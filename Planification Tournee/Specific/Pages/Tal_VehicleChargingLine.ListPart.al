page 73523 "Vehicle Charging Line List"
{
    PageType = ListPart;
    SourceTable = "Vehicle Charging Line";
    ApplicationArea = All;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; rec."Line No.") { ApplicationArea = All; Editable = false; Visible = false; }
                field("Stop No."; rec."Stop No.") { ApplicationArea = All; Editable = false; }
                field("Document Type"; rec."Document Type") { ApplicationArea = All; Editable = false; }
                field("Customer No."; rec."Customer No.") { ApplicationArea = All; Editable = false; }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the item number of the delivery.';
                    Editable = false;
                }
                field("description"; rec."Description")
                {
                    ApplicationArea = All;
                    Caption = 'item Description';
                    ToolTip = 'Specifies the description of the delivery.';
                    Editable = false;
                }
                field("Delivery Address"; rec."Delivery Address") { ApplicationArea = All; Editable = false; }
                field("Planned Quantity"; rec."prepapred Quantity") { ApplicationArea = All; Editable = false; StyleExpr = 'Strong'; }
                field("Purchased Quantity"; rec."Purchased Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Received';
                    ToolTip = 'Specifies the quantity that has been purchased (only for Purchase document type).';
                    Visible = true;
                    StyleExpr = 'Favorable';
                    Editable = IsPurchaseDocType;

                    trigger OnValidate()
                    var
                        PurchasedQty: Decimal;
                        stopline: Record "vehicle Stop Line";
                    begin

                        begin
                            if PurchasedQty < 0 then
                                Error('Purchased Quantity cannot be negative.');
                            if PurchasedQty > rec."prepapred Quantity" then
                                Error('Purchased Quantity cannot exceed the planned quantity.');

                            rec."Purchased Quantity" := PurchasedQty;
                            rec."Actual Quantity" := rec."Purchased Quantity";
                            rec."Quantity Difference" := rec."prepapred Quantity" - rec."Actual Quantity";
                            rec.Modify(true);

                            Message('Purchased Quantity updated to %1.', PurchasedQty);
                        end;
                    end;
                }
                field("Charged Quantity"; rec."Actual Quantity")
                {
                    ApplicationArea = All;
                    StyleExpr = QuantityStyleExpr;
                    Caption = 'Charged Quantity';
                    ToolTip = 'Specifies the quantity that has been charged.';
                    Editable = IsPurchaseDocType = false;

                    trigger OnValidate()
                    begin
                        UpdateLoadingStatus();
                    end;
                }
                field("Quantity Difference"; rec."Quantity Difference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = DifferenceStyleExpr;
                    Caption = 'quantity not charged';
                    ToolTip = 'Specifies the difference between planned and actual charged quantity.';
                }

                field("Loading Status"; rec."Loading Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;

                    trigger OnValidate()
                    begin
                        UpdateQuantityBasedOnStatus();
                    end;
                }
                field("Loaded By"; rec."Loaded By") { ApplicationArea = All; Editable = false; }
                field("Loading Time"; rec."Loading Time") { ApplicationArea = All; Editable = false; }
                field("Remarks"; rec."Remarks") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Load Quantities from Receipt")
            {
                ApplicationArea = All;
                Caption = 'Load Qty from Receipt';
                Image = Calculate;

                trigger OnAction()
                var
                    ChargingHeader: Record "Vehicle Charging Header";
                    TransferReceiptLine: Record "Transfer Receipt Line";
                begin
                    // Get the parent header
                    if not ChargingHeader.Get(rec."Charging No.") then
                        Error('Charging header %1 not found.', rec."Charging No.");

                    // Match with Transfer Receipt Line
                    TransferReceiptLine.Reset();
                    TransferReceiptLine.SetRange("Transfer Order No.", ChargingHeader."Transfer Order No.");
                    TransferReceiptLine.SetRange("Item No.", rec."Item No."); // Use Item No for better match
                                                                              // TransferReceiptLine.SetRange("Line No.", rec."Stop No."); // Commented out if not reliable

                    if TransferReceiptLine.FindFirst() then begin
                        rec."Actual Quantity" := TransferReceiptLine."Quantity";
                        rec."Quantity Difference" := rec."Actual Quantity" - rec."prepapred Quantity";

                        // Update Loading Status based on actual qty
                        if rec."Actual Quantity" = 0 then
                            rec."Loading Status" := rec."Loading Status"::NotLoaded
                        else
                            if rec."Actual Quantity" < rec."prepapred Quantity" then
                                rec."Loading Status" := rec."Loading Status"::PartiallyLoaded
                            else
                                rec."Loading Status" := rec."Loading Status"::Loaded;

                        rec.Modify(true);
                        Message('Loaded: Qty=%1 | Diff=%2 | Status=%3',
                            rec."Actual Quantity",
                            rec."Quantity Difference",
                            Format(rec."Loading Status"));
                    end else
                        Error('No matching Transfer Receipt Line found for Item %1.', rec."Item No.");
                end;
            }


            action("Mark as Loaded")
            {
                ApplicationArea = All;
                Caption = 'Mark as Loaded';
                Image = Completed;

                trigger OnAction()
                begin
                    rec."Loading Status" := rec."Loading Status"::Loaded;

                    if rec."Actual Quantity" = 0 then
                        rec."Actual Quantity" := rec."prepapred Quantity";

                    rec."Loaded By" := UserId;
                    rec."Loading Time" := Time;
                    rec.Modify(true);

                    SetStyleExpressions();
                end;
            }

            action("Mark as Partially Loaded")
            {
                ApplicationArea = All;
                Caption = 'Mark as Partially Loaded';
                Image = Partial;

                trigger OnAction()
                var
                    PartialQty: Decimal;
                begin
                    // Set a default quantity of half the planned quantity
                    PartialQty := Round(rec."prepapred Quantity" / 2, 0.01);

                    // Use standard confirmation dialog
                    if not Confirm('Mark as partially loaded with quantity %1?\Planned: %2',
                        true, PartialQty, rec."prepapred Quantity") then
                        exit;

                    // Set as partially loaded with default quantity
                    rec."Loading Status" := rec."Loading Status"::PartiallyLoaded;
                    rec."Actual Quantity" := PartialQty;
                    rec."Loaded By" := UserId;
                    rec."Loading Time" := Time;
                    rec.Modify(true);

                    SetStyleExpressions();

                    Message('Item marked as partially loaded with quantity %1.', PartialQty);
                end;
            }

            action("Mark as Not Loaded")
            {
                ApplicationArea = All;
                Caption = 'Mark as Not Loaded';
                Image = Cancel;

                trigger OnAction()
                begin
                    rec."Loading Status" := rec."Loading Status"::NotLoaded;
                    rec."Actual Quantity" := 0;
                    rec."Loaded By" := UserId;
                    rec."Loading Time" := Time;
                    rec.Modify(true);

                    SetStyleExpressions();
                end;
            }

            action("Update Purchased Quantity")
            {
                ApplicationArea = All;
                Caption = 'Update Purchased Quantity';
                Image = UpdateUnitCost;
                Visible = IsPurchaseDocType;

                trigger OnAction()
                var
                    PurchasedQty: Decimal;
                    stopline: Record "vehicle Stop Line";
                begin
                    if rec."Document Type" <> rec."Document Type"::Purchase then
                        Error('This action is only available for Purchase document type.');

                    // Use standard input dialog
                    if not Dialog.Confirm('Do you want to update the Purchased Quantity?', true) then
                        exit;

                    // Remplacer Dialog.Input par la fonction InputDecimal
                    if not InputDecimal('Purchased Quantity', 'Enter Purchased Quantity:', PurchasedQty) then
                        exit;

                    if PurchasedQty < 0 then
                        Error('Purchased Quantity cannot be negative.');
                    if PurchasedQty > rec."prepapred Quantity" then
                        Error('Purchased Quantity cannot exceed the planned quantity.');

                    rec."Purchased Quantity" := PurchasedQty;
                    rec."Actual Quantity" := rec."Purchased Quantity";
                    rec."Quantity Difference" := rec."prepapred Quantity" - rec."Actual Quantity";
                    rec.Modify(true);

                    Message('Purchased Quantity updated to %1.', PurchasedQty);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
        IsPurchaseDocType := (rec."Document Type" = rec."Document Type"::Purchase);
    end;

    trigger OnOpenPage()
    begin
        SetStyleExpressions();
        IsPurchaseDocType := (rec."Document Type" = rec."Document Type"::Purchase);
    end;

    local procedure UpdateLoadingStatus()
    begin
        if rec."Actual Quantity" = 0 then
            rec."Loading Status" := rec."Loading Status"::NotLoaded
        else if rec."Actual Quantity" >= rec."prepapred Quantity" then
            rec."Loading Status" := rec."Loading Status"::Loaded
        else
            rec."Loading Status" := rec."Loading Status"::PartiallyLoaded;

        if (rec."Loaded By" = '') then
            rec."Loaded By" := UserId;

        if (rec."Loading Time" = 0T) then
            rec."Loading Time" := Time;

        SetStyleExpressions();
    end;

    local procedure UpdateQuantityBasedOnStatus()
    begin
        case rec."Loading Status" of
            rec."Loading Status"::Loaded:
                if rec."Actual Quantity" = 0 then
                    rec."Actual Quantity" := rec."prepapred Quantity";
            rec."Loading Status"::NotLoaded:
                rec."Actual Quantity" := 0;
            rec."Loading Status"::PartiallyLoaded:
                if rec."Actual Quantity" = 0 then
                    rec."Actual Quantity" := Round(rec."prepapred Quantity" / 2, 0.01);
            rec."Loading Status"::Pending:
                rec."Actual Quantity" := 0;
        end;

        if (rec."Loaded By" = '') and (rec."Loading Status" <> rec."Loading Status"::Pending) then
            rec."Loaded By" := UserId;

        if (rec."Loading Time" = 0T) and (rec."Loading Status" <> rec."Loading Status"::Pending) then
            rec."Loading Time" := Time;

        SetStyleExpressions();
    end;

    local procedure SetStyleExpressions()
    begin
        // Set styles based on loading status
        case rec."Loading Status" of
            rec."Loading Status"::Loaded:
                StatusStyleExpr := 'Favorable';
            rec."Loading Status"::PartiallyLoaded:
                StatusStyleExpr := 'Ambiguous';
            rec."Loading Status"::NotLoaded:
                StatusStyleExpr := 'Unfavorable';
            rec."Loading Status"::Pending:
                StatusStyleExpr := 'Standard';
        end;

        // Set styles based on quantity difference
        if rec."Quantity Difference" = 0 then
            DifferenceStyleExpr := 'Favorable'
        else if rec."Quantity Difference" > 0 then
            DifferenceStyleExpr := 'StrongAccent'
        else
            DifferenceStyleExpr := 'Unfavorable';

        // Set styles for actual quantity
        if rec."Actual Quantity" = 0 then
            QuantityStyleExpr := 'Standard'
        else if rec."Actual Quantity" >= rec."prepapred Quantity" then
            QuantityStyleExpr := 'Favorable'
        else
            QuantityStyleExpr := 'Ambiguous';
    end;

    var
        StatusStyleExpr: Text;
        DifferenceStyleExpr: Text;
        QuantityStyleExpr: Text;
        IsPurchaseDocType: Boolean;

    local procedure InputDecimal(TitleTxt: Text[100]; PromptTxt: Text[250]; var ResultDecimal: Decimal): Boolean
    var
        InputDialog: Page "Input Dialog";
        ResultTxt: Text[250];
    begin
        ResultTxt := Format(ResultDecimal);
        InputDialog.SetTexts(TitleTxt, PromptTxt);
        if InputDialog.RunModal() = ACTION::OK then begin
            ResultTxt := InputDialog.GetInput();
            Evaluate(ResultDecimal, ResultTxt);
            exit(true);
        end;
        exit(false);
    end;
}

// Ajouter cette procédure locale à la fin du fichier, avant la dernière accolade
