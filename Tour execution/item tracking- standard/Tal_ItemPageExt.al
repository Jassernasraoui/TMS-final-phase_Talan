pageextension 73598 "Tal_ItemPageExt" extends "Item Card"
{
    layout
    {
        addlast(Warehouse)
        {
            field("Vehicle Class Code"; Rec."Vehicle Class Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the required vehicle class for transporting this item.';
            }
        }

        addlast(Item)
        {
            group("Special Handling Requirements")
            {
                Caption = 'Special Handling Requirements';

                field("Special Handling"; Rec."Special Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any special handling requirements for this item.';
                    Importance = Promoted;
                }

                field("Temperature Requirements"; Rec."Temperature Requirements")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the temperature requirements for this item in degrees Celsius.';
                    Visible = ShowTemperatureField;
                }

                field("Handling Instructions"; Rec."Handling Instructions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies detailed handling instructions for this item.';
                    MultiLine = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateVisibility();
    end;

    local procedure UpdateVisibility()
    begin
        ShowTemperatureField := (Rec."Special Handling" = Rec."Special Handling"::"Temperature Controlled") or
                               (Rec."Special Handling" = Rec."Special Handling"::Perishable);
    end;

    var
        ShowTemperatureField: Boolean;
}