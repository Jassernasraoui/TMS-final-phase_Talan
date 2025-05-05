page 50100 "Planning Lines"
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
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Logistic Tour No."; rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; rec."Description 2")
                {
                    ApplicationArea = All;
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
                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Project Code"; rec."Project Code")
                {
                    ApplicationArea = All;
                }
                field("Department Code"; rec."Department Code")
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Inventory Posting Group"; rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("Planned Date"; rec."Planned Date")
                {
                    ApplicationArea = All;
                }
                field("Expected Shipment Date"; rec."Expected Shipment Date")
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
                field("System ID"; rec."System ID")
                {
                    ApplicationArea = All;
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
            
            
    }
    
    }
    
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
            PlanningLine.Description := SalesLine.Description;
            PlanningLine."Description 2" := SalesLine."Description 2";
            PlanningLine.Quantity := SalesLine.Quantity;
            PlanningLine."Quantity (Base)" := SalesLine."Quantity (Base)";
            PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
            PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
            PlanningLine."Variant Code" := SalesLine."Variant Code";
            
            // Vous pouvez ajouter d'autres champs selon votre structure de données
            PlanningLine."Planned Date" := WorkDate();
            
            PlanningLine.Insert(true);
            LineNo += 10000;
        until SalesLine.Next() = 0;
        
        Message('Les lignes de vente ont été extraites avec succès.');
    end;
}
//
// #################################################
// #######################################################
// #################################################

// page 50100 "Planning Lines ListPart"
// {
//     PageType = ListPart;
//     SourceTable = "Planning Line";
//     ApplicationArea = All;
//     // SourceTableView = where("Document Type" = filter(Invoice));


//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {
//                 field("Type"; rec."Type")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Line No."; rec."Line No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Logistic Tour No."; rec."Logistic Tour No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Source ID"; rec."Source ID")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Item No."; rec."Item No.")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Variant Code"; rec."Variant Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Description; rec.Description)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Description 2"; rec."Description 2")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Quantity; rec.Quantity)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Quantity (Base)"; rec."Quantity (Base)")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Qty. per Unit of Measure"; rec."Qty. per Unit of Measure")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Unit of Measure Code"; rec."Unit of Measure Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Qty. Rounding Precision"; rec."Qty. Rounding Precision")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Qty. Rounding Precision (Base)"; rec."Qty. Rounding Precision (Base)")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Unit Volume"; rec."Unit Volume")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Gross Weight"; rec."Gross Weight")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Net Weight"; rec."Net Weight")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field(Status; rec.Status)
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Project Code"; rec."Project Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Department Code"; rec."Department Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Gen. Prod. Posting Group"; rec."Gen. Prod. Posting Group")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Inventory Posting Group"; rec."Inventory Posting Group")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Item Category Code"; rec."Item Category Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Dimension Set ID"; rec."Dimension Set ID")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Planned Date"; rec."Planned Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Expected Shipment Date"; rec."Expected Shipment Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Expected Receipt Date"; rec."Expected Receipt Date")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Created At"; rec."Created At")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Created By"; rec."Created By")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Modified At"; rec."Modified At")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Modified By"; rec."Modified By")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("System ID"; rec."System ID")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
//     actions
//     {
//       area(processing)
//       {

//         group("&Line")
//             {
//                 Caption = '&Line';
//                 Image = Line;
//                 group("F&unctions")
//                 {
//                     Caption = 'F&unctions';
//                     Image = "Action";
//                     action(GetPrice)
//                     {
//                         AccessByPermission = TableData "Sales Price Access" = R;
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Get &Price';
//                         Ellipsis = true;
//                         Image = Price;
//                         // Visible = ExtendedPriceEnabled;
//                         ToolTip = 'Insert the lowest possible price in the Unit Price field according to any special price that you have set up.';

