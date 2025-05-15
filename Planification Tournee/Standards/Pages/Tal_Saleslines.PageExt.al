pageextension 77005 "Tal Sales Lines" extends "Sales Lines"
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

// {
//     layout
//     {
//         addlast(Control1)
//         {
//             field("Logistic Tour No."; rec."Logistic Tour No.")
//             {
//                 ApplicationArea = All;
//                 ToolTip = 'The number of the logistic tour.';
//                 TableRelation = "Planification Header"."Logistic Tour No.";
//                 // ValidateTableRelation = true;
//             }

//         }
//     }

//     actions
//     {
//         // Add your custom actions here
//     }

//     trigger OnOpenPage()
//     begin
//         // Add your custom logic here
//     end;
// }