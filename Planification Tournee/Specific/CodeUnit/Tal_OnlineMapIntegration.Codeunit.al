codeunit 77150 "Online Map Integration"
{
    // Codeunit pour gérer l'intégration avec les services de cartographie en ligne

    trigger OnRun()
    begin
        // Non utilisé pour le trigger OnRun
    end;

    var
        MapSetupNotFoundErr: Label 'Configuration de la carte non trouvée. Veuillez configurer les paramètres de la carte en ligne.';

    procedure InitializeMapControl(PlanningMapCtrl: ControlAddIn PlanningMapAddIn)
    var
        MapSetup: Record "Online Map Parameters";
        MapSubstitution: Record "Online Map Substitution";
        MapParamsJson: JsonObject;
    begin
        if not GetDefaultMapSetup(MapSetup) then
            Error(MapSetupNotFoundErr);

        // Initialiser les paramètres standard si nécessaire
        MapSubstitution.InitializeStandardParameters();

        // Configurer la clé API
        PlanningMapCtrl.SetBingMapsKey(MapSetup."API Key");

        // Configurer les paramètres de la carte
        MapParamsJson.Add('defaultLocation', CreateLocationJson(48.856614, 2.3522219)); // Paris par défaut
        MapParamsJson.Add('zoom', 6);
        MapParamsJson.Add('mapType', 'road');

        PlanningMapCtrl.SetMapParameters(Format(MapParamsJson));
    end;

    procedure UpdateMapLocations(PlanningMapCtrl: ControlAddIn PlanningMapAddIn; LocationsArray: JsonArray)
    begin
        PlanningMapCtrl.UpdateLocations(Format(LocationsArray));
    end;

    procedure CalculateOptimalRoute(PlanningMapCtrl: ControlAddIn PlanningMapAddIn; StartLocationId: Text; Algorithm: Text)
    begin
        PlanningMapCtrl.CalculateOptimalRoute(StartLocationId, Algorithm);
    end;

    procedure ClearRoute(PlanningMapCtrl: ControlAddIn PlanningMapAddIn)
    begin
        PlanningMapCtrl.ClearRoute();
    end;

    procedure HighlightLocation(PlanningMapCtrl: ControlAddIn PlanningMapAddIn; LocationId: Text)
    begin
        PlanningMapCtrl.HighlightLocation(LocationId);
    end;

    procedure GetAddressUrl(CustomerNo: Code[20]; ShowInBrowser: Boolean): Text
    var
        Customer: Record Customer;
        MapSetup: Record "Online Map Parameters";
        MapUrl: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit('');

        if not GetDefaultMapSetup(MapSetup) then
            exit('');

        MapUrl := FormatAddressUrl(MapSetup, Customer.Address, Customer.City, Customer."Post Code", Customer."Country/Region Code");

        if ShowInBrowser then
            Hyperlink(MapUrl);

        exit(MapUrl);
    end;

    procedure GetDirectionsUrl(FromCustomerNo: Code[20]; ToCustomerNo: Code[20]; ShowInBrowser: Boolean): Text
    var
        FromCustomer, ToCustomer : Record Customer;
        MapSetup: Record "Online Map Parameters";
        DirectionsUrl: Text;
    begin
        if not (FromCustomer.Get(FromCustomerNo) and ToCustomer.Get(ToCustomerNo)) then
            exit('');

        if not GetDefaultMapSetup(MapSetup) then
            exit('');

        DirectionsUrl := FormatDirectionsUrl(
            MapSetup,
            FromCustomer.Address, FromCustomer.City, FromCustomer."Post Code", FromCustomer."Country/Region Code",
            ToCustomer.Address, ToCustomer.City, ToCustomer."Post Code", ToCustomer."Country/Region Code"
        );

        if ShowInBrowser then
            Hyperlink(DirectionsUrl);

        exit(DirectionsUrl);
    end;

    local procedure GetDefaultMapSetup(var MapSetup: Record "Online Map Parameters"): Boolean
    begin
        MapSetup.Reset();
        MapSetup.SetRange("Is Default", true);

        if not MapSetup.FindFirst() then begin
            MapSetup.Reset();
            if not MapSetup.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure FormatAddressUrl(MapSetup: Record "Online Map Parameters"; Address: Text; City: Text; PostCode: Text; CountryCode: Text): Text
    var
        FormattedAddress: Text;
        MapUrl: Text;
    begin
        FormattedAddress := FormatAddress(Address, City, PostCode, CountryCode);

        // Utiliser l'URL du service de carte configuré
        MapUrl := MapSetup."Map Service";

        // Remplacer les paramètres
        MapUrl := MapUrl.Replace('{0}', UrlEncode(FormattedAddress));

        exit(MapUrl);
    end;

    local procedure FormatDirectionsUrl(MapSetup: Record "Online Map Parameters";
                                       FromAddress: Text; FromCity: Text; FromPostCode: Text; FromCountryCode: Text;
                                       ToAddress: Text; ToCity: Text; ToPostCode: Text; ToCountryCode: Text): Text
    var
        FromFormattedAddress, ToFormattedAddress : Text;
        DirectionsUrl: Text;
    begin
        FromFormattedAddress := FormatAddress(FromAddress, FromCity, FromPostCode, FromCountryCode);
        ToFormattedAddress := FormatAddress(ToAddress, ToCity, ToPostCode, ToCountryCode);

        // Utiliser l'URL du service de directions configuré
        DirectionsUrl := MapSetup."Directions Service";

        // Remplacer les paramètres
        DirectionsUrl := DirectionsUrl.Replace('{0}', UrlEncode(FromFormattedAddress));
        DirectionsUrl := DirectionsUrl.Replace('{1}', UrlEncode(ToFormattedAddress));

        exit(DirectionsUrl);
    end;

    local procedure FormatAddress(Address: Text; City: Text; PostCode: Text; CountryCode: Text): Text
    var
        FormattedAddress: Text;
    begin
        FormattedAddress := '';

        if Address <> '' then
            FormattedAddress += Address;

        if City <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ', ';
            FormattedAddress += City;
        end;

        if PostCode <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ' ';
            FormattedAddress += PostCode;
        end;

        if CountryCode <> '' then begin
            if FormattedAddress <> '' then
                FormattedAddress += ', ';
            FormattedAddress += CountryCode;
        end;

        exit(FormattedAddress);
    end;

    local procedure UrlEncode(TextToEncode: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UrlEncode(TextToEncode));
    end;

    local procedure CreateLocationJson(Latitude: Decimal; Longitude: Decimal): JsonObject
    var
        LocationJson: JsonObject;
    begin
        LocationJson.Add('latitude', Latitude);
        LocationJson.Add('longitude', Longitude);
        exit(LocationJson);
    end;
}