//                         // trigger OnAction()
//                         // begin
//                         //     ShowPrices()
//                         // end;
//                     }
//                     action(GetLineDiscount)
//                     {
//                         AccessByPermission = TableData "Sales Discount Access" = R;
//                         ApplicationArea = Basic, Suite;
//                         Caption = 'Get Li&ne Discount';
//                         Ellipsis = true;
//                         Image = LineDiscount;
//                         // Visible = ExtendedPriceEnabled;
//                         ToolTip = 'Insert the best possible discount in the Line Discount field according to any special discounts that you have set up.';

//                         // trigger OnAction()
//                         // begin
//                         //     ShowLineDisc()
//                         // end;
//                     }
//                     // action("E&xplode BOM")
//                     // {
//                     //     AccessByPermission = TableData "BOM Component" = R;
//                     //     ApplicationArea = Suite;
//                     //     Caption = 'E&xplode BOM';
//                     //     Image = ExplodeBOM;
//                     //     Enabled = Rec.Type = Rec.Type::Item;
//                     //     ToolTip = 'Add a line for each component on the bill of materials for the selected item. For example, this is useful for selling the parent item as a kit. CAUTION: The line for the parent item will be deleted and only its description will display. To undo this action, delete the component lines and add a line for the parent item again. This action is available only for lines that contain an item.';

//                     //     trigger OnAction()
//                     //     begin
//                     //         ExplodeBOM();
//                     //     end;
//                     // }
//                     action(InsertExtTexts)
//                     {
//                         AccessByPermission = TableData "Extended Text Header" = R;
//                         ApplicationArea = Suite;
//                         Caption = 'Insert &Ext. Texts';
//                         Image = Text;
//                         Scope = Repeater;
//                         ToolTip = 'Insert the extended item description that is set up for the item that is being processed on the line.';

//                         trigger OnAction()
//                         begin
//                             InsertExtendedText(true);
//                         end;
//                     }
//                     action(GetShipmentLines)
//                     {
//                         AccessByPermission = TableData "Sales Shipment Header" = R;
//                         ApplicationArea = Suite;
//                         Caption = 'Get &Shipment Lines';
//                         Ellipsis = true;
//                         Image = Shipment;
//                         ToolTip = 'Select multiple shipments to the same customer because you want to combine them on one invoice.';

//                         trigger OnAction()
//                         begin
//                             GetShipment();
//                             RedistributeTotalsOnAfterValidate();
//                         end;
//                     }
//                     action(GetJobPlanningLines)
//                     {
//                         AccessByPermission = TableData "Job Planning Line" = R;
//                         ApplicationArea = Jobs;
//                         Caption = 'Get &Project Planning Lines';
//                         Ellipsis = true;
//                         Image = JobLines;
//                         ToolTip = 'Select multiple planning lines to the same customer because you want to combine them on one invoice.';

//                         trigger OnAction()
//                         begin
//                             GetJobLines();
//                             RedistributeTotalsOnAfterValidate();
//                         end;
//                     }
//                 }
// //                 group("Item Availability by")
// //                 {
// //                     Caption = 'Item Availability by';
// //                     Image = ItemAvailability;
// //                     // Enabled = Rec.Type 
// //                     // action("Event")
// //                     // {
// //                     //     ApplicationArea = Basic, Suite;
// //                     //     Caption = 'Event';
// //                     //     Image = "Event";
// //                     //     ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

// //                     //     trigger OnAction()
// //                     //     begin
// //                     //         SalesAvailabilityMgt.ShowItemAvailabilityFromSalesLine(Rec, "Item Availability Type"::Period);
// //                     //     end;
// //                     // }
// //                     // action(Period)
// //                     // {
// //                     //     ApplicationArea = Basic, Suite;
// //                     //     Caption = 'Period';
// //                     //     Image = Period;
// //                     //     ToolTip = 'Show the projected quantity of the item over time according to time periods, such as day, week, or month.';

