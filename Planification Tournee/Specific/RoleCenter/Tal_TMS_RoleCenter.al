page 73620 "TMS Role Center"
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
                part(Control1901851508; "SO Processor Activities")
                {
                    AccessByPermission = TableData "Sales Shipment Header" = R;
                    ApplicationArea = Basic, Suite;
                }
                part(Control1; "Trailing Sales Orders Chart")
                {
                    AccessByPermission = TableData "Sales Shipment Header" = R;
                    ApplicationArea = Basic, Suite;
                }
                part(Control55; "Help And Chart Wrapper")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '';
                }
                part(ProcessWorkflow; "TMS Process Workflow")
                {
                    Caption = 'Process Workflow';
                    ApplicationArea = All;
                }
                part(Control2; "Power BI Embedded Report Part")
                {
                    Caption = 'Power BI Report';
                    ApplicationArea = All;
                    ToolTip = 'Power BI Report';
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
                action(locationSetup)
                {
                    RunObject = page "Tal Locations Setup";
                    ApplicationArea = all;
                }
            }
            group(MasterData)
            {
                Caption = 'Master Data';
                Image = Setup;

                action(Resources)
                {
                    Caption = 'Person Resources';
                    RunObject = Page "Resource List";
                    ApplicationArea = All;
                }
                action(VehiculeResource)
                {
                    Caption = 'Vehicule Resource';
                    RunObject = Page "Tal Vehicule Resource list";
                    ApplicationArea = All;
                }
                action(customers)
                {
                    Caption = 'Customers';
                    RunObject = Page "Customer List";
                    ApplicationArea = All;
                }
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "Item List";
                    ApplicationArea = All;
                }
                action(salesOrders)
                {
                    Caption = 'Sales Orders';
                    RunObject = Page "Sales Order List";
                    ApplicationArea = All;
                }

                action(purchaseOrders)
                {
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                    ApplicationArea = All;
                }
                action(transferOrders)
                {
                    Caption = 'Transfer Orders';
                    RunObject = Page "Transfer Orders";
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
                action(VehicleChargingList)
                {
                    Caption = 'Vehicle charging List';
                    RunObject = Page "Vehicle charging List";
                    ApplicationArea = All;
                }
                action(TourExecution)
                {
                    Caption = 'Trip Execution';
                    RunObject = Page "Tour Execution Tracking List";
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