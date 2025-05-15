page 77024 "Vehicle Loading Management"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Vehicle Loading Management';

    layout
    {
        area(Content)
        {
            group(Overview)
            {
                Caption = 'Vehicle Loading Process Overview';

                part(PreparationList; "Vehicle Loading List")
                {
                    Caption = 'Loading Preparation';
                    ApplicationArea = All;
                }

                part(ChargingList; "Vehicle Charging List")
                {
                    Caption = 'Vehicle Charging';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewPreparation)
            {
                Caption = 'New Loading Preparation';
                ApplicationArea = All;
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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

                    CurrPage.Update(false);
                end;
            }

            action(NewCharging)
            {
                Caption = 'New Vehicle Charging';
                ApplicationArea = All;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    VehicleChargingHeader: Record "Vehicle Charging Header";
                    VehicleChargingCard: Page "Vehicle Charging Card";
                begin
                    VehicleChargingHeader.Init();
                    VehicleChargingHeader."Charging Date" := Today;
                    VehicleChargingHeader."Status" := VehicleChargingHeader."Status"::InProgress;
                    VehicleChargingHeader.Insert(true);

                    Commit();

                    VehicleChargingCard.SetRecord(VehicleChargingHeader);
                    VehicleChargingCard.Run();

                    CurrPage.Update(false);
                end;
            }

            action(Refresh)
            {
                Caption = 'Refresh';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }

        area(Navigation)
        {
            action(GoToPreparationList)
            {
                Caption = 'All Loading Preparations';
                ApplicationArea = All;
                Image = List;
                RunObject = Page "Vehicle Loading List";
            }

            action(GoToChargingList)
            {
                Caption = 'All Vehicle Chargings';
                ApplicationArea = All;
                Image = List;
                RunObject = Page "Vehicle Charging List";
            }
        }
    }
}