// //                     //     trigger OnAction()
// //                     //     begin
// //                     //         SalesAvailabilityMgt.ShowItemAvailabilityFromSalesLine(Rec, "Item Availability Type"::Period);
// //                     //     end;
// //                     // }
// //                     // action(Variant)
// //                     // {
// //                     //     ApplicationArea = Planning;
// //                     //     Caption = 'Variant';
// //                     //     Image = ItemVariant;
// //                     //     ToolTip = 'View or edit the item''s variants. Instead of setting up each color of an item as a separate item, you can set up the various colors as variants of the item.';

// //                     //     trigger OnAction()
// //                     //     begin
// //                     //         SalesAvailabilityMgt.ShowItemAvailabilityFromSalesLine(Rec, "Item Availability Type"::Variant);
// //                     //     end;
// //                     // }
// //                     // action(Location)
// //                     // {
// //                     //     AccessByPermission = TableData Location = R;
// //                     //     ApplicationArea = Location;
// //                     //     Caption = 'Location';
// //                     //     Image = Warehouse;
// //                     //     ToolTip = 'View the actual and projected quantity of the item per location.';

// //                     //     trigger OnAction()
// //                     //     begin
// //                     //         SalesAvailabilityMgt.ShowItemAvailabilityFromSalesLine(Rec, "Item Availability Type"::Location);
// //                     //     end;
// //                     // }
// //                     // action(Lot)
// //                     // {
// //                     //     ApplicationArea = ItemTracking;
// //                     //     Caption = 'Lot';
// //                     //     Image = LotInfo;
// //                     //     RunObject = Page "Item Availability by Lot No.";
// //                     //     RunPageLink = "No." = field("No."),
// //                     //         "Location Filter" = field("Location Code"),
// //                     //         "Variant Filter" = field("Variant Code");
// //                     //     ToolTip = 'View the current and projected quantity of the item in each lot.';
// //                     // }
// //                 //     action("BOM Level")
// //                 //     {
// //                 //         AccessByPermission = TableData "BOM Buffer" = R;
// //                 //         ApplicationArea = Assembly;
// //                 //         Caption = 'BOM Level';
// //                 //         Image = BOMLevel;
// //                 //         ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

// //                 //         trigger OnAction()
// //                 //         begin
// //                 //             SalesAvailabilityMgt.ShowItemAvailabilityFromSalesLine(Rec, "Item Availability Type"::BOM);
// //                 //         end;
// //                 //     }
// //                 // }
                
// // //                 group("Related Information")
// // //                 {
// // //                     Caption = 'Related Information';
// // //                     action(Dimensions)
// // //                     {
// // //                         AccessByPermission = TableData Dimension = R;
// // //                         ApplicationArea = Dimensions;
// // //                         Caption = 'Dimensions';
// // //                         Image = Dimensions;
// // //                         Scope = Repeater;
// // //                         ShortCutKey = 'Alt+D';
// // //                         ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

// // //                         trigger OnAction()
// // //                         begin
// // //                             Rec.ShowDimensions();
// // //                         end;
// // //                     }
// // //                     action("Co&mments")
// // //                     {
// // //                         ApplicationArea = Comments;
// // //                         Caption = 'Co&mments';
// // //                         Image = ViewComments;
// // //                         ToolTip = 'View or add comments for the record.';

// // //                         trigger OnAction()
// // //                         begin
// // //                             Rec.ShowLineComments();
// // //                         end;
// // //                     }
// // //                     action("Item Charge &Assignment")
// // //                     {
// // //                         AccessByPermission = TableData "Item Charge" = R;
// // //                         ApplicationArea = ItemCharges;
// // //                         Caption = 'Item Charge &Assignment';
// // //                         Enabled = Rec.Type = Rec.Type::"Charge (Item)";
// // //                         Image = ItemCosts;
// // //                         ToolTip = 'Record additional direct costs, for example for freight. This action is available only for Charge (Item) line types.';

