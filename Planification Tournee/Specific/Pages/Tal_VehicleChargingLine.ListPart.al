page 77023 "Vehicle Charging Line List"
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
                field("Line No."; rec."Line No.") { ApplicationArea = All; Editable = false; }
                field("Stop No."; rec."Stop No.") { ApplicationArea = All; Editable = false; }
                field("Customer No."; rec."Customer No.") { ApplicationArea = All; Editable = false; }
                field("Delivery Address"; rec."Delivery Address") { ApplicationArea = All; Editable = false; }
                field("Planned Quantity"; rec."Planned Quantity") { ApplicationArea = All; Editable = false; StyleExpr = 'Strong'; }
                field("Actual Quantity"; rec."Actual Quantity")
                {
                    ApplicationArea = All;
                    StyleExpr = QuantityStyleExpr;

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
            action("Mark as Loaded")
            {
                ApplicationArea = All;
                Caption = 'Mark as Loaded';
                Image = Completed;

                trigger OnAction()
                begin
                    rec."Loading Status" := rec."Loading Status"::Loaded;

                    if rec."Actual Quantity" = 0 then
                        rec."Actual Quantity" := rec."Planned Quantity";

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
                    PartialQty := Round(rec."Planned Quantity" / 2, 0.01);

                    // Use standard confirmation dialog
                    if not Confirm('Mark as partially loaded with quantity %1?\Planned: %2',
                        true, PartialQty, rec."Planned Quantity") then
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
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStyleExpressions();
    end;

    trigger OnOpenPage()
    begin
        SetStyleExpressions();
    end;

    local procedure UpdateLoadingStatus()
    begin
        if rec."Actual Quantity" = 0 then
            rec."Loading Status" := rec."Loading Status"::NotLoaded
        else if rec."Actual Quantity" >= rec."Planned Quantity" then
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
                    rec."Actual Quantity" := rec."Planned Quantity";
            rec."Loading Status"::NotLoaded:
                rec."Actual Quantity" := 0;
            rec."Loading Status"::PartiallyLoaded:
                if rec."Actual Quantity" = 0 then
                    rec."Actual Quantity" := Round(rec."Planned Quantity" / 2, 0.01);
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
        else if rec."Actual Quantity" >= rec."Planned Quantity" then
            QuantityStyleExpr := 'Favorable'
        else
            QuantityStyleExpr := 'Ambiguous';
    end;

    var
        StatusStyleExpr: Text;
        DifferenceStyleExpr: Text;
        QuantityStyleExpr: Text;
}