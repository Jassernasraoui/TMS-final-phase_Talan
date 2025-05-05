page 50131 "Vehicle Loading List"
{
    PageType = List;
    SourceTable = "Vehicle Loading";
    Caption = 'Vehicle Loading List';
    ApplicationArea = All;
    CardPageId = "Vehicle Loading";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Tour No.") { ApplicationArea = All; }
                field("Loading Date"; Rec."Loading Date") { ApplicationArea = All; }
                // field("Vehicle No."; Rec."Vehicle No.") 
                // { ApplicationArea = All;
                // LookupPageId = "Resource List" ;
                //  }
                // field("Driver Name"; Rec."Driver Name")
                //  { ApplicationArea = All;
                //  LookupPageId = "Resource List"; 
                //   }
                field("Loading Location"; Rec."Loading Location") { ApplicationArea = All; }
                field("Destination"; Rec."Destination") { ApplicationArea = All; }
                field("Cargo Description"; Rec."Cargo Description") { ApplicationArea = All; }
                field("Weight (kg)"; Rec."Weight (kg)") { ApplicationArea = All; }
                field("Hazardous Material"; Rec."Hazardous Material") { ApplicationArea = All; }
            }
        }
    }

    // actions
    // {
    //     area(navigation)
    //     {
    //         group("Vehicle Loading")
    //         {
    //             action("Card")
    //             {
    //                 ApplicationArea = All;
    //                 RunObject = page "Vehicle Loading Card";
    //                 RunPageMode = View;
    //             }
    //         }
    //     }
    // }
}
