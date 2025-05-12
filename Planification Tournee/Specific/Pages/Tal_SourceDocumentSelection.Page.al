page 50121 "Source Document Selection"
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
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the type of document.';
                    Editable = false;
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document number.';
                    Editable = false;
                }

                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    Caption = 'Account Type';
                    ToolTip = 'Specifies the type of account (Customer or Vendor).';
                    Editable = false;
                }

                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Account No.';
                    ToolTip = 'Specifies the account number.';
                    Editable = false;
                }

                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                    ToolTip = 'Specifies the account name.';
                    Editable = false;
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    ToolTip = 'Specifies the location code.';
                    Editable = false;
                }

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the document date.';
                    Editable = false;
                }

                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Date';
                    ToolTip = 'Specifies the requested delivery date.';
                    Editable = false;
                }

                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Caption = 'Priority';
                    ToolTip = 'Specifies the priority level of the document.';
                    Editable = false;
                }

                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    ToolTip = 'Specifies the total quantity in the document.';
                    Editable = false;
                }

                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Total Weight';
                    ToolTip = 'Specifies the total weight of items in the document.';
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

                // Calculate total quantity and weight
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += SalesLine.Quantity;
                        if SalesLine.Type = SalesLine.Type::Item then begin
                            // Weight calculation would need item information
                            // This is simplified
                        end;
                    until SalesLine.Next() = 0;

                Rec.Insert();
            until SalesHeader.Next() = 0;
    end;

    local procedure LoadPurchaseOrders()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
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

                // Calculate total quantity and weight
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                if PurchLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += PurchLine.Quantity;
                    // Weight calculation simplified
                    until PurchLine.Next() = 0;

                Rec.Insert();
            until PurchHeader.Next() = 0;
    end;

    local procedure LoadTransferOrders()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
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

                // Calculate total quantity and weight
                TransferLine.SetRange("Document No.", TransferHeader."No.");
                if TransferLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += TransferLine.Quantity;
                    // Weight calculation simplified
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