// // //                         trigger OnAction()
// // //                         begin
// // //                             Rec.ShowItemChargeAssgnt();
// // //                             SetItemChargeFieldsStyle();
// // //                         end;
// // //                     }
// // //                     action("Item &Tracking Lines")
// // //                     {
// // //                         ApplicationArea = ItemTracking;
// // //                         Caption = 'Item &Tracking Lines';
// // //                         Image = ItemTrackingLines;
// // //                         ShortCutKey = 'Ctrl+Alt+I';
// // //                         Enabled = Rec.Type = Rec.Type::Item;
// // //                         ToolTip = 'View or edit serial, lot and package numbers for the selected item. This action is available only for lines that contain an item.';

// // //                         trigger OnAction()
// // //                         begin
// // //                             Rec.OpenItemTrackingLines();
// // //                         end;
// // //                     }
// // //                     action(DocAttach)
// // //                     {
// // //                         ApplicationArea = All;
// // //                         Caption = 'Attachments';
// // //                         Image = Attach;
// // //                         ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

// // //                         trigger OnAction()
// // //                         var
// // //                             DocumentAttachmentDetails: Page "Document Attachment Details";
// // //                             RecRef: RecordRef;
// // //                         begin
// // //                             RecRef.GetTable(Rec);
// // //                             DocumentAttachmentDetails.OpenForRecRef(RecRef);
// // //                             DocumentAttachmentDetails.RunModal();
// // //                         end;
// // //                     }
// // //                     action(DeferralSchedule)
// // //                     {
// // //                         ApplicationArea = Suite;
// // //                         Caption = 'Deferral Schedule';
// // //                         Enabled = Rec."Deferral Code" <> '';
// // //                         Image = PaymentPeriod;
// // //                         ToolTip = 'View or edit the deferral schedule that governs how revenue made with this sales document is deferred to different accounting periods when the document is posted.';

// // //                         trigger OnAction()
// // //                         begin
// // //                             Rec.ShowDeferralSchedule();
// // //                         end;
// // //                     }
// // //                     action(RedistributeAccAllocations)
// // //                     {
// // //                         ApplicationArea = All;
// // //                         Caption = 'Redistribute Account Allocations';
// // //                         Image = EditList;
// // // #pragma warning disable AA0219
// // //                         ToolTip = 'Use this action to redistribute the account allocations for this line.';
// // // #pragma warning restore AA0219

// // //                         trigger OnAction()
// // //                         var
// // //                             AllocAccManualOverride: Page "Redistribute Acc. Allocations";
// // //                         begin
// // //                             if ((Rec."Type" <> Rec."Type"::"Allocation Account") and (Rec."Selected Alloc. Account No." = '')) then
// // //                                 Error(ActionOnlyAllowedForAllocationAccountsErr);

// // //                             AllocAccManualOverride.SetParentSystemId(Rec.SystemId);
// // //                             AllocAccManualOverride.SetParentTableId(Database::"Sales Line");
// // //                             AllocAccManualOverride.RunModal();
// // //                         end;
// // //                     }
// // //                     action(ReplaceAllocationAccountWithLines)
// // //                     {
// // //                         ApplicationArea = All;
// // //                         Caption = 'Generate lines from Allocation Account Line';
// // //                         Image = CreateLinesFromJob;
// // // #pragma warning disable AA0219
// // //                         ToolTip = 'Use this action to replace the Allocation Account line with the actual lines that would be generated from the line itself.';
// // // #pragma warning restore AA0219

// // //                         trigger OnAction()
// // //                         var
// // //                             SalesAllocAccMgt: Codeunit "Sales Alloc. Acc. Mgt.";
// // //                         begin
// // //                             if ((Rec."Type" <> Rec."Type"::"Allocation Account") and (Rec."Selected Alloc. Account No." = '')) then
// // //                                 Error(ActionOnlyAllowedForAllocationAccountsErr);

// // //                             SalesAllocAccMgt.CreateLinesFromAllocationAccountLine(Rec);
// // //                             Rec.Delete();
// // //                             CurrPage.Update(false);
// // //                         end;
// // //                     }
// // //                 }
                
// //             }
//       }
      
//     }
//     }
    
