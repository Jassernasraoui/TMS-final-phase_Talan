pageextension 73598 "Tal_ItemPageExt" extends "Item Card"
{
    layout
    {
        addlast(Warehouse)
        {
            field("Vehicle Class Code"; Rec."Vehicle Class Code")
            {
                ApplicationArea = All;
            }
        }
    }
}