page 73522 "Vehicle Charging List"
{
    PageType = List;
    SourceTable = "Vehicle Charging Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Vehicle Charging List';
    Editable = True;
    CardPageId = "Vehicle Charging Card";
    SourceTableView = sorting("Charging Date") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."Vehicle Charging No.") { ApplicationArea = All; }
                field("Loading Sheet No."; Rec."Loading Sheet No.") { ApplicationArea = All; }
                field("Charging Date"; Rec."Charging Date") { ApplicationArea = All; }
                field("Tour No."; Rec."Tour No.") { ApplicationArea = All; }
                field("Truck No."; Rec."Truck No.") { ApplicationArea = All; }
                field("Driver No."; Rec."Driver No.") { ApplicationArea = All; }
                field("Loading Location"; Rec."Loading Location") { ApplicationArea = All; }
                field("Start Time"; Rec."Start Time") { ApplicationArea = All; }
                field("End Time"; Rec."End Time") { ApplicationArea = All; }
                field("Actual Weight (kg)"; Rec."Actual Weight (kg)") { ApplicationArea = All; }
                field("Actual Volume (m³)"; Rec."Actual Volume (m³)") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Completion Date"; Rec."Completion Date") { ApplicationArea = All; }
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
                    PAGE.Run(PAGE::"Vehicle Charging Card", Rec);
                end;
            }

            action("Create New")
            {
                Caption = 'Create New Charging Sheet';
                ApplicationArea = All;
                Image = New;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    VehicleChargingHeader: Record "Vehicle Charging Header";
                    VehicleChargingCard: Page "Vehicle Charging Card";
                    PlanHeader: Record "Planification Header";
                begin
                    VehicleChargingHeader.Init();
                    VehicleChargingHeader."Charging Date" := Today;
                    VehicleChargingHeader."Status" := VehicleChargingHeader."Status"::InProgress;
                    VehicleChargingHeader.Status := PlanHeader.Statut::Inprogress;
                    VehicleChargingHeader.Insert(true);

                    Commit();

                    VehicleChargingCard.SetRecord(VehicleChargingHeader);
                    VehicleChargingCard.Run();
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
        }
    }
}