//     protected var
//         Currency: Record Currency;
//         TotalSalesHeader: Record "Sales Header";
//         TotalSalesLine: Record "Sales Line";
//         DocumentTotals: Codeunit "Document Totals";
//         ShortcutDimCode: array[8] of Code[20];
//         DimVisible1: Boolean;
//         DimVisible2: Boolean;
//         DimVisible3: Boolean;
//         DimVisible4: Boolean;
//         DimVisible5: Boolean;
//         DimVisible6: Boolean;
//         DimVisible7: Boolean;
//         DimVisible8: Boolean;
//         InvDiscAmountEditable: Boolean;
//         InvoiceDiscountAmount: Decimal;
//         InvoiceDiscountPct: Decimal;
//         IsBlankNumber: Boolean;
//         BackgroundErrorCheck: Boolean;
//         ShowAllLinesEnabled: Boolean;
//         IsCommentLine: Boolean;
//         SuppressTotals: Boolean;
//         ItemReferenceVisible: Boolean;
//         LocationCodeVisible: Boolean;
//         UnitofMeasureCodeIsChangeable: Boolean;
//         VATAmount: Decimal;
//     // procedure ShowPrices()
//     // begin
//     //     Rec.PickPrice();
//     // end;

//     // procedure ShowLineDisc()
//     // begin
//     //     Rec.PickDiscount();
//     // end;
//     procedure GetShipment()
//     begin
//         CODEUNIT.Run(CODEUNIT::"Sales-Get Shipment", Rec);
//     end;
//      procedure InsertExtendedText(Unconditionally: Boolean)
//     begin
//         OnBeforeInsertExtendedText(Rec);
//         if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
//             CurrPage.SaveRecord();
//             Commit();
//             TransferExtendedText.InsertSalesExtText(Rec);
//         end;
//         if TransferExtendedText.MakeUpdate() then
//             UpdatePage(true);
//     end;
//      procedure RedistributeTotalsOnAfterValidate()
//     var
//         SalesHeader: Record "Sales Header";
//     begin
//         if SuppressTotals then
//             exit;

//         CurrPage.SaveRecord();

//         SalesHeader.Get(Rec."Source ID", Rec."Item No.");
//         DocumentTotals.SalesRedistributeInvoiceDiscountAmounts(Rec, VATAmount, TotalSalesLine);
//         CurrPage.Update(false);
//     end;
//     local procedure GetJobLines()
//     begin
//         Codeunit.Run(Codeunit::"Job-Process Plan. Lines", Rec);
//     end;
//     var
//         SalesSetup: Record "Sales & Receivables Setup";
//         TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
//         ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
//         TransferExtendedText: Codeunit "Transfer Extended Text";
//         SalesAvailabilityMgt: Codeunit "Sales Availability Mgt.";
//         SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";
//         AmountWithDiscountAllowed: Decimal;
//         UpdateAllowedVar: Boolean;
// #pragma warning disable AA0074
//         Text000: Label 'Unable to run this function while in View mode.';
// #pragma warning restore AA0074
//         VariantCodeMandatory: Boolean;
//         CurrPageIsEditable: Boolean;
//         IsSaaSExcelAddinEnabled: Boolean;
//         ExtendedPriceEnabled: Boolean;
//         ItemChargeStyleExpression: Text;
//         TypeAsText: Text[30];
//         TypeAsTextFieldVisible: Boolean;
//         UseAllocationAccountNumber: Boolean;
//         ActionOnlyAllowedForAllocationAccountsErr: Label 'This action is only available for lines that have Allocation Account set as Type.';
//         ExcelFileNameTxt: Label 'Sales Invoice %1 - Lines', Comment = '%1 = document number, ex. 10000';
        
//         [IntegrationEvent(false, false)]
//     local procedure OnBeforeInsertExtendedText(var SalesLine: Record "Sales Line")
//     begin
//     end;
//     procedure UpdatePage(SetSaveRecord: Boolean)
//     begin
//         CurrPage.Update(SetSaveRecord);
//     end;


    
// }

            
        
