page 77008 "Source Document Selection"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Planning Document Buffer";
    SourceTableTemporary = true;
    Caption = 'Source Document Selection';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(TourInfo)
            {
                Caption = 'Tour Information';

                field(TourNumberDisplay; CurrentTourNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour Number';
                    Style = StrongAccent;
                    StyleExpr = CurrentTourNoStyle;
                    ToolTip = 'Specifies the tour number to which documents will be added.';
                }

                field(TourStartDate; TourHeader."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour Start Date';
                    ToolTip = 'Specifies the start date of the tour.';
                }

                field(TourEndDate; TourHeader."End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Tour End Date';
                    ToolTip = 'Specifies the end date of the tour.';
                }
            }
            group(FilterOptions)
            {
                Caption = 'Filter Options';

                field(DocumentTypeFilter; DocumentTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    OptionCaption = 'All,Sales Orders,Purchase Orders,Transfer Orders';
                    ToolTip = 'Select the type of documents to display.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(DateFilterStart; DateFilterStart)
                {
                    ApplicationArea = All;
                    Caption = 'Date From';
                    ToolTip = 'Specifies the starting date for the filter.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(DateFilterEnd; DateFilterEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Date To';
                    ToolTip = 'Specifies the ending date for the filter.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(CustomerNoFilter; CustomerNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the customer number to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(VendorNoFilter; VendorNoFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    TableRelation = Vendor;
                    ToolTip = 'Specifies the vendor number to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(LocationCodeFilter; LocationCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location;
                    ToolTip = 'Specifies the location code to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(PriorityFilter; PriorityFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Priority';
                    OptionCaption = 'All,Low,Normal,High,Critical';
                    ToolTip = 'Specifies the priority level to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }
            }

            repeater(DocumentList)
            {
                Caption = 'Documents';

                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    ToolTip = 'Specifies whether the document is selected for inclusion in the tour.';
                    Editable = true;
                }

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of document.';
                    Editable = false;
                }

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line No.';
                    ToolTip = 'Specifies the line number.';
                    Editable = false;
                }

                field("Tour No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
                    Caption = 'Logistic Tour No.';
                    ToolTip = 'Specifies the tour number.';
                    Editable = false;
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Source ID';
                    ToolTip = 'Specifies the document number.';
                    Editable = false;
                }

                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor No.';
                    ToolTip = 'Specifies the account number.';
                    Editable = false;
                }

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Caption = 'Variant Code';
                    ToolTip = 'Specifies the variant code.';
                    Editable = false;
                }

                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor Name';
                    ToolTip = 'Specifies the account name.';
                    Editable = false;
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Caption = 'Description 2';
                    ToolTip = 'Specifies an additional description.';
                    Editable = false;
                }

                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the total quantity in the document.';
                    Editable = false;
                }

                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity (Base)';
                    ToolTip = 'Specifies the quantity in base unit of measure.';
                    Editable = false;
                }

                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. per Unit of Measure';
                    ToolTip = 'Specifies the quantity per unit of measure.';
                    Editable = false;
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Caption = 'Unit of Measure Code';
                    ToolTip = 'Specifies the unit of measure code.';
                    Editable = false;
                }

                field("Qty. Rounding Precision"; Rec."Qty. Rounding Precision")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. Rounding Precision';
                    ToolTip = 'Specifies the quantity rounding precision.';
                    Editable = false;
                }

                field("Qty. Rounding Precision (Base)"; Rec."Qty. Rounding Precision (Base)")
                {
                    ApplicationArea = All;
                    Caption = 'Qty. Rounding Precision (Base)';
                    ToolTip = 'Specifies the quantity rounding precision in base unit.';
                    Editable = false;
                }

                field("Unit Volume"; Rec."Unit Volume")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Volume';
                    ToolTip = 'Specifies the unit volume.';
                    Editable = false;
                }

                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Gross Weight';
                    ToolTip = 'Specifies the gross weight.';
                    Editable = false;
                }

                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Net Weight';
                    ToolTip = 'Specifies the net weight.';
                    Editable = false;
                }

                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 1 Code';
                    ToolTip = 'Specifies the global dimension 1 code.';
                    Editable = false;
                }

                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 2 Code';
                    ToolTip = 'Specifies the global dimension 2 code.';
                    Editable = false;
                }

                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                    Caption = 'Dimension Set ID';
                    ToolTip = 'Specifies the dimension set ID.';
                    Editable = false;
                }

                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'Planned Date';
                    ToolTip = 'Specifies the requested delivery date.';
                    Editable = false;
                }

                field("Expected Shipment Date"; Rec."Expected Shipment Date")
                {
                    ApplicationArea = All;
                    Caption = 'Expected Shipment Date';
                    ToolTip = 'Specifies the expected shipment date.';
                    Editable = false;
                }

                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    Caption = 'Expected Receipt Date';
                    ToolTip = 'Specifies the expected receipt date.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectAll)
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = SelectAll;
                ToolTip = 'Selects all displayed documents.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SelectAllDocuments(true);
                end;
            }

            action(UnselectAll)
            {
                ApplicationArea = All;
                Caption = 'Unselect All';
                Image = CancelLine;
                ToolTip = 'Unselects all displayed documents.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SelectAllDocuments(false);
                end;
            }

            action(AddToTour)
            {
                ApplicationArea = All;
                Caption = 'Add to Tour';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add the selected documents to the tour.';

                trigger OnAction()
                begin
                    AddSelectedDocumentsToTour();
                end;
            }

            action(RefreshList)
            {
                ApplicationArea = All;
                Caption = 'Refresh List';
                Image = Refresh;
                ToolTip = 'Refreshes the list of available documents.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    LoadDocuments();
                end;
            }
        }
    }

    var
        TourHeader: Record "Planification Header";
        DocumentTypeFilter: Option All,"Sales Orders","Purchase Orders","Transfer Orders";
        DateFilterStart: Date;
        DateFilterEnd: Date;
        CustomerNoFilter: Code[20];
        VendorNoFilter: Code[20];
        LocationCodeFilter: Code[20];
        PriorityFilter: Option All,Low,Normal,High,Critical;
        ActionOK: Boolean;
        CurrentTourNo: Code[20];
        CurrentTourNoStyle: Boolean;

    trigger OnOpenPage()
    begin
        ActionOK := false;

        // Set default date filters if not already set
        if DateFilterStart = 0D then
            DateFilterStart := WorkDate();

        if DateFilterEnd = 0D then
            DateFilterEnd := CalcDate('<+1M>', WorkDate());

        // Load available documents
        LoadDocuments();
    end;

    procedure SetTourHeader(TourHeaderRec: Record "Planification Header")
    begin
        // Store the tour header
        TourHeader := TourHeaderRec;

        // Set the global tour number variable directly
        CurrentTourNo := TourHeaderRec."Logistic Tour No.";
        CurrentTourNoStyle := true;

        // Set default date filters if available
        if TourHeader."Start Date" <> 0D then
            DateFilterStart := TourHeader."Start Date";

        if TourHeader."End Date" <> 0D then
            DateFilterEnd := TourHeader."End Date";

        // Load documents with this tour number
        LoadDocuments();
    end;

    local procedure LoadDocuments()
    begin
        ActionOK := false;
        Rec.Reset();
        Rec.DeleteAll();

        // Load all document types
        LoadSalesOrders();
        LoadPurchaseOrders();
        LoadTransferOrders();

        // Set Tour No. on all records (in case it wasn't set during loading)
        if CurrentTourNo <> '' then begin
            Rec.Reset();
            if Rec.FindSet() then
                repeat
                    Rec."Tour No." := CurrentTourNo;
                    Rec.Modify();
                until Rec.Next() = 0;
        end;

        // Apply filters
        UpdateFilters();
    end;

    local procedure LoadSalesOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter(Status, '%1|%2', SalesHeader.Status::Open, SalesHeader.Status::Released);

        if SalesHeader.FindSet() then
            repeat
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                Rec."Line No." := LineNo;
                Rec."Document Type" := Rec."Document Type"::"Sales Order";
                Rec."Document No." := SalesHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Customer;
                Rec."Account No." := SalesHeader."Sell-to Customer No.";
                Rec."Account Name" := SalesHeader."Sell-to Customer Name";
                Rec."Location Code" := SalesHeader."Location Code";
                Rec."Document Date" := SalesHeader."Document Date";
                Rec."Delivery Date" := SalesHeader."Requested Delivery Date";
                // Explicitly set the tour number on each record
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := Rec.Priority::Normal;

                // New fields
                Rec."Global Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                Rec."Global Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                Rec."Dimension Set ID" := SalesHeader."Dimension Set ID";
                Rec."Expected Shipment Date" := SalesHeader."Shipment Date";

                // Calculate total quantity and weight
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += SalesLine.Quantity;
                        Rec."Quantity (Base)" += SalesLine."Quantity (Base)";

                        if SalesLine.Type = SalesLine.Type::Item then begin
                            // Get additional info from the item
                            if Item.Get(SalesLine."No.") then begin
                                Rec."Unit Volume" := Item."Unit Volume";
                                Rec."Gross Weight" := Item."Gross Weight";
                                Rec."Net Weight" := Item."Net Weight";
                            end;

                            Rec."Variant Code" := SalesLine."Variant Code";
                            Rec."Description 2" := SalesLine."Description 2";
                            Rec."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                            Rec."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";

                            // These fields might not be directly available in sales line
                            // Assign default values if needed
                            Rec."Qty. Rounding Precision" := 0.00001;
                            Rec."Qty. Rounding Precision (Base)" := 0.00001;
                        end;
                    until SalesLine.Next() = 0;

                Rec.Insert();
            until SalesHeader.Next() = 0;
    end;

    local procedure LoadPurchaseOrders()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        if Rec.FindLast() then
            LineNo := Rec."Line No.";

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetFilter(Status, '%1|%2', PurchHeader.Status::Open, PurchHeader.Status::Released);

        if PurchHeader.FindSet() then
            repeat
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                Rec."Line No." := LineNo;
                Rec."Document Type" := Rec."Document Type"::"Purchase Order";
                Rec."Document No." := PurchHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Vendor;
                Rec."Account No." := PurchHeader."Buy-from Vendor No.";
                Rec."Account Name" := PurchHeader."Buy-from Vendor Name";
                Rec."Location Code" := PurchHeader."Location Code";
                Rec."Document Date" := PurchHeader."Document Date";
                Rec."Delivery Date" := PurchHeader."Expected Receipt Date";
                // Explicitly set the tour number on each record
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := Rec.Priority::Normal;

                // New fields
                Rec."Global Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
                Rec."Global Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
                Rec."Dimension Set ID" := PurchHeader."Dimension Set ID";
                Rec."Expected Receipt Date" := PurchHeader."Expected Receipt Date";

                // Calculate total quantity and weight
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                if PurchLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += PurchLine.Quantity;
                        Rec."Quantity (Base)" += PurchLine."Quantity (Base)";

                        if PurchLine.Type = PurchLine.Type::Item then begin
                            // Get additional info from the item
                            if Item.Get(PurchLine."No.") then begin
                                Rec."Unit Volume" := Item."Unit Volume";
                                Rec."Gross Weight" := Item."Gross Weight";
                                Rec."Net Weight" := Item."Net Weight";
                            end;

                            Rec."Variant Code" := PurchLine."Variant Code";
                            Rec."Description 2" := PurchLine."Description 2";
                            Rec."Unit of Measure Code" := PurchLine."Unit of Measure Code";
                            Rec."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";

                            // These fields might not be directly available in purchase line
                            // Assign default values if needed
                            Rec."Qty. Rounding Precision" := 0.00001;
                            Rec."Qty. Rounding Precision (Base)" := 0.00001;
                        end;
                    until PurchLine.Next() = 0;

                Rec.Insert();
            until PurchHeader.Next() = 0;
    end;

    local procedure LoadTransferOrders()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        if Rec.FindLast() then
            LineNo := Rec."Line No.";

        TransferHeader.SetFilter(Status, '%1|%2', TransferHeader.Status::Open, TransferHeader.Status::Released);

        if TransferHeader.FindSet() then
            repeat
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                Rec."Line No." := LineNo;
                Rec."Document Type" := Rec."Document Type"::"Transfer Order";
                Rec."Document No." := TransferHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Location;
                Rec."Account No." := TransferHeader."Transfer-to Code";
                Rec."Account Name" := GetLocationName(TransferHeader."Transfer-to Code");
                Rec."Location Code" := TransferHeader."Transfer-from Code";
                Rec."Document Date" := TransferHeader."Posting Date";
                Rec."Delivery Date" := TransferHeader."Receipt Date";
                // Explicitly set the tour number on each record
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := Rec.Priority::Normal;

                // New fields
                Rec."Expected Shipment Date" := TransferHeader."Shipment Date";
                Rec."Expected Receipt Date" := TransferHeader."Receipt Date";

                // Calculate total quantity and weight
                TransferLine.SetRange("Document No.", TransferHeader."No.");
                if TransferLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += TransferLine.Quantity;
                        Rec."Quantity (Base)" += TransferLine."Quantity (Base)";

                        // Get additional info from the item
                        if Item.Get(TransferLine."Item No.") then begin
                            Rec."Unit Volume" := Item."Unit Volume";
                            Rec."Gross Weight" := Item."Gross Weight";
                            Rec."Net Weight" := Item."Net Weight";

                            // Add dimension information from the item
                            Rec."Global Dimension 1 Code" := Item."Global Dimension 1 Code";
                            Rec."Global Dimension 2 Code" := Item."Global Dimension 2 Code";
                        end;

                        Rec."Variant Code" := TransferLine."Variant Code";
                        Rec."Description 2" := TransferLine."Description 2";
                        Rec."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                        Rec."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                        Rec."Qty. Rounding Precision" := TransferLine."Qty. Rounding Precision";
                        Rec."Qty. Rounding Precision (Base)" := TransferLine."Qty. Rounding Precision (Base)";
                    until TransferLine.Next() = 0;

                Rec.Insert();
            until TransferHeader.Next() = 0;
    end;

    local procedure GetLocationName(LocationCode: Code[10]): Text[100]
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then
            exit(Location.Name);

        exit('');
    end;

    local procedure UpdateFilters()
    begin
        Rec.Reset();

        // Filter by document type
        case DocumentTypeFilter of
            DocumentTypeFilter::"Sales Orders":
                Rec.SetRange("Document Type", Rec."Document Type"::"Sales Order");
            DocumentTypeFilter::"Purchase Orders":
                Rec.SetRange("Document Type", Rec."Document Type"::"Purchase Order");
            DocumentTypeFilter::"Transfer Orders":
                Rec.SetRange("Document Type", Rec."Document Type"::"Transfer Order");
        end;

        // Filter by date range
        if DateFilterStart <> 0D then
            Rec.SetFilter("Delivery Date", '>=%1', DateFilterStart);

        if DateFilterEnd <> 0D then
            Rec.SetFilter("Delivery Date", '<=%1', DateFilterEnd);

        // Filter by customer
        if CustomerNoFilter <> '' then
            Rec.SetFilter("Account No.", CustomerNoFilter);

        // Filter by vendor
        if VendorNoFilter <> '' then
            Rec.SetFilter("Account No.", VendorNoFilter);

        // Filter by location
        if LocationCodeFilter <> '' then
            Rec.SetFilter("Location Code", LocationCodeFilter);

        // Filter by priority
        if PriorityFilter <> PriorityFilter::All then
            Rec.SetRange(Priority, PriorityFilter - 1); // Adjust for option index

        CurrPage.Update(false);
    end;

    local procedure SelectAllDocuments(SelectValue: Boolean)
    begin
        if Rec.FindSet() then
            repeat
                Rec.Selected := SelectValue;
                Rec.Modify();
            until Rec.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure AddSelectedDocumentsToTour()
    var
        TourHeader: Record "Planification Header";
        PlanningLineMgt: Codeunit "Planning Lines Management";
        SelectedCount: Integer;
        AttemptsCount: Integer;
        PlanningLine: Record "Planning Lines";
        CountBefore: Integer;
        CountAfter: Integer;
    begin
        // Verify tour number exists
        if CurrentTourNo = '' then begin
            Error('Tour number is missing. Please save the tour first or select a valid tour.');
            exit;
        end;

        // Get active tour - must find the record
        TourHeader.Reset();
        TourHeader.SetRange("Logistic Tour No.", CurrentTourNo);
        if not TourHeader.FindFirst() then begin
            Error('Cannot find tour with number %1. Please ensure the tour exists.', CurrentTourNo);
            exit;
        end;

        // Get count of planning lines before
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", CurrentTourNo);
        CountBefore := PlanningLine.Count;

        // Count selected documents
        Rec.Reset();
        Rec.SetRange(Selected, true);
        if not Rec.FindSet() then begin
            Message('No documents are selected. Please select at least one document.');
            exit;
        end;

        // Count the selected documents first
        repeat
            AttemptsCount += 1;
        until Rec.Next() = 0;

        // Process documents (need to find records again)
        Rec.Reset();
        Rec.SetRange(Selected, true);
        Rec.FindSet();

        // Process selected documents
        repeat
            // Force the tour number in buffer
            Rec."Tour No." := CurrentTourNo;
            Rec.Modify();

            // Clear any error message before calling
            ClearLastError();

            // Call with the CORRECT tour header record
            PlanningLineMgt.AddDocumentToTour(TourHeader, Rec);

            if GetLastErrorText = '' then
                SelectedCount += 1;
        until Rec.Next() = 0;

        // Get count of planning lines after
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", CurrentTourNo);
        CountAfter := PlanningLine.Count;

        // Final message and close page
        if (SelectedCount > 0) and (CountAfter > CountBefore) then begin
            Message('Successfully added %1 out of %2 selected document(s) to tour %3. Added %4 planning lines.',
                    SelectedCount, AttemptsCount, CurrentTourNo, CountAfter - CountBefore);
            ActionOK := true;
            CurrPage.Close();
        end else if SelectedCount > 0 then begin
            Message('Documents were processed but no planning lines were added. Please check the tour configuration.');
        end else
            Message('No documents were added to the tour. Error: %1', GetLastErrorText);
    end;

    procedure IsActionOK(): Boolean
    begin
        exit(ActionOK);
    end;
}