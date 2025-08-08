pageextension 73505 "Tal Sales Lines" extends "Sales order"
{
    layout
    {
        addlast(General)
        {
            field("Logistic Tour No."; rec."Logistic Tour No.")
            {
                ApplicationArea = All;
                ToolTip = 'The number of the logistic tour.';
                TableRelation = "Planification Header"."Logistic Tour No.";
                // ValidateTableRelation = true;
            }
            field("Priority"; rec.Priority)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the priority of the sales line.';
                Caption = 'Priority';
                Editable = true;
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