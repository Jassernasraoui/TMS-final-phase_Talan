page 73637 "Tal Planning Map Page"
{
    PageType = CardPart;
    SourceTable = "Planning Lines";
    ApplicationArea = All;
    Caption = 'Carte de Planning';

    layout
    {
        area(content)
        {
            usercontrol(PlanningMap; PlanningMapAddIn)
            {
                ApplicationArea = All;

                trigger OnControlReady()
                var
                    OnlineMapIntegration: Codeunit "Online Map Integration";
                    LocationsArray: JsonArray;
                begin
                    // Initialiser la carte avec les paramètres Bing Maps
                    OnlineMapIntegration.InitializeMapControl(CurrPage.PlanningMap);

                    // Charger les localisations
                    LoadPlanningLocations(LocationsArray);

                    // Mettre à jour la carte
                    OnlineMapIntegration.UpdateMapLocations(CurrPage.PlanningMap, LocationsArray);

                    Message('🗺️ Carte prête et initialisée !');
                end;

                trigger OnLocationSelected(locationId: Text; locationInfo: Text)
                var
                    LocationInfoObj: JsonObject;
                    PlanningLine: Record "Planning Lines";
                    LineNo: Integer;
                begin
                    // Analyser l'information de localisation
                    LocationInfoObj.ReadFrom(locationInfo);

                    // Extraire le numéro de ligne pour filtrer les données
                    if Evaluate(LineNo, locationId) then begin
                        // Filtrer les données de planning
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Line No.", LineNo);

                        if PlanningLine.FindFirst() then begin
                            // Sélectionner cette ligne dans la source
                            Rec := PlanningLine;
                            CurrPage.Update(false);

                            // Mettre en évidence sur la carte
                            CurrPage.PlanningMap.HighlightLocation(locationId);

                            Message('📍 Sélection: %1', PlanningLine.Description);
                        end;
                    end;
                end;

                trigger OnRouteCalculated(routeInfo: Text; totalDistance: Decimal; totalTime: Decimal)
                var
                    PlanificationHeader: Record "Planification Header";
                begin
                    // Mettre à jour les informations d'itinéraire dans l'en-tête de planification
                    if PlanificationHeader.Get(Rec."Logistic Tour No.") then begin
                        PlanificationHeader."Estimated Distance" := totalDistance;
                        PlanificationHeader."Estimated Duration" := totalTime / 60; // Convertir minutes en heures
                        PlanificationHeader.Modify();
                    end;

                    Message('🛣️ Itinéraire calculé: Distance: %1 km, Temps estimé: %2 min',
                            Format(totalDistance, 0, '<Precision,2><Standard Format,1>'),
                            Format(totalTime, 0, '<Precision,0>'));
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshMap)
            {
                ApplicationArea = All;
                Caption = '🔄 Actualiser';
                ToolTip = 'Actualiser la carte';
                Image = Refresh;

                trigger OnAction()
                var
                    OnlineMapIntegration: Codeunit "Online Map Integration";
                    LocationsArray: JsonArray;
                begin
                    LoadPlanningLocations(LocationsArray);
                    OnlineMapIntegration.UpdateMapLocations(CurrPage.PlanningMap, LocationsArray);
                    CurrPage.Update(false);
                    Message('✅ Carte actualisée');
                end;
            }

            action(CalculateRoute)
            {
                ApplicationArea = All;
                Caption = '🛣️ Calculer Route';
                ToolTip = 'Calculer l''itinéraire optimal pour toutes les livraisons';
                Image = GetEntries;

                trigger OnAction()
                var
                    OnlineMapIntegration: Codeunit "Online Map Integration";
                    PlanningLine: Record "Planning Lines";
                    StartLocationId: Text;
                begin
                    // Utiliser la ligne actuelle comme point de départ ou prendre la première ligne
                    if Rec."Line No." <> 0 then
                        StartLocationId := Format(Rec."Line No.")
                    else begin
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                        if PlanningLine.FindFirst() then
                            StartLocationId := Format(PlanningLine."Line No.")
                        else
                            StartLocationId := '0'; // Valeur par défaut
                    end;

                    // Lancer le calcul de l'itinéraire avec Bing Maps
                    OnlineMapIntegration.CalculateOptimalRoute(CurrPage.PlanningMap, StartLocationId, 'timeWithTraffic');
                    Message('🧮 Calcul de l''itinéraire optimal en cours...');
                end;
            }

            action(ClearRoutes)
            {
                ApplicationArea = All;
                Caption = '🧹 Effacer Route';
                ToolTip = 'Effacer l''itinéraire de la carte';
                Image = ClearFilter;

                trigger OnAction()
                var
                    OnlineMapIntegration: Codeunit "Online Map Integration";
                begin
                    OnlineMapIntegration.ClearRoute(CurrPage.PlanningMap);
                    Message('🗑️ Itinéraire effacé');
                end;
            }

            action(FilterByDate)
            {
                ApplicationArea = All;
                Caption = '📅 Filtrer par Date';
                ToolTip = 'Filtrer par date';
                Image = Calendar;

                trigger OnAction()
                var
                    OnlineMapIntegration: Codeunit "Online Map Integration";
                    FilterDate: Date;
                    LocationsArray: JsonArray;
                    Option: Integer;
                    DateDialog: Page "Tal Date Dialog";
                begin
                    FilterDate := WorkDate();

                    Option := Dialog.StrMenu('Aujourd''hui|Demain|Semaine prochaine|Mois prochain|Date spécifique', 1, 'Choisir une période');

                    case Option of
                        1:  // Aujourd'hui (par défaut)
                            FilterDate := WorkDate();
                        2:  // Demain
                            FilterDate := CalcDate('<+1D>', WorkDate());
                        3:  // Semaine prochaine
                            FilterDate := CalcDate('<+1W>', WorkDate());
                        4:  // Mois prochain
                            FilterDate := CalcDate('<+1M>', WorkDate());
                        5:  // Date spécifique
                            begin
                                DateDialog.SetDate(WorkDate());
                                if DateDialog.RunModal() = Action::OK then
                                    FilterDate := DateDialog.GetDate()
                                else
                                    exit;
                            end;
                        else
                            exit;
                    end;

                    // Appliquer le filtre
                    Rec.Reset();
                    Rec.SetRange("Expected Shipment Date", FilterDate);
                    CurrPage.Update(false);

                    // Mettre à jour la carte
                    LoadPlanningLocations(LocationsArray);
                    OnlineMapIntegration.UpdateMapLocations(CurrPage.PlanningMap, LocationsArray);

                    Message('📅 Filtrage par date: %1', Format(FilterDate, 0, '<Day,2>/<Month,2>/<Year4>'));
                end;
            }

            action(OpenBingMapsSetup)
            {
                ApplicationArea = All;
                Caption = '⚙️ Configuration Cartes';
                ToolTip = 'Ouvrir la configuration des services de cartographie';
                Image = Setup;
                RunObject = Page "Online Map Setup";
            }
        }
    }

    local procedure LoadPlanningLocations(var LocationsArray: JsonArray)
    var
        PlanningLine: Record "Planning Lines";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ShipToAddress: Record "Ship-to Address";
        LocationObj: JsonObject;
        AddressObj: JsonObject;
        CoordinatesObj: JsonObject;
        ResponseObj: JsonObject;
    begin
        // Créer le conteneur de réponse structuré
        ResponseObj := CreateResponseObject();
        Clear(LocationsArray);

        // Collecter les données de planning filtrées
        PlanningLine.Reset();
        PlanningLine.CopyFilters(Rec); // Utiliser les filtres actuels

        if PlanningLine.FindSet() then
            repeat
                // Créer un objet pour cette localisation
                LocationObj := GetEmptyJsonObject();
                AddressObj := GetEmptyJsonObject();
                CoordinatesObj := GetEmptyJsonObject();

                // Identifiant unique (numéro de ligne)
                LocationObj.Add('id', Format(PlanningLine."Line No."));

                // Données de base
                LocationObj.Add('title', GetLocationTitle(PlanningLine));
                LocationObj.Add('type', Format(PlanningLine."Type"));
                LocationObj.Add('sourceID', PlanningLine."Source ID");
                LocationObj.Add('priority', Format(PlanningLine.Priority));

                if PlanningLine."Expected Shipment Date" <> 0D then
                    LocationObj.Add('date', Format(PlanningLine."Expected Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>'));

                // Récupérer les informations d'adresse en fonction du type de document
                case PlanningLine."Type" of
                    PlanningLine."Type"::Sales:
                        begin
                            // Informations client et adresse de livraison
                            if PlanningLine."Customer No." <> '' then begin
                                LocationObj.Add('customerNo', PlanningLine."Customer No.");

                                // Vérifier si nous avons une adresse spécifique de livraison
                                if SalesHeader.Get(SalesHeader."Document Type"::Order, PlanningLine."Source ID") then begin
                                    if SalesHeader."Ship-to Code" <> '' then begin
                                        if ShipToAddress.Get(PlanningLine."Customer No.", SalesHeader."Ship-to Code") then begin
                                            AddAddressToJson(AddressObj, ShipToAddress.Name, ShipToAddress.Address,
                                                            ShipToAddress."Post Code", ShipToAddress.City,
                                                            ShipToAddress."Country/Region Code", ShipToAddress.Contact);

                                            // Ajouter les coordonnées géographiques
                                            AddGeoCoordinates(CoordinatesObj, ShipToAddress."Post Code", ShipToAddress.City);
                                        end;
                                    end else begin
                                        // Utiliser l'adresse Ship-to du document
                                        AddAddressToJson(AddressObj, SalesHeader."Ship-to Name", SalesHeader."Ship-to Address",
                                                        SalesHeader."Ship-to Post Code", SalesHeader."Ship-to City",
                                                        SalesHeader."Ship-to Country/Region Code", SalesHeader."Ship-to Contact");

                                        // Ajouter les coordonnées géographiques
                                        AddGeoCoordinates(CoordinatesObj, SalesHeader."Ship-to Post Code", SalesHeader."Ship-to City");
                                    end;
                                end else if Customer.Get(PlanningLine."Customer No.") then begin
                                    // Utiliser l'adresse client standard
                                    AddAddressToJson(AddressObj, Customer.Name, Customer.Address,
                                                    Customer."Post Code", Customer.City,
                                                    Customer."Country/Region Code", Customer.Contact);

                                    // Ajouter les coordonnées géographiques
                                    AddGeoCoordinates(CoordinatesObj, Customer."Post Code", Customer.City);
                                end;
                            end;
                        end;
                    PlanningLine."Type"::Purchase:
                        begin
                            // Informations fournisseur
                            if PlanningLine."Vendor No." <> '' then begin
                                LocationObj.Add('vendorNo', PlanningLine."Vendor No.");

                                if Vendor.Get(PlanningLine."Vendor No.") then begin
                                    AddAddressToJson(AddressObj, Vendor.Name, Vendor.Address,
                                                    Vendor."Post Code", Vendor.City,
                                                    Vendor."Country/Region Code", Vendor.Contact);

                                    // Ajouter les coordonnées géographiques
                                    AddGeoCoordinates(CoordinatesObj, Vendor."Post Code", Vendor.City);
                                end;
                            end;
                        end;
                    PlanningLine."Type"::Transfer:
                        begin
                            // Informations sur le transfert entre magasins
                            if TransferHeader.Get(PlanningLine."Source ID") then begin
                                // Utiliser le magasin de destination comme localisation
                                if Location.Get(TransferHeader."Transfer-to Code") then begin
                                    AddAddressToJson(AddressObj, Location.Name, Location.Address,
                                                    Location."Post Code", Location.City,
                                                    Location."Country/Region Code", Location.Contact);

                                    // Ajouter les coordonnées géographiques
                                    AddGeoCoordinates(CoordinatesObj, Location."Post Code", Location.City);
                                end;
                            end;
                        end;
                end;

                // Ajouter les détails d'adresse et de coordonnées à la localisation
                LocationObj.Add('address', AddressObj);
                LocationObj.Add('coordinates', CoordinatesObj);

                // Définir le type de marqueur et couleur en fonction du type et de la priorité
                AddMarkerStyle(LocationObj, Format(PlanningLine."Type"), Format(PlanningLine.Priority));

                // Ajouter la localisation au tableau
                LocationsArray.Add(LocationObj);
            until PlanningLine.Next() = 0;

        // Ajouter les localisations au conteneur de réponse
        ResponseObj.Add('locations', LocationsArray);

        // Remplacer LocationsArray par le conteneur de réponse complet
        Clear(LocationsArray);
        LocationsArray.Add(ResponseObj);
    end;

    local procedure GetLocationTitle(PlanningLine: Record "Planning Lines"): Text
    begin
        if PlanningLine.Description <> '' then
            exit(PlanningLine.Description)
        else if PlanningLine."Item No." <> '' then
            exit(PlanningLine."Item No.")
        else
            exit(Format(PlanningLine."Type") + ': ' + PlanningLine."Source ID");
    end;

    local procedure AddAddressToJson(var AddressObj: JsonObject; Name: Text; Address: Text;
                                    PostCode: Text; City: Text; Country: Text; Contact: Text)
    begin
        if Name <> '' then
            AddressObj.Add('name', Name);
        if Address <> '' then
            AddressObj.Add('street', Address);
        if PostCode <> '' then
            AddressObj.Add('postCode', PostCode);
        if City <> '' then
            AddressObj.Add('city', City);
        if Country <> '' then
            AddressObj.Add('country', Country);
        if Contact <> '' then
            AddressObj.Add('contact', Contact);

        // Concaténer pour affichage
        AddressObj.Add('formatted', FormatAddress(Name, Address, PostCode, City, Country));
    end;

    local procedure FormatAddress(Name: Text; Address: Text; PostCode: Text; City: Text; Country: Text): Text
    var
        FormattedAddress: Text;
    begin
        FormattedAddress := Name;

        if Address <> '' then
            FormattedAddress += StrSubstNo(', %1', Address);

        if (PostCode <> '') or (City <> '') then
            FormattedAddress += StrSubstNo(', %1 %2', PostCode, City);

        if Country <> '' then
            FormattedAddress += StrSubstNo(', %1', Country);

        exit(FormattedAddress);
    end;

    local procedure AddGeoCoordinates(var CoordinatesObj: JsonObject; PostCode: Text; City: Text)
    var
        GeoDataHelper: Record "Online Map Parameters"; // Utilisé uniquement pour le cache, pas idéal mais fonctionnel
        Coordinates: List of [Decimal];
        CacheKey: Text;
        Lat, Lng : Decimal;
        Found: Boolean;
    begin
        // Dans une version réelle, vous utiliseriez un service de géocodage
        CacheKey := PostCode + '|' + City;

        // Rechercher dans la "cache" (temporaire - en production utilisez une table dédiée)
        GeoDataHelper.Reset();
        GeoDataHelper.SetRange(Code, CacheKey);
        if GeoDataHelper.FindFirst() then begin
            // Utiliser les valeurs en cache
            Evaluate(Lat, GeoDataHelper.Name);
            Evaluate(Lng, GeoDataHelper."Map Service");
            Found := true;
        end else begin
            // Simuler des coordonnées en France
            Coordinates := GetSimulatedCoordinates(PostCode, City);
            if Coordinates.Count >= 2 then begin
                Lat := Coordinates.Get(1);
                Lng := Coordinates.Get(2);

                // Stocker dans la "cache"
                GeoDataHelper.Init();
                GeoDataHelper.Code := CopyStr(CacheKey, 1, 20);
                GeoDataHelper.Name := Format(Lat);
                GeoDataHelper."Map Service" := Format(Lng);
                if GeoDataHelper.Insert() then;

                Found := true;
            end;
        end;

        // Ajouter les coordonnées
        if Found then begin
            CoordinatesObj.Add('latitude', Lat);
            CoordinatesObj.Add('longitude', Lng);
        end else begin
            // Valeurs par défaut (Paris)
            CoordinatesObj.Add('latitude', 48.856614);
            CoordinatesObj.Add('longitude', 2.3522219);
        end;
    end;

    local procedure GetSimulatedCoordinates(PostCode: Text; City: Text) CoordList: List of [Decimal]
    var
        Seed: Integer;
        Lat, Lng : Decimal;
    begin
        // Cette fonction simule des coordonnées basées sur le code postal
        // Dans une version réelle, vous utiliseriez un service API de géocodage
        CoordList := GetEmptyDecimalList();

        if PostCode = '' then
            PostCode := '75000'; // Paris par défaut

        // Générer un nombre entre 0 et 99 basé sur le code postal pour la variation
        if Evaluate(Seed, CopyStr(PostCode, 1, 2)) then begin
            // France approximativement: Lat: 42-51, Lng: -4-8
            Lat := 42 + (Seed mod 9) + Random(100) / 100;
            Lng := -4 + (Seed mod 12) + Random(100) / 100;
        end else begin
            // Paris par défaut
            Lat := 48.856614 + (Random(100) - 50) / 1000;
            Lng := 2.3522219 + (Random(100) - 50) / 1000;
        end;

        CoordList.Add(Lat);
        CoordList.Add(Lng);
    end;

    local procedure AddMarkerStyle(var LocationObj: JsonObject; PlanningType: Text; Priority: Text)
    var
        MarkerColor: Text;
        MarkerIcon: Text;
    begin
        // Déterminer l'icône en fonction du type de document
        case PlanningType of
            'Sales':
                MarkerIcon := 'shopping-cart';
            'Purchase':
                MarkerIcon := 'cube';
            'Transfer':
                MarkerIcon := 'exchange-alt';
            else
                MarkerIcon := 'map-marker-alt';
        end;

        // Déterminer la couleur en fonction de la priorité
        case Priority of
            'Critical':
                MarkerColor := '#d13438'; // Rouge
            'High':
                MarkerColor := '#ffaa44'; // Orange
            'Low':
                MarkerColor := '#107c10'; // Vert
            else
                MarkerColor := '#0078D4'; // Bleu BC par défaut
        end;

        // Ajouter les propriétés de style au marqueur
        LocationObj.Add('markerIcon', MarkerIcon);
        LocationObj.Add('markerColor', MarkerColor);
    end;

    local procedure CreateResponseObject() ResponseObj: JsonObject
    begin
        // Créer un objet JSON pour contenir toutes les données
        ResponseObj.Add('version', '1.0');
        ResponseObj.Add('source', 'Business Central');
        ResponseObj.Add('generatedAt', Format(CurrentDateTime(), 0, 9)); // ISO format
    end;

    local procedure GetEmptyJsonObject() ResultObject: JsonObject
    begin
        // Return an empty JSON object
        Clear(ResultObject);
    end;

    local procedure GetEmptyJsonArray() ResultArray: JsonArray
    begin
        // Return an empty JSON array
        Clear(ResultArray);
    end;

    local procedure GetEmptyDecimalList() ResultList: List of [Decimal]
    begin
        // Return an empty list of decimals
        Clear(ResultList);
    end;
}