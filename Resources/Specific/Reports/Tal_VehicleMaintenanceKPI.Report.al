report 73556 "Vehicle Maintenance KPI"
{
    ApplicationArea = All;
    Caption = 'Vehicle Maintenance KPI';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Resources/Specific/Reports/VehicleMaintenanceKPI.rdl';
    
    dataset
    {
        dataitem(Resource; Resource)
        {
            DataItemTableView = where(Type = const(Machine));
            RequestFilterFields = "No.", "vehicle Type";
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(License_plate_No_; " License plate No.")
            {
            }
            column(vehicle_Type; "vehicle Type")
            {
            }
            column(Current_kilometres; "Current kilometres")
            {
            }
            column(Last_Maintenance_Date; "Last Maintenance Date")
            {
            }
            column(Next_Maintenance_Date; "Next Maintenance Date")
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
            column(TotalMaintenanceCost; TotalMaintenanceCost)
            {
            }
            column(MaintenanceCount; MaintenanceCount)
            {
            }
            column(AverageCostPerMaintenance; AverageCostPerMaintenance)
            {
            }
            column(DaysSinceLastMaintenance; DaysSinceLastMaintenance)
            {
            }
            column(DaysUntilNextMaintenance; DaysUntilNextMaintenance)
            {
            }
            column(MaintenanceStatusText; MaintenanceStatusText)
            {
            }
            
            trigger OnAfterGetRecord()
            var
                VehicleMaintenance: Record "Vehicle Maintenance";
                TodayDate: Date;
            begin
                // Reset counters for each vehicle
                TotalMaintenanceCost := 0;
                MaintenanceCount := 0;
                AverageCostPerMaintenance := 0;
                DaysSinceLastMaintenance := 0;
                DaysUntilNextMaintenance := 0;
                MaintenanceStatusText := '';
                
                // Calculate total maintenance cost and count
                VehicleMaintenance.Reset();
                VehicleMaintenance.SetRange("Vehicle No.", "No.");
                VehicleMaintenance.SetRange(Status, VehicleMaintenance.Status::Completed);
                if VehicleMaintenance.FindSet() then begin
                    repeat
                        TotalMaintenanceCost += VehicleMaintenance."Cost Amount";
                        MaintenanceCount += 1;
                    until VehicleMaintenance.Next() = 0;
                end;
                
                // Calculate average cost per maintenance
                if MaintenanceCount > 0 then
                    AverageCostPerMaintenance := TotalMaintenanceCost / MaintenanceCount;
                
                // Calculate days since last maintenance and until next maintenance
                TodayDate := WorkDate();
                if "Last Maintenance Date" <> 0D then
                    DaysSinceLastMaintenance := TodayDate - "Last Maintenance Date";
                    
                if "Next Maintenance Date" <> 0D then
                    DaysUntilNextMaintenance := "Next Maintenance Date" - TodayDate;
                
                // Set maintenance status text
                if "Next Maintenance Date" <> 0D then begin
                    if DaysUntilNextMaintenance < 0 then
                        MaintenanceStatusText := 'OVERDUE'
                    else if DaysUntilNextMaintenance <= 7 then
                        MaintenanceStatusText := 'DUE SOON'
                    else
                        MaintenanceStatusText := 'OK';
                end else
                    MaintenanceStatusText := 'NOT SCHEDULED';
            end;
            
            trigger OnPreDataItem()
            begin
                DateFilter := Resource.GetFilter("Last Maintenance Date");
                if DateFilter = '' then
                    DateFilter := 'All Dates';
                
                // Apply filter for overdue maintenance if option is selected
                if ShowOnlyOverdue then
                    Resource.SetFilter("Next Maintenance Date", '<%1', WorkDate());
            end;
        }
    }
    
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowOnlyOverdue; ShowOnlyOverdue)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Only Overdue';
                        ToolTip = 'Specifies if only vehicles with overdue maintenance should be included in the report.';
                    }
                }
            }
        }
    }
    
    var
        ShowOnlyOverdue: Boolean;
        DateFilter: Text;
        TotalMaintenanceCost: Decimal;
        MaintenanceCount: Integer;
        AverageCostPerMaintenance: Decimal;
        DaysSinceLastMaintenance: Integer;
        DaysUntilNextMaintenance: Integer;
        MaintenanceStatusText: Text;
        ReportTitleLbl: Label 'Vehicle Maintenance KPI';
}