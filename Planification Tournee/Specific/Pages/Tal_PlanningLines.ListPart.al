page 73655 "Planning Lines"
{
    PageType = ListPart;
    SourceTable = "Planning Lines";
    ApplicationArea = All;
    // SourceTableView = where("Document Type" = filter(Invoice));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Type"; rec."Type")
                {
                    ApplicationArea = All;
                }
                field("Logistic Tour No."; rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    visible = false;
                }
                field("Source ID"; rec."Source ID")
                {
                    ApplicationArea = All;
                    Caption = 'Source Document ID';
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor No.';
                    ToolTip = 'Specifies the account number.';
                    Editable = false;
                }

                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                    visible = false;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision"; rec."Qty. Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Qty. Rounding Precision (Base)"; rec."Qty. Rounding Precision (Base)")
                {
                    ApplicationArea = All;
                }
                field("Unit Volume"; rec."Unit Volume")
                {
                    ApplicationArea = All;
                }
                field("Gross Weight"; rec."Gross Weight")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; rec."Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; rec."Ship-to Address")
                {
                    ApplicationArea = all;
                }
                field("Global Dimension 1 Code"; rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 1 Code';
                }
                field("Global Dimension 2 Code"; rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 2 Code';
                }
                field("Dimension Set ID"; rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("Planned Date"; rec." Delivery Date")
                {
                    ApplicationArea = All;
                }
                field(" Shipment Date"; rec."Expected Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Created At"; rec."Created At")
                {
                    ApplicationArea = All;
                }
                field("Created By"; rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Modified At"; rec."Modified At")
                {
                    ApplicationArea = All;
                }
                field("Modified By"; rec."Modified By")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    ToolTip = 'Specifies the location code for the transfer order.';
                    Visible = true; // Set to true if you want to show this field
                }

            }
        }
    }
    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = 'Sales/Purchase Lines';
                Image = Line;
                group("F&unctions")
                {
                    Caption = 'F&unctions';
                    Image = "Action";
                    action(GetPrice)
                    {
                        AccessByPermission = TableData "Sales Price Access" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Get &Price';
                        Ellipsis = true;
                        Image = Price;
                        // Visible = ExtendedPriceEnabled;
                        ToolTip = 'Insert the lowest possible price in the Unit Price field according to any special price that you have set up.';

                        // trigger OnAction()
                        // begin
                        //     ShowPrices()
                        // end;
                    }
                    action(GetLineDiscount)
                    {
                        AccessByPermission = TableData "Sales Discount Access" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Get Li&ne Discount';
                        Ellipsis = true;
                        Image = LineDiscount;
                        // Visible = ExtendedPriceEnabled;
                        ToolTip = 'Insert the best possible discount in the Line Discount field according to any special discounts that you have set up.';

                        // trigger OnAction()
                        // begin
                        //     ShowLineDisc()
                        // end;
                    }
                    action(InsertExtTexts)
                    {
                        AccessByPermission = TableData "Extended Text Header" = R;
                        ApplicationArea = Suite;
                        Caption = 'Insert &Ext. Texts';
                        Image = Text;
                        Scope = Repeater;
                        ToolTip = 'Insert the extended item description that is set up for the item that is being processed on the line.';

                        trigger OnAction()
                        begin
                            InsertExtendedText(true);
                        end;
                    }
                    action(GetShipmentLines)
                    {
                        AccessByPermission = TableData "Sales Shipment Header" = R;
                        ApplicationArea = Suite;
                        Caption = 'Get &Shipment Lines';
                        Ellipsis = true;
                        Image = Shipment;
                        ToolTip = 'Select multiple shipments to the same customer because you want to combine them on one invoice.';

                        trigger OnAction()
                        begin
                            GetShipment();
                            RedistributeTotalsOnAfterValidate();
                        end;
                    }
                    action(GetJobPlanningLines)
                    {
                        AccessByPermission = TableData "Job Planning Line" = R;
                        ApplicationArea = Jobs;
                        Caption = 'Get &Project Planning Lines';
                        Ellipsis = true;
                        Image = JobLines;
                        ToolTip = 'Select multiple planning lines to the same customer because you want to combine them on one invoice.';

                        trigger OnAction()
                        begin
                            GetJobLines();
                            RedistributeTotalsOnAfterValidate();
                        end;
                    }
                    // Ajout de la nouvelle action pour extraire les lignes de ventes
                    action(GetSalesLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '&Get Sales Lines';
                        Ellipsis = true;
                        Image = Sales;
                        ToolTip = 'Sélectionner et extraire les lignes de vente pour les ajouter à la planification du tour.';

                        trigger OnAction()
                        begin
                            GetSalesLinesForTourPlanning();
                        end;
                    }
                    action(GetReceiptLines)
                    {
                        AccessByPermission = TableData "Purch. Rcpt. Header" = R;
                        ApplicationArea = Suite;
                        Caption = '&Get Receipt Lines';
                        Ellipsis = true;
                        Image = Receipt;
                        ToolTip = 'Select a posted purchase receipt for the item that you want to assign the item charge to.';

                        trigger OnAction()
                        begin
                            GetReceipt();
                            RedistributeTotalsOnAfterValidate();
                        end;
                    }
                    action("Get Bin Content")
                    {
                        AccessByPermission = TableData "Bin Content" = R;
                        ApplicationArea = Warehouse;
                        Caption = 'Get Bin Content';
                        Ellipsis = true;
                        Image = GetBinContent;
                        ToolTip = 'Use a function to create transfer lines with items to put away or pick based on the actual content in the specified bin.';

                        trigger OnAction()
                        var
                            BinContent: Record "Bin Content";
                            GetBinContent: Report "Whse. Get Bin Content";
                        begin
                            BinContent.SetRange("Location Code", Rec."Transfer-from Code");
                            GetBinContent.SetTableView(BinContent);
                            // GetBinContent.InitializeTransferHeader(Rec);
                            GetBinContent.RunModal();
                        end;
                    }
                }
            }

            group("Warehouse")
            {
                Caption = 'Transfer Order lines';
                Image = Warehouse;
                action("Whse. Shi&pments")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Whse. Shi&pments';
                    Image = Shipment;
                    RunObject = Page "Whse. Shipment Lines";
                    RunPageLink = "Source Type" = const(5741),
                                  "Source Subtype" = const("0"),
                                  "Source No." = field("Item No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    ToolTip = 'View outbound items that have been shipped with warehouse activities for the transfer order.';
                }
                action("&Whse. Receipts")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Whse. Receipts';
                    Image = Receipt;
                    RunObject = Page "Whse. Receipt Lines";
                    RunPageLink = "Source Type" = const(5741),
                                  "Source Subtype" = const("1"),
                                  "Source No." = field("Item No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    ToolTip = 'View inbound items that have been received with warehouse activities for the transfer order.';
                }
                action("In&vt. Put-away/Pick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'In&vt. Put-away/Pick Lines';
                    Image = PickLines;
                    RunObject = Page "Warehouse Activity List";
                    RunPageLink = "Source Document" = filter("Inbound Transfer" | "Outbound Transfer"),
                                  "Source No." = field("Item No.");
                    RunPageView = sorting("Source Document", "Source No.", "Location Code");
                    ToolTip = 'View items that are inbound or outbound on inventory put-away or inventory pick documents for the transfer order.';
                }
                action("Whse. Put-away/Pick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Put-away/Pick Lines';
                    Image = PutawayLines;
                    RunObject = page "Warehouse Activity Lines";
                    RunPageLink = "Source Document" = filter("Inbound Transfer" | "Outbound Transfer"), "Source No." = field("Item No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.");
                    ToolTip = 'View items that are inbound or outbound on warehouse put-away or warehouse pick documents for the transfer order.';
                }
            }

            group("Maps")
            {
                action(ShowMap)
                {
                    ApplicationArea = All;
                    Caption = 'Show All on Map';
                    Image = Map;
                    trigger OnAction()
                    var
                        PlanningLine: Record "Planning Lines";
                        OnlineMapIntegration: Codeunit "Online Map Integration";
                        Customer: Record Customer;
                        Vendor: Record Vendor;
                        Location: Record Location;
                        SalesHeader: Record "Sales Header";
                        PurchaseHeader: Record "Purchase Header";
                        TransferHeader: Record "Transfer Header";
                        ShipToAddress: Record "Ship-to Address";
                        LocationsList: Text;
                        MapUrl: Text;
                        Address: Text;
                        City: Text;
                        PostCode: Text;
                        CountryCode: Text;
                        Latitude: Text;
                        Longitude: Text;
                        LocationName: Text;
                        LocationCount: Integer;
                    begin
                        LocationsList := '';
                        LocationCount := 0;

                        // Get all planning lines
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");

                        if PlanningLine.FindSet() then begin
                            repeat
                                Clear(Address);
                                Clear(City);
                                Clear(PostCode);
                                Clear(CountryCode);
                                Clear(Latitude);
                                Clear(Longitude);
                                Clear(LocationName);

                                // Extract address information based on document type
                                case PlanningLine."Type" of
                                    PlanningLine."Type"::Sales:
                                        begin
                                            // Try to get customer address - first check if there's a ship-to address
                                            if SalesHeader.Get(SalesHeader."Document Type"::Order, PlanningLine."Source ID") then begin
                                                if (SalesHeader."Ship-to Code" <> '') and ShipToAddress.Get(PlanningLine."Account No.", SalesHeader."Ship-to Code") then begin
                                                    LocationName := ShipToAddress.Name;
                                                    Address := ShipToAddress.Address;
                                                    City := ShipToAddress.City;
                                                    PostCode := ShipToAddress."Post Code";
                                                    CountryCode := ShipToAddress."Country/Region Code";
                                                end else begin
                                                    LocationName := SalesHeader."Ship-to Name";
                                                    Address := SalesHeader."Ship-to Address";
                                                    City := SalesHeader."Ship-to City";
                                                    PostCode := SalesHeader."Ship-to Post Code";
                                                    CountryCode := SalesHeader."Ship-to Country/Region Code";
                                                end;
                                            end else if Customer.Get(PlanningLine."Account No.") then begin
                                                // Default to customer address
                                                LocationName := Customer.Name;
                                                Address := Customer.Address;
                                                City := Customer.City;
                                                PostCode := Customer."Post Code";
                                                CountryCode := Customer."Country/Region Code";
                                            end;
                                        end;
                                    PlanningLine."Type"::Purchase:
                                        begin
                                            if Vendor.Get(PlanningLine."Account No.") then begin
                                                LocationName := Vendor.Name;
                                                Address := Vendor.Address;
                                                City := Vendor.City;
                                                PostCode := Vendor."Post Code";
                                                CountryCode := Vendor."Country/Region Code";
                                            end;
                                        end;
                                    PlanningLine."Type"::Transfer:
                                        begin
                                            if Location.Get(PlanningLine."Location Code") then begin
                                                LocationName := Location.Name;
                                                Address := Location.Address;
                                                City := Location.City;
                                                PostCode := Location."Post Code";
                                                CountryCode := Location."Country/Region Code";
                                            end;
                                        end;
                                end;

                                // Build the formatted address if we have valid address information
                                if (Address <> '') or (City <> '') or (PostCode <> '') then begin
                                    LocationCount += 1;

                                    // Format the address for the map URL
                                    if LocationsList <> '' then
                                        LocationsList += '/';

                                    // Format the address with proper URL encoding
                                    LocationsList += EncodeUrl(
                                        FormatAddress(Address, City, PostCode, CountryCode)
                                    );
                                end;
                            until PlanningLine.Next() = 0;
                        end;

                        if LocationCount > 0 then begin
                            // Use Google Maps directions service for multiple locations
                            if LocationCount > 1 then
                                MapUrl := 'https://www.google.com/maps/dir/' + LocationsList
                            else
                                MapUrl := 'https://www.google.com/maps/search/?api=1&query=' + LocationsList;

                            Hyperlink(MapUrl);
                        end else
                            Message('No valid addresses found in the current planning lines.');
                    end;
                }
            }
            group("Related Information")
            {
                Caption = 'Related Information';
                Image = RelatedInformation;

                action("Item &Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    Enabled = ItemTrackingEnabled;
                    ToolTip = 'View or edit serial numbers, lot numbers, and package numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines();
                    end;
                }
                action("Show Item Tracking Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Voir Item Tracking Lines';
                    Image = ItemTracking;
                    ToolTip = 'Afficher le suivi des lots/séries pour cette ligne de planification ou issue de documents vente/achat.';
                    trigger OnAction()
                    var
                        PlanningItemTrackingMgt: Codeunit "Planning Item Tracking Mgt";
                        SalesLine: Record "Sales Line";
                        PurchLine: Record "Purchase Line";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        // Si la ligne de planification provient d'une vente
                        if Rec."Type" = Rec."Type"::Sales then begin
                            if SalesLine.Get(SalesLine."Document Type"::Order, Rec."Source ID", Rec."Line No.") then begin
                                PAGE.RunModal(PAGE::"Item Tracking Lines", SalesLine);
                                IsHandled := true;
                            end;
                        end;
                        // Si la ligne de planification provient d'un achat
                        if Rec."Type" = Rec."Type"::Purchase then begin
                            if PurchLine.Get(PurchLine."Document Type"::Order, Rec."Source ID", Rec."Line No.") then begin
                                PAGE.RunModal(PAGE::"Item Tracking Lines", PurchLine);
                                IsHandled := true;
                            end;
                        end;
                        // Sinon, ouvrir le suivi sur la ligne de planification
                        if not IsHandled then
                            PlanningItemTrackingMgt.OpenItemTrackingLines(Rec);
                    end;
                }
            }

        }
    }
    var
        ItemTrackingEnabled: Boolean;
        PlanningItemTrackingMgt: Codeunit "Planning Item Tracking Mgt";

    trigger OnAfterGetRecord()
    begin
        UpdateItemTrackingStatus();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateItemTrackingStatus();
    end;

    local procedure UpdateItemTrackingStatus()
    begin
        ItemTrackingEnabled := PlanningItemTrackingMgt.HasItemTrackingCode(Rec."Item No.");
    end;

    local procedure OpenItemTrackingLines()
    begin
        PlanningItemTrackingMgt.OpenItemTrackingLines(Rec);
    end;

    protected var
        Currency: Record Currency;
        TotalSalesHeader: Record "Sales Header";
        TotalSalesLine: Record "Sales Line";
        DocumentTotals: Codeunit "Document Totals";
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        InvDiscAmountEditable: Boolean;
        InvoiceDiscountAmount: Decimal;
        InvoiceDiscountPct: Decimal;
        IsBlankNumber: Boolean;
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        IsCommentLine: Boolean;
        SuppressTotals: Boolean;
        ItemReferenceVisible: Boolean;
        LocationCodeVisible: Boolean;
        UnitofMeasureCodeIsChangeable: Boolean;
        VATAmount: Decimal;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        SalesAvailabilityMgt: Codeunit "Sales Availability Mgt.";
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";
        AmountWithDiscountAllowed: Decimal;
        UpdateAllowedVar: Boolean;
