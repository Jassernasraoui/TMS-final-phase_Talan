page 73599 "Vehicle Maintenance Dashboard"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Vehicle Maintenance Dashboard';

    layout
    {
        area(Content)
        {
            group(Overview)
            {
                Caption = 'Overview';

                field(TotalVehicles; TotalVehicles)
                {
                    ApplicationArea = All;
                    Caption = 'Total Vehicles';
                    ToolTip = 'Specifies the total number of vehicles in the system.';
                    Editable = false;
                    StyleExpr = 'Strong';
                }
                field(VehiclesInMaintenance; VehiclesInMaintenance)
                {
                    ApplicationArea = All;
                    Caption = 'Vehicles In Maintenance';
                    ToolTip = 'Specifies the number of vehicles currently in maintenance.';
                    Editable = false;
                    StyleExpr = 'Ambiguous';
                }
                field(VehiclesWithOverdueMaintenance; VehiclesWithOverdueMaintenance)
                {
                    ApplicationArea = All;
                    Caption = 'Vehicles With Overdue Maintenance';
                    ToolTip = 'Specifies the number of vehicles with overdue maintenance.';
                    Editable = false;
                    StyleExpr = 'Unfavorable';
                }
                field(VehiclesWithUpcomingMaintenance; VehiclesWithUpcomingMaintenance)
                {
                    ApplicationArea = All;
                    Caption = 'Vehicles With Upcoming Maintenance (7 Days)';
                    ToolTip = 'Specifies the number of vehicles with maintenance due in the next 7 days.';
                    Editable = false;
                    StyleExpr = 'Attention';
                }
                field(TotalMaintenanceCost; TotalMaintenanceCost)
                {
                    ApplicationArea = All;
                    Caption = 'Total Maintenance Cost (YTD)';
                    ToolTip = 'Specifies the total maintenance cost for the current year.';
                    Editable = false;
                    StyleExpr = 'Strong';
                }
                field(CurrentVehicleFilter; CurrentVehicleFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Current Vehicle Filter';
                    ToolTip = 'Shows the current vehicle filter applied to the dashboard.';
                    Editable = false;
                    Visible = CurrentVehicleFilter <> '';
                    StyleExpr = 'Strong';
                }
            }
            part(VehiclesOverdueMaintenance; "Vehicles Overdue Maintenance")
            {
                ApplicationArea = All;
                Caption = 'Vehicles With Overdue Maintenance';
                UpdatePropagation = Both;
            }
            part(VehiclesUpcomingMaintenance; "Vehicles Upcoming Maintenance")
            {
                ApplicationArea = All;
                Caption = 'Vehicles With Upcoming Maintenance';
                UpdatePropagation = Both;
            }
            part(RecentMaintenanceActivities; "Recent Maintenance Activities")
            {
                ApplicationArea = All;
                Caption = 'Recent Maintenance Activities';
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("New Maintenance")
            {
                ApplicationArea = All;
                Caption = 'New Maintenance';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create a new maintenance record.';
                RunObject = page "Vehicle Maintenance Card";
                RunPageMode = Create;
            }
            action("Maintenance List")
            {
                ApplicationArea = All;
                Caption = 'Maintenance List';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the list of all maintenance records.';
                RunObject = page "Vehicle Maintenance List";
            }
            action("Clear Vehicle Filter")
            {
                ApplicationArea = All;
                Caption = 'Clear Vehicle Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Clear the current vehicle filter.';
                Visible = CurrentVehicleFilter <> '';

                trigger OnAction()
                begin
                    CurrentVehicleFilter := '';
                    CurrentVehicleNo := '';
                    CurrPage.Update(false);
                    CalculateDashboardStatistics();
                    UpdateSubpages();
                end;
            }
        }
        area(Reporting)
        {
            action("Maintenance History Report")
            {
                ApplicationArea = All;
                Caption = 'Maintenance History Report';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'View the maintenance history report.';

                trigger OnAction()
                var
                    Resource: Record Resource;
                    MaintenanceHistoryReport: Report "Vehicle Maintenance History";
                begin
                    if CurrentVehicleNo <> '' then begin
                        Resource.SetRange("No.", CurrentVehicleNo);
                        MaintenanceHistoryReport.SetTableView(Resource);
                    end;
                    MaintenanceHistoryReport.Run();
                end;
            }
            action("Maintenance KPI Report")
            {
                ApplicationArea = All;
                Caption = 'Maintenance KPI Report';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'View the maintenance KPI report.';

                trigger OnAction()
                var
                    Resource: Record Resource;
                    MaintenanceKPIReport: Report "Vehicle Maintenance KPI";
                begin
                    if CurrentVehicleNo <> '' then begin
                        Resource.SetRange("No.", CurrentVehicleNo);
                        MaintenanceKPIReport.SetTableView(Resource);
                    end;
                    MaintenanceKPIReport.Run();
                end;
            }
            action("Usage and Costs Report")
            {
                ApplicationArea = All;
                Caption = 'Usage and Costs Report';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'View the vehicle usage and costs report.';

                trigger OnAction()
                var
                    Resource: Record Resource;
                    UsageAndCostsReport: Report "Vehicle Usage and Costs";
                begin
                    if CurrentVehicleNo <> '' then begin
                        Resource.SetRange("No.", CurrentVehicleNo);
                        UsageAndCostsReport.SetTableView(Resource);
                    end;
                    UsageAndCostsReport.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateDashboardStatistics();
    end;

    var
        TotalVehicles: Integer;
        VehiclesInMaintenance: Integer;
        VehiclesWithOverdueMaintenance: Integer;
        VehiclesWithUpcomingMaintenance: Integer;
        TotalMaintenanceCost: Decimal;
        CurrentVehicleFilter: Text;
        CurrentVehicleNo: Code[20];

    local procedure CalculateDashboardStatistics()
    var
        Resource: Record Resource;
        VehicleMaintenance: Record "Vehicle Maintenance";
        TodayDate: Date;
        YearStartDate: Date;
    begin
        TodayDate := WorkDate();
        YearStartDate := DMY2Date(1, 1, Date2DMY(TodayDate, 3)); // January 1st of current year

        // Calculate total vehicles
        Resource.Reset();
        Resource.SetRange(Type, Resource.Type::Machine);
        if CurrentVehicleNo <> '' then
            Resource.SetRange("No.", CurrentVehicleNo);
        TotalVehicles := Resource.Count;

        // Calculate vehicles in maintenance
        Resource.Reset();
        Resource.SetRange(Type, Resource.Type::Machine);
        Resource.SetRange("Resource Status", Resource."Resource Status"::InMaintenance);
        if CurrentVehicleNo <> '' then
            Resource.SetRange("No.", CurrentVehicleNo);
        VehiclesInMaintenance := Resource.Count;

        // Calculate vehicles with overdue maintenance
        Resource.Reset();
        Resource.SetRange(Type, Resource.Type::Machine);
        Resource.SetFilter("Next Maintenance Date", '<%1', TodayDate);
        if CurrentVehicleNo <> '' then
            Resource.SetRange("No.", CurrentVehicleNo);
        VehiclesWithOverdueMaintenance := Resource.Count;

        // Calculate vehicles with upcoming maintenance (next 7 days)
        Resource.Reset();
        Resource.SetRange(Type, Resource.Type::Machine);
        Resource.SetFilter("Next Maintenance Date", '%1..%2', TodayDate, CalcDate('<+7D>', TodayDate));
        if CurrentVehicleNo <> '' then
            Resource.SetRange("No.", CurrentVehicleNo);
        VehiclesWithUpcomingMaintenance := Resource.Count;

        // Calculate total maintenance cost for current year
        TotalMaintenanceCost := 0;
        VehicleMaintenance.Reset();
        VehicleMaintenance.SetRange(Status, VehicleMaintenance.Status::Completed);
        VehicleMaintenance.SetFilter("Completion Date", '>=%1', YearStartDate);
        if CurrentVehicleNo <> '' then
            VehicleMaintenance.SetRange("Vehicle No.", CurrentVehicleNo);
        if VehicleMaintenance.FindSet() then
            repeat
                TotalMaintenanceCost += VehicleMaintenance."Cost Amount";
            until VehicleMaintenance.Next() = 0;
    end;

    procedure SetVehicleFilter(VehicleNo: Code[20])
    var
        Resource: Record Resource;
    begin
        CurrentVehicleNo := VehicleNo;

        if CurrentVehicleNo <> '' then begin
            if Resource.Get(CurrentVehicleNo) then
                CurrentVehicleFilter := Resource."No." + ' - ' + Resource.Name
            else
                CurrentVehicleFilter := CurrentVehicleNo;
        end else
            CurrentVehicleFilter := '';

        CalculateDashboardStatistics();
        UpdateSubpages();
    end;

    local procedure UpdateSubpages()
    var
        VehiclesOverduePage: Page "Vehicles Overdue Maintenance";
        VehiclesUpcomingPage: Page "Vehicles Upcoming Maintenance";
        RecentMaintenancePage: Page "Recent Maintenance Activities";
    begin
        if CurrentVehicleNo <> '' then begin
            CurrPage.VehiclesOverdueMaintenance.Page.SetVehicleFilter(CurrentVehicleNo);
            CurrPage.VehiclesUpcomingMaintenance.Page.SetVehicleFilter(CurrentVehicleNo);
            CurrPage.RecentMaintenanceActivities.Page.SetVehicleFilter(CurrentVehicleNo);
        end else begin
            CurrPage.VehiclesOverdueMaintenance.Page.SetVehicleFilter('');
            CurrPage.VehiclesUpcomingMaintenance.Page.SetVehicleFilter('');
            CurrPage.RecentMaintenanceActivities.Page.SetVehicleFilter('');
        end;
    end;
}