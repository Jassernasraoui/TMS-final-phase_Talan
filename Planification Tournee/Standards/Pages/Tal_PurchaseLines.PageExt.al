pageextension 77008 "Tal Purchase Lines" extends "Purchase Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("Logistic Tour No."; rec."Logistic Tour No.")
            {
                ApplicationArea = All;
                ToolTip = 'The number of the logistic tour.';
                TableRelation = "Planification Header"."Logistic Tour No.";
                // ValidateTableRelation = true;
            }

        }
    }

    actions
    {
        // Add your custom actions here
    }

    trigger OnOpenPage()
    begin
        // Add your custom logic here
    end;
}