page 50114 "Truck Loading Card"
{
    PageType = Card;
    SourceTable = "Truck Loading Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("General")
            {
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Loading Date"; rec."Loading Date")
                {
                    ApplicationArea = All;

                }
                field("Tour No."; rec."Tour No.")
                {
                    ApplicationArea = All;

                }
                field("Truck No."; rec."Truck No.")
                {
                    ApplicationArea = All;

                }
                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = All;

                }
                field("Loading Location"; rec."Loading Location")
                {
                    ApplicationArea = All;

                }
            }

            group("Timing")
            {
                field("Departure Time"; rec."Departure Time") { }
                field("Arrival Time"; rec."Arrival Time") { }
                field("Validation Date"; rec."Validation Date") { }
            }

            group("Load Info")
            {
                field("Total Weight (kg)"; rec."Total Weight (kg)") { }
                field("Total Volume (m³)"; rec."Total Volume (m³)") { }
                field("Number of Deliveries"; rec."Number of Deliveries") { }
                field("Goods Type"; rec."Goods Type") { }
            }

            group("Itinerary")
            {
                field("Itinerary No."; rec."Itinerary No.") { }
                field("Total Distance (km)"; rec."Total Distance (km)") { }
                field("Estimated Duration"; rec."Estimated Duration") { }
                field("Itinerary Type"; rec."Itinerary Type") { }
                field("Planned Route"; rec."Planned Route") { }
            }

            group("Statuts")
            {
                field("Status"; rec."Status") { }
                field("Validated By"; rec."Validated By") { }
            }

            part("StopsPart"; "Truck Stop List")
            {
                SubPageLink = "Fiche No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
    }
}
