pageextension 77004 "Tal Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addlast(Content)
        {
            field("Logistic Tour No."; rec."Logistic Tour No.")
            {
                ApplicationArea = All;
            }
        }
    }
}