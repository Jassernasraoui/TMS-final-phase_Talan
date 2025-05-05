pageextension 50127 Tal_SalesOrderSubformExt extends "Sales Order Subform"
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