//         //         action(GetSalesLines)
//         // {
//         //     AccessByPermission = TableData "Sales Line" = R;
//         //     ApplicationArea = Suite;
//         //     Caption = 'Récupérer les &lignes de vente';
//         //     Ellipsis = true;
//         //     Image = Sales;
//         //     ToolTip = 'Sélectionner plusieurs lignes de vente pour les ajouter à la planification du tour.';

//         //     trigger OnAction()
//         //     begin
//         //         GetSalesLines();
//         //         RedistributeTotalsOnAfterValidate();
//         //     end;
//         // }
//         // procedure GetSalesLines()
//         // var
//         //     SalesLine: Record "Sales Line";
//         //     SelectionFilterManagement: Codeunit SelectionFilterManagement;
//         //     SalesLineRecordRef: RecordRef;
//         // begin
//         //     SalesLine.Reset();
//         //     SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
//         //     // Ajoutez d'autres filtres selon vos besoins

//         //     SalesLineRecordRef.GetTable(SalesLine);
//         //     SalesLineRecordRef.SetView(SalesLine.GetView());
//         //     z
//         //     if PAGE.RunModal(PAGE::"Sales Lines", SalesLine) = ACTION::LookupOK then begin
//         //         // Le code pour traiter les lignes sélectionnées
//         //         InsertSelectedSalesLines(SalesLine);
//         //     end;
//         // end;

//         // procedure InsertSelectedSalesLines(var SalesLine: Record "Sales Line")
//         // var
//         //     TourPlanificationLine: Record "Planning Line"; // Remplacez par le nom réel de votre table
//         // begin
//         //     if SalesLine.FindSet() then
//         //         repeat
//         //             // Créer une nouvelle ligne de planification basée sur la ligne de vente
//         //             TourPlanificationLine.Init();
//         //             TourPlanificationLine."Document No." := Rec."Document No."; // Adaptez selon vos champs
//         //             TourPlanificationLine."Line No." := GetNextLineNo();
//         //             TourPlanificationLine."Sales Document No." := SalesLine."Document No.";
//         //             TourPlanificationLine."Sales Line No." := SalesLine."Line No.";
//         //             // Copiez d'autres champs selon vos besoins
//         //             TourPlanificationLine.Insert(true);
//         //         until SalesLine.Next() = 0;
//         // end;

//         // procedure GetNextLineNo(): Integer
//         // var
//         //     TourPlanificationLine: Record "Planning Line"; // Remplacez par le nom réel de votre table
//         // begin
//         //     TourPlanificationLine.SetRange("Document No.", Rec."Document No.");
//         //     if TourPlanificationLine.FindLast() then
//         //         exit(TourPlanificationLine."Line No." + 10000)
//         //     else
//         //         exit(10000);
//         // end;
//         // area(processing)
//         // {
//         //     group("Fetch Planning Lines")
//         //     {
//         //         action("Get Sales Lines")
//         //         {
//         //             ApplicationArea = All;
//         //             Caption = 'Get Sales Lines';
//         //             Image = Import;

//         //             trigger OnAction()
//         //             var
//         //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
//         //             begin
//         //                 PlanningLineFetcher.FetchSalesLines(Rec."Document No.");
//         //             end;
//         //         }

//         //         action("Get Purchase Lines")
//         //         {
//         //             ApplicationArea = All;
//         //             Caption = 'Get Purchase Lines';
//         //             Image = Import;

//         //             trigger OnAction()
//         //             var
//         //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
//         //             begin
//         //                 PlanningLineFetcher.FetchPurchaseLines(Rec."Document No.");
//         //             end;
//         //         }

//         //         action("Get Transfer Lines")
//         //         {
//         //             ApplicationArea = All;
//         //             Caption = 'Get Transfer Lines';
//         //             Image = Import;

//         //             trigger OnAction()
//         //             var
//         //                 PlanningLineFetcher: Codeunit "Planning Line Fetcher";
//         //             begin
//         //                 PlanningLineFetcher.FetchTransferLines(Rec."Document No.");
//         //             end;
//         //         }
//         //     }
//         // }
   

