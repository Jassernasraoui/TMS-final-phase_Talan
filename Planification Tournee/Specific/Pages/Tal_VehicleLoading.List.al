page 50135 "Vehicle Loading List"
{
    PageType = List;
    SourceTable = "Vehicle Loading Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Vehicle Loading List';
    Editable = True;
    CardPageId = "Vehicle Loading Card";
    SourceTableView = sorting("Loading Date") order(descending);

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
                Promoted = true;
                PromotedCategory = Process;
                ShortcutKey = 'Return';

                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Vehicle Loading Card", Rec);
                end;
            }

            action("Create New")
            {
                Caption = 'Create New Loading Sheet';
                ApplicationArea = All;
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    VehicleLoadingHeader: Record "Vehicle Loading Header";
                    VehicleLoadingCard: Page "Vehicle Loading Card";
                begin
                    VehicleLoadingHeader.Init();
                    VehicleLoadingHeader."Loading Date" := Today;
                    VehicleLoadingHeader."Status" := VehicleLoadingHeader."Status"::Planned;
                    VehicleLoadingHeader.Insert(true);

                    Commit();

                    VehicleLoadingCard.SetRecord(VehicleLoadingHeader);
                    VehicleLoadingCard.Run();
                end;
            }

            action("Filter Planned")
            {
                Caption = 'Show Planned';
                ApplicationArea = All;
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Planned);
                    CurrPage.Update(false);
                end;
            }

            action("Filter In Progress")
            {
                Caption = 'Show In Progress';
                ApplicationArea = All;
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::InProgress);
                    CurrPage.Update(false);
                end;
            }

            action("Filter Completed")
            {
                Caption = 'Show Completed';
                ApplicationArea = All;
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Completed);
                    CurrPage.Update(false);
                end;
            }

            action("Clear Filters")
            {
                Caption = 'Show All';
                ApplicationArea = All;
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                end;
            }
        }

        area(Navigation)
        {
            action("Tour Planning")
            {
                Caption = 'Tour Planning';
                ApplicationArea = All;
                Image = Planning;
                RunObject = Page "Tour Planification List";
            }
        }
    }
}
