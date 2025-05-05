page 50135 "Vehicle Loading List"
{
    PageType = List;
    SourceTable = "Vehicle Loading Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Vehicle Loading List';
    Editable = True;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Loading Date"; Rec."Loading Date") { ApplicationArea = All; }
                field("Tour No."; Rec."Tour No.") { ApplicationArea = All; }
                field("Truck No."; Rec."Truck No.") { ApplicationArea = All; }
                field("Driver No."; Rec."Driver No.") { ApplicationArea = All; }
                field("Loading Location"; Rec."Loading Location") { ApplicationArea = All; }
                field("Departure Time"; Rec."Departure Time") { ApplicationArea = All; }
                field("Arrival Time"; Rec."Arrival Time") { ApplicationArea = All; }
                field("Total Weight (kg)"; Rec."Total Weight (kg)") { ApplicationArea = All; }
                field("Total Volume (m³)"; Rec."Total Volume (m³)") { ApplicationArea = All; }
                field("Number of Deliveries"; Rec."Number of Deliveries") { ApplicationArea = All; }
                field("Goods Type"; Rec."Goods Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Itinerary Type"; Rec."Itinerary Type") { ApplicationArea = All; }
                field("Total Distance (km)"; Rec."Total Distance (km)") { ApplicationArea = All; }
                field("Estimated Duration"; Rec."Estimated Duration") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenCard)
            {
                Caption = 'Open';
                ApplicationArea = All;
                Image = EditLines;
                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Vehicle Loading Card", Rec);
                end;
            }
        }
    }
}
