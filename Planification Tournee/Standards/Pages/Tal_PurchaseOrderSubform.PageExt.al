pageextension 50128 "Tal Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addfirst(Content)
        {
            field("Logistic Tour No."; rec."Logistic Tour No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the logistic tour number.';
            }
        }
    }

    actions
    {
        // Add actions here if needed
    }
}