#pragma warning disable AA0074
        Text000: Label 'Unable to run this function while in View mode.';
#pragma warning restore AA0074
        VariantCodeMandatory: Boolean;
        CurrPageIsEditable: Boolean;
        IsSaaSExcelAddinEnabled: Boolean;
        ExtendedPriceEnabled: Boolean;
        ItemChargeStyleExpression: Text;
        TypeAsText: Text[30];
        TypeAsTextFieldVisible: Boolean;
        UseAllocationAccountNumber: Boolean;
        ActionOnlyAllowedForAllocationAccountsErr: Label 'This action is only available for lines that have Allocation Account set as Type.';
        ExcelFileNameTxt: Label 'Sales Invoice %1 - Lines', Comment = '%1 = document number, ex. 10000';

    procedure GetShipment()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Get Shipment", Rec);
    end;

    procedure GetReceipt()
    begin
        CODEUNIT.Run(CODEUNIT::"Purch.-Get Receipt", Rec);
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        // OnBeforeInsertExtendedText(Rec);
        // if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
        //  s   CurrPage.SaveRecord();
        //     Commit();
        //     TransferExtendedText.InsertSalesExtText(Rec);
        // end;
        if TransferExtendedText.MakeUpdate() then
            UpdatePage(true);
    end;

    procedure RedistributeTotalsOnAfterValidate()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SuppressTotals then
            exit;

        // CurrPage.SaveRecord();

        // SalesHeader.Get(Rec."Source ID", Rec."Item No.");
        // DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(Rec, VATAmount, TotalSalesLine);
        // CurrPage.Update(false);
    end;

    local procedure GetJobLines()
    begin
        Codeunit.Run(Codeunit::"Job-Process Plan. Lines", Rec);
    end;

    procedure UpdatePage(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertExtendedText(var SalesLine: Record "Sales Line")
    begin
    end;

    // Nouvelle procédure pour extraire les lignes de ventes
    procedure GetSalesLinesForTourPlanning()
    var
        SalesLine: Record "Sales Line";
        SalesLineSelection: Page "Sales Lines";
    begin
        // Configuration des filtres pour les lignes de vente
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        // Vous pouvez ajouter d'autres filtres selon vos besoins spécifiques

        // Configuration de la page de sélection
        SalesLineSelection.SetTableView(SalesLine);
        SalesLineSelection.LookupMode(true);

        if SalesLineSelection.RunModal() = ACTION::LookupOK then begin
            // Récupération des lignes sélectionnées
            SalesLineSelection.SetSelectionFilter(SalesLine);
            if SalesLine.FindSet() then
                TransferSalesLinesToTourPlanning(SalesLine);
        end;
    end;

    // Procédure pour transférer les lignes de ventes vers les lignes de planification
    procedure TransferSalesLinesToTourPlanning(var SalesLine: Record "Sales Line")
    var
        PlanningLine: Record "Planning Lines";
        LineNo: Integer;
    begin
        // Détermination du prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        if PlanningLine.FindLast() then
            LineNo := PlanningLine."Line No." + 10000
        else
            LineNo := 10000;

        // Traitement de chaque ligne de vente sélectionnée
        repeat
            // Création d'une nouvelle ligne de planification
            PlanningLine.Init();
            PlanningLine."Logistic Tour No." := Rec."Logistic Tour No.";
            PlanningLine."Line No." := LineNo;

            // Transfert des données de la ligne de vente
            PlanningLine."Source ID" := SalesLine."Document No.";
            PlanningLine."Item No." := SalesLine."No.";
            Planningline."Account No." := SalesLine."Sell-to Customer No.";
            PlanningLine.Description := SalesLine.Description;
            PlanningLine."Description 2" := SalesLine."Description 2";
            PlanningLine.Quantity := SalesLine.Quantity;
            PlanningLine."Quantity (Base)" := SalesLine."Quantity (Base)";
            PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
            PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
            PlanningLine."Variant Code" := SalesLine."Variant Code";
            PlanningLine."Location Code" := SalesLine."Location Code";

            // Vous pouvez ajouter d'autres champs selon votre structure de données
            PlanningLine." Delivery Date" := WorkDate();

            PlanningLine.Insert(true);
            LineNo += 10000;
        until SalesLine.Next() = 0;

        Message('Les lignes de vente ont été extraites avec succès.');
    end;

    local procedure EncodeUrl(TextToEncode: Text): Text
    var
        TempText: Text;
    begin
        TempText := TextToEncode;
        TempText := DelChr(TempText, '=', ' '); // Remove spaces
        TempText := ReplaceStr(TempText, ' ', '+');
        exit(TempText);
    end;

    local procedure ReplaceStr(Source: Text; OldValue: Text; NewValue: Text): Text
    var
        Pos: Integer;
    begin
        while true do begin
            Pos := StrPos(Source, OldValue);
            if Pos = 0 then
                exit(Source);
            Source := CopyStr(Source, 1, Pos - 1) + NewValue + CopyStr(Source, Pos + StrLen(OldValue));
        end;
    end;

    local procedure FormatAddress(StreetAddress: Text; City: Text; PostCode: Text; CountryCode: Text): Text
    var
        FormattedAddress: Text;
    begin
        FormattedAddress := '';

        if StreetAddress <> '' then
            FormattedAddress += StreetAddress;

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
}
