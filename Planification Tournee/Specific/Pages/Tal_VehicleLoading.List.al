page 77010 "Vehicle Loading List"
{
    PageType = List;
    SourceTable = "Vehicle Loading Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Vehicle Loading Preparation List';
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
                Caption = 'Create New Loading Preparation';
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

            action("Filter Validated")
            {
                Caption = 'Show Validated';
                ApplicationArea = All;
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Validated);
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

            action("Clear Filter")
            {
                Caption = 'Show All';
                ApplicationArea = All;
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    Rec.SetRange(Status);
                    CurrPage.Update(false);
                end;
            }

            action("Create Vehicle Charging Sheet")
            {
                Caption = 'Create Vehicle Charging Sheet';
                ApplicationArea = All;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    VehicleChargingHeader: Record "Vehicle Charging Header";
                    VehicleChargingCard: Page "Vehicle Charging Card";
                begin
                    if Rec."Status" <> Rec."Status"::Validated then begin
                        Error('The loading preparation must be validated before creating a charging sheet.');
                        exit;
                    end;

                    // Check if a charging sheet already exists for this loading sheet
                    VehicleChargingHeader.Reset();
                    VehicleChargingHeader.SetRange("Loading Sheet No.", Rec."No.");
                    if VehicleChargingHeader.FindFirst() then begin
                        if Confirm('A vehicle charging sheet already exists for this loading preparation. Do you want to view it?') then begin
                            VehicleChargingCard.SetRecord(VehicleChargingHeader);
                            VehicleChargingCard.Run();
                        end;
                        exit;
                    end;

                    // Create new vehicle charging header
                    VehicleChargingHeader.Init();
                    VehicleChargingHeader."Loading Sheet No." := Rec."No.";
                    VehicleChargingHeader."Charging Date" := Rec."Loading Date";
                    VehicleChargingHeader."Status" := VehicleChargingHeader."Status"::InProgress;
                    VehicleChargingHeader.Insert(true);
                    VehicleChargingHeader.GetLoadingInfo();

                    // Open the new vehicle charging card
                    Message('Vehicle charging sheet %1 has been created.', VehicleChargingHeader."No.");

                    Commit();

                    VehicleChargingCard.SetRecord(VehicleChargingHeader);
                    VehicleChargingCard.Run();
                end;
            }

            action("Open Vehicle Charging List")
            {
                Caption = 'Vehicle Charging List';
                ApplicationArea = All;
                Image = TransferToLines;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Vehicle Charging List";

                trigger OnAction()
                begin
                    // This action just opens the Vehicle Charging List page
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
