page 50130 "Vehicle Loading Card"
{
    PageType = Card;
    SourceTable = "Vehicle Loading";
    Caption = 'Vehicle Loading';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "Planification Document";
                    Editable = false;
                }
                field("Loading Date"; Rec."Loading Date") { ApplicationArea = All; }
                // field("Vehicle No."; Rec."Vehicle No.") { ApplicationArea = All; }
                // field("Driver Name"; Rec."Driver Name") { ApplicationArea = All; }
                field("Loading Location"; Rec."Loading Location") { ApplicationArea = All; }
                field("Destination"; Rec."Destination") { ApplicationArea = All; }
                field("Cargo Description"; Rec."Cargo Description") { ApplicationArea = All; }
                field("Weight (kg)"; Rec."Weight (kg)") { ApplicationArea = All; }
                field("Hazardous Material"; Rec."Hazardous Material") { ApplicationArea = All; }
            }
        }
    }
}
