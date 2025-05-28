page 77120 "TMS Role Center"
{
    PageType = RoleCenter;
    Caption = 'TMS Role Center';

    layout
    {
        area(RoleCenter)
        {
            group(Group1)
            {
                part(Part1; RoleCenterHeadline)
                {
                    ApplicationArea = All;
                }

                part(Part2; TripScedulingCuePage)
                {
                    Caption = 'Trip Scheduling';
                    ApplicationArea = All;
                }
                part(ProcessWorkflow; "TMS Process Workflow")
                {
                    Caption = 'Process Workflow';
                    ApplicationArea = All;
                }
            }
        }
    }


    actions
    {
        area(Sections)
        {
            group(Setup)
            {
                Caption = 'Setup';
                Image = Setup;
                action(TripSetup)
                {
                    Caption = 'Trip Setup';
                    RunObject = Page "Trip Setup";
                    ApplicationArea = All;
                }
            }
            group(MasterData)
            {
                Caption = 'Master Data';
                Image = Setup;

                action(Resources)
                {
                    Caption = 'Resources';
                    RunObject = Page "Resource List";
                    ApplicationArea = All;
                }
                action(VehiculeResource)
                {
                    Caption = 'Vehicule Resource list';
                    RunObject = Page "Tal Vehicule Resource list";
                    ApplicationArea = All;
                }
            }

            group(TripDocument)
            {
                Caption = 'Trip Document';
                Image = Setup;
                action(TourPlanificationList)
                {
                    Caption = 'Trip Scheduling List';
                    RunObject = Page "Tour Planning List";
                    ApplicationArea = All;
                }
                action(VehicleLoadingList)
                {
                    Caption = 'Vehicle Loading List';
                    RunObject = Page "Vehicle Loading List";
                    ApplicationArea = All;
                }
                action(TourExecution)
                {
                    Caption = 'Tour Execution';
                    RunObject = Page "Tour Execution Page";
                    ApplicationArea = All;
                    Image = ExecuteBatch;
                    ToolTip = 'Execute tours with or without loading';
                }
            }

        }
    }
}







// Creates a profile that uses the Role Center
profile MyProfile
{
    ProfileDescription = 'Transport Management System : Role Center';
    RoleCenter = "TMS Role Center";
    Caption = 'TMS Role Center';
}