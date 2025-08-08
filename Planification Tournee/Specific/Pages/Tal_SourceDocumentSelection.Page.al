page 73608 "Source Document Selection"
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

                field(DeliveryAreaFilter; DeliveryAreaFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Area';
                    ToolTip = 'Specifies the delivery area to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(RequestedShipmentDateFilter; RequestedShipmentDateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Filter on Requested Shipment Date';
                    ToolTip = 'Specifies the requested shipment date to filter by.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }

                field(CutoffLogisticsFilter; CutoffLogisticsFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Before Logistics Cutoff';
                    ToolTip = 'Specifies whether to show only documents before the logistics cutoff time.';

                    trigger OnValidate()
                    begin
                        UpdateFilters();
                    end;
                }





            }

            repeater(DocumentList)
            {
                Caption = 'Documents';
                IndentationColumn = Indentation;
                ShowAsTree = true;
                field(SelectionStatus; SelectionStatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Selection Status';
                    ToolTip = 'Displays the current selection status of the document.';
                    Editable = false;
                    StyleExpr = SelectionStatusStyle;
                    Visible = true; // Hide this field since we're using SelectionIndicator
                }
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    ToolTip = 'Specifies whether the document is selected for inclusion in the tour.';
                    Editable = DocumentIsSelectable;

                    StyleExpr = DocumentStyleExpr;

                    trigger OnValidate()
                    begin
                        // If this is a header record, update all its child lines
                        if not Rec."Is Document Line" then begin
                            // Save the current record
                            Rec.Modify();

                            // Find and update all child records
                            UpdateChildLines(Rec."Line No.", Rec.Selected);
                        end;
                    end;
                }

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of document.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = not Rec."Is Document Line";
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Source Document ID';
                    ToolTip = 'Specifies the document number.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = not Rec."Is Document Line";
                }
                field("Source Line No."; Rec."Source Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line No.';
                    ToolTip = 'Specifies the line number from the source document.';
                    Editable = false;
                    Visible = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the item number according to the specified number series.';
                    Editable = false;
                    Visible = true;
                    Style = Strong;
                    StyleExpr = Rec."Is Document Line";
                }

                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor No.';
                    ToolTip = 'Specifies the account number.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = not Rec."Is Document Line";
                }

                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer/Vendor Name';
                    ToolTip = 'Specifies the account name.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = not Rec."Is Document Line";
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description.';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec."Is Document Line";
                }

                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the total quantity in the document.';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec."Is Document Line";
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Caption = 'Unit of Measure Code';
                    ToolTip = 'Specifies the unit of measure code.';
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = Rec."Is Document Line";
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Net Weight';
                    ToolTip = 'Specifies the net weight.';
                    Editable = false;
                }

                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Gross Weight';
                    ToolTip = 'Specifies the gross weight.';
                    Editable = false;
                }
                field("Unit Volume"; Rec."Unit Volume")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Volume';
                    ToolTip = 'Specifies the unit volume.';
                    Editable = false;
                }
                field("Ship-to Address"; rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    Caption = 'Ship-to Address';
                    ToolTip = 'Specifies the ship-to address.';
                    Editable = false;
                }

                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                    Caption = 'Planned Date';
                    ToolTip = 'Specifies the requested delivery date.';
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
        DeliveryAreaFilter: Text[50];
        RequestedShipmentDateFilter: Date;
        CutoffLogisticsFilter: Boolean;
        ActionOK: Boolean;
        CurrentTourNo: Code[20];
        CurrentTourNoStyle: Boolean;
        Indentation: Integer;
        DocumentStyle: Text;
        DocumentStyleExpr: Text;
        DocumentIsSelectable: Boolean;
        SelectionTypeOption: Option None,Full,Partial;
        SelectionTypeStyle: Text;
        SelectionStatusText: Text;
        SelectionStatusStyle: Text;

    // YA JASSER THABBET m3a Bilel//

    // trigger OnOpenPage()
    // begin
    //     ActionOK := false;

    //     // Set default date filters if not already set
    //     if DateFilterStart = 0D then
    //         DateFilterStart := WorkDate();

    //     if DateFilterEnd = 0D then
    //         DateFilterEnd := CalcDate('<+1M>', WorkDate());

    //     // Load available documents
    //     LoadDocuments();
    // end;

    trigger OnAfterGetRecord()
    var
        PlanningLine: Record "Planning Lines";
        DocBuffer: Record "Planning Document Buffer";
        AllChildLinesSelected: Boolean;
        AnyChildLinesSelected: Boolean;
        ChildCount: Integer;
        SelectedChildCount: Integer;
    begin
        // Calculate indentation based on whether this is a document line
        if Rec."Is Document Line" then
            Indentation := 1
        else
            Indentation := 0;

        // Check if this document is already in any tour
        DocumentIsSelectable := true;
        DocumentStyle := '';
        DocumentStyleExpr := '';

        PlanningLine.Reset();
        PlanningLine.SetRange(Type, GetPlanningLineType(Rec."Document Type"));
        PlanningLine.SetRange("Source ID", Rec."Document No.");

        if not Rec."Is Document Line" then begin
            // For document headers, check if any planning line exists with this document number
            if not PlanningLine.IsEmpty() then begin
                // This document is already in a tour, mark it as unselectable
                DocumentIsSelectable := false;
                DocumentStyle := 'Unfavorable';
                DocumentStyleExpr := 'Unfavorable';
                SelectionTypeOption := SelectionTypeOption::None;
                SelectionStatusText := 'Order is assigned ⚠️';
                SelectionStatusStyle := 'Unfavorable';
                SelectionTypeStyle := 'Unfavorable';
            end else begin
                // Determine the selection type based on child lines
                DocBuffer.Reset();
                DocBuffer.SetRange("Parent Line No.", Rec."Line No.");
                DocBuffer.SetRange("Is Document Line", true);

                if DocBuffer.FindSet() then begin
                    ChildCount := 0;
                    SelectedChildCount := 0;

                    repeat
                        ChildCount += 1;
                        if DocBuffer.Selected then
                            SelectedChildCount += 1;
                    until DocBuffer.Next() = 0;

                    AllChildLinesSelected := (ChildCount > 0) and (SelectedChildCount = ChildCount);
                    AnyChildLinesSelected := SelectedChildCount > 0;

                    if AllChildLinesSelected then begin
                        SelectionTypeOption := SelectionTypeOption::Full;
                        SelectionStatusText := '✓';
                        SelectionStatusStyle := 'Favorable';
                        SelectionTypeStyle := 'Favorable';
                    end else if AnyChildLinesSelected then begin
                        SelectionTypeOption := SelectionTypeOption::Partial;
                        SelectionStatusText := '◑';
                        SelectionStatusStyle := 'Ambiguous';
                        SelectionTypeStyle := 'Ambiguous';
                    end else begin
                        SelectionTypeOption := SelectionTypeOption::None;
                        SelectionStatusText := '○';
                        SelectionStatusStyle := 'Unfavorable';
                        SelectionTypeStyle := 'Standard';
                    end;
                end else begin
                    SelectionTypeOption := Rec.Selected ? SelectionTypeOption::Full : SelectionTypeOption::None;
                    if Rec.Selected then begin
                        SelectionStatusText := '✓';
                        SelectionStatusStyle := 'Favorable';
                        SelectionTypeStyle := 'Favorable';
                    end else begin
                        SelectionStatusText := '○';
                        SelectionStatusStyle := 'Unfavorable';
                        SelectionTypeStyle := 'Standard';
                    end;
                end;
            end;
        end else begin
            // For document lines, check if this specific line is in a tour
            PlanningLine.SetRange("Item No.", Rec."Item No.");
            if Rec."Source Line No." <> 0 then
                PlanningLine.SetRange("Line No.", Rec."Source Line No.");

            if not PlanningLine.IsEmpty() then begin
                // This document line is already in a tour, mark it as unselectable
                DocumentIsSelectable := false;
                DocumentStyle := 'Unfavorable';
                DocumentStyleExpr := 'Unfavorable';
                SelectionStatusText := 'Line is assigned ⚠️';
                SelectionStatusStyle := 'Unfavorable';
            end else begin
                // Set selection status for document lines based on Selected field
                DocumentIsSelectable := true;
                if Rec.Selected then begin
                    DocumentStyle := 'Favorable';
                    DocumentStyleExpr := 'Favorable';
                    SelectionStatusText := '✓';
                    SelectionStatusStyle := 'Favorable';
                end else begin
                    DocumentStyle := 'Unfavorable';
                    DocumentStyleExpr := 'Unfavorable';
                    SelectionStatusText := 'Available ✓';
                    SelectionStatusStyle := 'Favorable';
                end;
            end;

            // For document lines, check if parent has partial selection
            if Rec."Parent Line No." <> 0 then begin
                DocBuffer.Reset();
                DocBuffer.SetRange("Line No.", Rec."Parent Line No.");
                DocBuffer.SetRange("Is Document Line", false);
                if DocBuffer.FindFirst() then begin
                    // Make line selectable only if parent is in partial selection mode
                    DocBuffer.Reset();
                    DocBuffer.SetRange("Parent Line No.", Rec."Parent Line No.");
                    DocBuffer.SetRange("Is Document Line", true);
                    DocBuffer.SetFilter(Selected, '%1', true);

                    AnyChildLinesSelected := not DocBuffer.IsEmpty();

                    DocBuffer.Reset();
                    DocBuffer.SetRange("Parent Line No.", Rec."Parent Line No.");
                    DocBuffer.SetRange("Is Document Line", true);
                    ChildCount := DocBuffer.Count;

                    DocBuffer.SetRange(Selected, true);
                    SelectedChildCount := DocBuffer.Count;

                    AllChildLinesSelected := (ChildCount > 0) and (SelectedChildCount = ChildCount);

                    if not AllChildLinesSelected and not Rec.Selected then
                        DocumentStyleExpr := 'Standard';
                end;
            end;
        end;
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

        // Mark documents that are already in tours
        MarkDocumentsInTours();

        // Apply filters
        UpdateFilters();
    end;

    local procedure MarkDocumentsInTours()
    var
        PlanningLine: Record "Planning Lines";
        DocBuffer: Record "Planning Document Buffer";
    begin
        // Find all documents that are already in any tour
        DocBuffer.Reset();
        if DocBuffer.FindSet() then
            repeat
                // Check if this document is already in any tour
                PlanningLine.Reset();
                PlanningLine.SetRange(Type, GetPlanningLineType(DocBuffer."Document Type"));
                PlanningLine.SetRange("Source ID", DocBuffer."Document No.");

                if not DocBuffer."Is Document Line" then begin
                    // For document headers, check if any planning line exists with this document number
                    if not PlanningLine.IsEmpty() then begin
                        // This document is already in a tour, mark it as unselectable
                        DocBuffer.Selected := false;
                        DocBuffer.Modify();
                    end;
                end else begin
                    // For document lines, check if this specific line is in a tour
                    PlanningLine.SetRange("Item No.", DocBuffer."Item No.");
                    if DocBuffer."Source Line No." <> 0 then
                        PlanningLine.SetRange("Line No.", DocBuffer."Source Line No.");

                    if not PlanningLine.IsEmpty() then begin
                        // This document line is already in a tour, mark it as unselectable
                        DocBuffer.Selected := false;
                        DocBuffer.Modify();
                    end;
                end;
            until DocBuffer.Next() = 0;
    end;

    local procedure GetPlanningLineType(DocumentType: Option "Sales Order","Purchase Order","Transfer Order"): Option Sales,Purchase,Transfer
    begin
        case DocumentType of
            DocumentType::"Sales Order":
                exit(0); // Sales
            DocumentType::"Purchase Order":
                exit(1); // Purchase
            DocumentType::"Transfer Order":
                exit(2); // Transfer
        end;
    end;

    local procedure LoadSalesOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LineNo: Integer;
        HeaderLineNo: Integer;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter(Status, '%1|%2', SalesHeader.Status::Open, SalesHeader.Status::Released);

        if SalesHeader.FindSet() then
            repeat
                // Create header record
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                HeaderLineNo := LineNo;
                Rec."Line No." := HeaderLineNo;
                Rec."Document Type" := Rec."Document Type"::"Sales Order";
                Rec."Document No." := SalesHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Customer;
                Rec."Account No." := SalesHeader."Sell-to Customer No.";
                Rec."Account Name" := SalesHeader."Sell-to Customer Name";
                Rec."Location Code" := SalesLine."Location Code";
                Rec."Document Date" := SalesHeader."Document Date";
                Rec."Delivery Date" := SalesLine."Planned Shipment Date";
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := SalesHeader.Priority;
                Rec."Is Document Line" := false;
                Rec."Source Line No." := SalesLine."Line No.";
                Rec."Parent Line No." := 0;
                rec."Ship-to Address" := SalesHeader."Ship-to Address";

                // New fields
                Rec."Global Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
                Rec."Global Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
                Rec."Dimension Set ID" := SalesHeader."Dimension Set ID";
                Rec."Expected Shipment Date" := SalesLine."Planned Shipment Date";

                // Additional new fields
                Rec."Document DateTime" := SalesHeader."Document DateTime";
                Rec."Requested Shipment DateTime" := SalesHeader."Document DateTime";
                Rec."Delivery Area" := SalesHeader."Ship-to city";

                // Calculate Before Cutoff field
                CalculateBeforeCutoff(Rec, SalesHeader."Document DateTime");

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
                                Rec."Unit Volume" += Item."Unit Volume" * SalesLine.Quantity;
                                Rec."Gross Weight" += Item."Gross Weight" * SalesLine.Quantity;
                                Rec."Net Weight" += Item."Net Weight" * SalesLine.Quantity;
                            end;
                        end;
                    until SalesLine.Next() = 0;

                Rec.Insert();

                // Now add detail lines for each sales line
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        if SalesLine.Type = SalesLine.Type::Item then begin
                            Clear(Rec);
                            Rec.Init();
                            LineNo += 1;
                            Rec."Line No." := LineNo;
                            Rec."Document Type" := Rec."Document Type"::"Sales Order";
                            Rec."Document No." := SalesHeader."No.";
                            Rec."Account Type" := Rec."Account Type"::Customer;
                            Rec."Account No." := SalesHeader."Sell-to Customer No.";
                            Rec."Account Name" := SalesHeader."Sell-to Customer Name";
                            Rec."Location Code" := SalesLine."Location Code";
                            Rec."Document Date" := SalesHeader."Document Date";
                            Rec."Delivery Date" := SalesLine."Planned Shipment Date";
                            Rec."Tour No." := CurrentTourNo;
                            Rec.Priority := SalesHeader.Priority;
                            Rec."Is Document Line" := true;
                            Rec."Source Line No." := SalesLine."Line No."; // Réinitialiser d'abord
                            Rec."Parent Line No." := HeaderLineNo;
                            rec."Ship-to Address" := SalesHeader."Ship-to Address";
                            Rec."Delivery Area" := SalesHeader."Ship-to city";

                            // Item specific fields
                            Rec."Variant Code" := SalesLine."Variant Code";
                            Rec."Description" := SalesLine."Description";
                            Rec."Total Quantity" := SalesLine.Quantity;
                            Rec."Quantity (Base)" := SalesLine."Quantity (Base)";
                            Rec."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                            Rec."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
                            // Rec."Line No." := SalesLine."Line No.";

                            // Stocker le numéro d'article dans le nouveau champ
                            if SalesLine.Type = SalesLine.Type::Item then
                                Rec."Item No." := SalesLine."No.";

                            // Get additional info from the item
                            if Item.Get(SalesLine."No.") then begin
                                Rec."Unit Volume" := Item."Unit Volume" * SalesLine.Quantity;
                                Rec."Gross Weight" := Item."Gross Weight" * SalesLine.Quantity;
                                Rec."Net Weight" := Item."Net Weight" * SalesLine.Quantity;
                            end;

                            Rec.Insert();
                        end;
                    until SalesLine.Next() = 0;
            until SalesHeader.Next() = 0;
    end;

    local procedure LoadPurchaseOrders()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        LineNo: Integer;
        HeaderLineNo: Integer;
    begin
        if Rec.FindLast() then
            LineNo := Rec."Line No.";

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetFilter(Status, '%1|%2', PurchHeader.Status::Open, PurchHeader.Status::Released);

        if PurchHeader.FindSet() then
            repeat
                // Create header record
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                HeaderLineNo := LineNo;
                Rec."Line No." := HeaderLineNo;
                Rec."Document Type" := Rec."Document Type"::"Purchase Order";
                Rec."Document No." := PurchHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Vendor;
                Rec."Account No." := PurchHeader."Buy-from Vendor No.";
                Rec."Account Name" := PurchHeader."Buy-from Vendor Name";
                Rec."Location Code" := PurchLine."Location Code";
                Rec."Document Date" := PurchHeader."Document Date";
                Rec."Delivery Date" := PurchLine."Expected Receipt Date";
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := PurchHeader.Priority;
                Rec."Is Document Line" := false;
                Rec."Source Line No." := PurchLine."Line No."; // Réinitialiser d'abord
                Rec."Parent Line No." := 0;
                rec."Ship-to Address" := PurchHeader."Ship-to Address";

                // New fields
                Rec."Global Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
                Rec."Global Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
                Rec."Dimension Set ID" := PurchHeader."Dimension Set ID";
                Rec."Expected Receipt Date" := PurchHeader."Expected Receipt Date";

                // Additional new fields
                Rec."Document DateTime" := PurchHeader."Document DateTime";
                // Rec."Requested Shipment DateTime" := PurchHeader."Requested Receipt DateTime";
                Rec."Delivery Area" := PurchHeader."Ship-to city";

                // Calculate Before Cutoff field
                CalculateBeforeCutoff(Rec, PurchHeader."Document DateTime");

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
                                Rec."Unit Volume" += Item."Unit Volume" * PurchLine.Quantity;
                                Rec."Gross Weight" += Item."Gross Weight" * PurchLine.Quantity;
                                Rec."Net Weight" += Item."Net Weight" * PurchLine.Quantity;
                            end;
                        end;
                    until PurchLine.Next() = 0;

                Rec.Insert();

                // Now add detail lines for each purchase line
                PurchLine.Reset();
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                if PurchLine.FindSet() then
                    repeat
                        if PurchLine.Type = PurchLine.Type::Item then begin
                            Clear(Rec);
                            Rec.Init();
                            LineNo += 1;
                            Rec."Line No." := LineNo;
                            Rec."Document Type" := Rec."Document Type"::"Purchase Order";
                            Rec."Document No." := PurchHeader."No.";
                            Rec."Account Type" := Rec."Account Type"::Vendor;
                            Rec."Account No." := PurchHeader."Buy-from Vendor No.";
                            Rec."Account Name" := PurchHeader."Buy-from Vendor Name";
                            Rec."Location Code" := PurchLine."Location Code";
                            Rec."Document Date" := PurchHeader."Document Date";
                            Rec."Delivery Date" := PurchLine."Expected Receipt Date";
                            Rec."Tour No." := CurrentTourNo;
                            Rec.Priority := PurchHeader.Priority;
                            Rec."Is Document Line" := true;
                            Rec."Source Line No." := PurchLine."Line No."; // Réinitialiser d'abord
                            Rec."Parent Line No." := HeaderLineNo;
                            rec."Ship-to Address" := PurchHeader."Ship-to Address";
                            Rec."Delivery Area" := PurchHeader."ship-to City";


                            // Item specific fields
                            Rec."Variant Code" := PurchLine."Variant Code";
                            Rec."Description" := PurchLine."Description";
                            Rec."Total Quantity" := PurchLine.Quantity;
                            Rec."Quantity (Base)" := PurchLine."Quantity (Base)";
                            Rec."Unit of Measure Code" := PurchLine."Unit of Measure Code";
                            Rec."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
                            // Rec."Line No." := PurchLine."Line No.";

                            // Stocker le numéro d'article dans le nouveau champ
                            if PurchLine.Type = PurchLine.Type::Item then
                                Rec."Item No." := PurchLine."No.";

                            // Get additional info from the item
                            if Item.Get(PurchLine."No.") then begin
                                Rec."Unit Volume" := Item."Unit Volume" * PurchLine.Quantity;
                                Rec."Gross Weight" := Item."Gross Weight" * PurchLine.Quantity;
                                Rec."Net Weight" := Item."Net Weight" * PurchLine.Quantity;
                            end;

                            Rec.Insert();
                        end;
                    until PurchLine.Next() = 0;
            until PurchHeader.Next() = 0;
    end;

    local procedure LoadTransferOrders()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        LineNo: Integer;
        HeaderLineNo: Integer;
    begin
        if Rec.FindLast() then
            LineNo := Rec."Line No.";

        TransferHeader.SetFilter(Status, '%1|%2', TransferHeader.Status::Open, TransferHeader.Status::Released);

        if TransferHeader.FindSet() then
            repeat
                // Create header record
                Clear(Rec);
                Rec.Init();
                LineNo += 1;
                HeaderLineNo := LineNo;
                Rec."Line No." := HeaderLineNo;
                Rec."Document Type" := Rec."Document Type"::"Transfer Order";
                Rec."Document No." := TransferHeader."No.";
                Rec."Account Type" := Rec."Account Type"::Location;
                Rec."Account No." := TransferLine."Transfer-to Code";
                Rec."Account Name" := GetLocationName(TransferHeader."Transfer-to Code");
                Rec."Location Code" := TransferLine."Transfer-from Code";
                Rec."Document Date" := TransferHeader."Posting Date";
                Rec."Delivery Date" := TransferLine."Receipt Date";
                Rec."Tour No." := CurrentTourNo;
                Rec.Priority := TransferHeader.Priority;
                Rec."Is Document Line" := false;
                Rec."Source Line No." := TransferLine."Line No."; // Réinitialiser d'abord
                Rec."Parent Line No." := 0;
                rec."Ship-to Address" := TransferHeader."Transfer-to Address";

                // New fields
                Rec."Expected Shipment Date" := TransferHeader."Shipment Date";
                Rec."Expected Receipt Date" := TransferHeader."Receipt Date";

                // Additional new fields
                Rec."Document DateTime" := TransferHeader."Document DateTime";
                // Rec."Requested Shipment DateTime" := TransferHeader."Requested Shipment DateTime";
                Rec."Delivery Area" := TransferHeader."Transfer-to City";

                // Calculate Before Cutoff field
                CalculateBeforeCutoff(Rec, TransferHeader."Document DateTime");

                // Calculate total quantity and weight
                TransferLine.SetRange("Document No.", TransferHeader."No.");
                if TransferLine.FindSet() then
                    repeat
                        Rec."Total Quantity" += TransferLine.Quantity;
                        Rec."Quantity (Base)" += TransferLine."Quantity (Base)";

                        // Get additional info from the item
                        if Item.Get(TransferLine."Item No.") then begin
                            Rec."Unit Volume" += Item."Unit Volume" * TransferLine.Quantity;
                            Rec."Gross Weight" += Item."Gross Weight" * TransferLine.Quantity;
                            Rec."Net Weight" += Item."Net Weight" * TransferLine.Quantity;

                            // Add dimension information from the item
                            Rec."Global Dimension 1 Code" := Item."Global Dimension 1 Code";
                            Rec."Global Dimension 2 Code" := Item."Global Dimension 2 Code";
                        end;
                    until TransferLine.Next() = 0;

                Rec.Insert();

                // Now add detail lines for each transfer line
                TransferLine.Reset();
                TransferLine.SetRange("Document No.", TransferHeader."No.");
                if TransferLine.FindSet() then
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
                        Rec."Location Code" := TransferLine."Transfer-from Code";
                        Rec."Document Date" := TransferHeader."Posting Date";
                        Rec."Delivery Date" := TransferLine."Receipt Date";
                        Rec."Tour No." := CurrentTourNo;
                        Rec.Priority := TransferHeader.Priority;
                        Rec."Is Document Line" := true;
                        Rec."Source Line No." := TransferLine."Line No."; // Réinitialiser d'abord
                        Rec."Parent Line No." := HeaderLineNo;
                        rec."Ship-to Address" := TransferHeader."Transfer-to Address";
                        Rec."Delivery Area" := TransferHeader."Transfer-to City";



                        // Item specific fields
                        Rec."Variant Code" := TransferLine."Variant Code";
                        Rec."Description" := TransferLine."Description";
                        Rec."Total Quantity" := TransferLine.Quantity;
                        Rec."Quantity (Base)" := TransferLine."Quantity (Base)";
                        Rec."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                        Rec."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                        Rec."Qty. Rounding Precision" := TransferLine."Qty. Rounding Precision";
                        Rec."Qty. Rounding Precision (Base)" := TransferLine."Qty. Rounding Precision (Base)";
                        Rec."Source Line No." := TransferLine."Line No.";

                        // Stocker le numéro d'article dans le nouveau champ
                        Rec."Item No." := TransferLine."Item No.";

                        // Get additional info from the item
                        if Item.Get(TransferLine."Item No.") then begin
                            Rec."Unit Volume" := Item."Unit Volume" * TransferLine.Quantity;
                            Rec."Gross Weight" := Item."Gross Weight" * TransferLine.Quantity;
                            Rec."Net Weight" := Item."Net Weight" * TransferLine.Quantity;

                            // Add dimension information from the item
                            Rec."Global Dimension 1 Code" := Item."Global Dimension 1 Code";
                            Rec."Global Dimension 2 Code" := Item."Global Dimension 2 Code";
                        end;

                        Rec.Insert();
                    until TransferLine.Next() = 0;
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

    local procedure GetLocationCounty(LocationCode: Code[10]): Text[50]
    var
        Location: Record Location;
    begin
        if Location.Get(LocationCode) then
            exit(Location.County);

        exit('');
    end;

    local procedure CalculateBeforeCutoff(var DocBuffer: Record "Planning Document Buffer"; DocumentDateTime: DateTime)
    var
        TripSetup: Record "Trip Setup";
        DocumentTime: Time;
    begin
        if TripSetup.Get() then begin
            if DocumentDateTime <> 0DT then begin
                DocumentTime := DT2Time(DocumentDateTime);

                // Check if document time is before cutoff time
                DocBuffer."Before Cutoff" := DocumentTime < TripSetup."Logistics Cutoff Time";
            end else
                DocBuffer."Before Cutoff" := false;
        end else
            DocBuffer."Before Cutoff" := false;
    end;

    local procedure UpdateFilters()
    var
        TripSetup: Record "Trip Setup";
        CurrentDateTime: DateTime;
        CurrentTime: Time;
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
            Rec.SetFilter("Delivery Date", '>%1', DateFilterStart);

        if DateFilterEnd <> 0D then
            Rec.SetFilter("Delivery Date", '<%1', DateFilterEnd);
        if DateFilterEnd < DateFilterStart then
            Error('End date cannot be earlier than start date.');


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
            Rec.SetFilter(Priority, Format(PriorityFilter));

        // Filter by delivery area
        if DeliveryAreaFilter <> '' then
            Rec.SetFilter("Delivery Area", DeliveryAreaFilter);

        // Filter by requested shipment date
        if RequestedShipmentDateFilter <> 0D then
            Rec.SetFilter("Delivery Date", '=%1', RequestedShipmentDateFilter);

        // Filter by cutoff time
        if CutoffLogisticsFilter then begin
            if TripSetup.Get() then begin
                CurrentDateTime := CurrentDateTime();
                CurrentTime := DT2Time(CurrentDateTime);

                // Filter documents where Before Cutoff is true
                Rec.SetRange("Before Cutoff", true);
            end;
        end;

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
        DocBuffer: Record "Planning Document Buffer" temporary;
        ProcessedDocuments: List of [Code[20]];
        SkippedDuplicates: Integer;
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

        // Count all selected records (headers and lines)
        Rec.Reset();
        Rec.SetRange(Selected, true);
        if not Rec.FindSet() then begin
            Message('No documents or lines are selected. Please select at least one document or line.');
            exit;
        end;

        // Process all selected records
        repeat
            AttemptsCount += 1;

            // Check if this document is already in any tour
            PlanningLine.Reset();
            PlanningLine.SetRange(Type, GetPlanningLineType(Rec."Document Type"));
            PlanningLine.SetRange("Source ID", Rec."Document No.");

            if Rec."Is Document Line" then begin
                // For document lines, check if this specific line is already in a tour
                PlanningLine.SetRange("Item No.", Rec."Item No.");
                if Rec."Source Line No." <> 0 then
                    PlanningLine.SetRange("Line No.", Rec."Source Line No.");

                if not PlanningLine.IsEmpty() then begin
                    // This document line is already in a tour, skip it
                    SkippedDuplicates += 1;
                    CurrPage.Update(false);
                end else if not ProcessedDocuments.Contains(Rec."Document No.") then begin
                    // Process this individual line
                    Clear(DocBuffer);
                    DocBuffer := Rec;
                    DocBuffer."Tour No." := CurrentTourNo;

                    // Clear any error message before calling
                    ClearLastError();

                    // Call with the CORRECT tour header record
                    PlanningLineMgt.AddDocumentLineToTour(TourHeader, DocBuffer);

                    if GetLastErrorText = '' then
                        SelectedCount += 1;
                end;
            end else begin
                // For document headers, check if any planning line exists with this document number
                if not PlanningLine.IsEmpty() then begin
                    // This document is already in a tour, skip it
                    SkippedDuplicates += 1;
                    CurrPage.Update(false);
                end else begin
                    // It's a document header and not in any tour yet
                    ProcessedDocuments.Add(Rec."Document No.");

                    // Force the tour number in buffer
                    DocBuffer := Rec;
                    DocBuffer."Tour No." := CurrentTourNo;

                    // Clear any error message before calling
                    ClearLastError();

                    // Call with the CORRECT tour header record
                    PlanningLineMgt.AddDocumentToTour(TourHeader, DocBuffer);

                    if GetLastErrorText = '' then
                        SelectedCount += 1;
                end;
            end;
        until Rec.Next() = 0;

        // Get count of planning lines after
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", CurrentTourNo);
        CountAfter := PlanningLine.Count;

        // Refresh the page to update the selectable status of documents
        LoadDocuments();

        // Final message and close page
        if (SelectedCount > 0) and (CountAfter > CountBefore) then begin
            if SkippedDuplicates > 0 then
                Message('Successfully added %1 out of %2 selected item(s) to tour %3. Added %4 planning lines.\%5 items were skipped because they are already in a tour.',
                        SelectedCount, AttemptsCount, CurrentTourNo, CountAfter - CountBefore, SkippedDuplicates)
            else
                Message('Successfully added %1 out of %2 selected item(s) to tour %3. Added %4 planning lines.',
                        SelectedCount, AttemptsCount, CurrentTourNo, CountAfter - CountBefore);
            ActionOK := true;
            CurrPage.Close();
        end else if SkippedDuplicates > 0 then begin
            Message('No new documents were added. %1 items were skipped because they are already in a tour.', SkippedDuplicates);
        end else if SelectedCount > 0 then begin
            Message('Documents were processed but no planning lines were added. Please check the tour configuration.');
        end else
            Message('No documents were added to the tour. Error: %1', GetLastErrorText);
    end;

    local procedure UpdateChildLines(ParentLineNo: Integer; SelectValue: Boolean)
    var
        DocBuffer: Record "Planning Document Buffer";
    begin
        DocBuffer.Reset();
        DocBuffer.SetRange("Parent Line No.", ParentLineNo);
        DocBuffer.SetRange("Is Document Line", true);

        if DocBuffer.FindSet() then
            repeat
                DocBuffer.Selected := SelectValue;
                DocBuffer.Modify();
            until DocBuffer.Next() = 0;

        CurrPage.Update(false);
    end;

    procedure IsActionOK(): Boolean
    begin
        exit(ActionOK);
    end;
}