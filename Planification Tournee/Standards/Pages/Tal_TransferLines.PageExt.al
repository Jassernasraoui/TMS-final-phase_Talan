pageextension 77003 "Tal transfer Lines" extends "transfer Lines"
{
    layout
    {
        addfirst(Control1)
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