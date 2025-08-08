report 73557 "Vehicle Usage and Costs"
{
    ApplicationArea = All;
    Caption = 'Vehicle Usage and Costs';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Resources/Specific/Reports/VehicleUsageAndCosts.rdl';

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
            column(Direct_Unit_Cost; "Direct Unit Cost")
            {
            }
            column(Unit_Cost; "Unit Cost")
            {
            }
            column(Unit_Price; "Unit Price")
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }

            column(DateFilter; DateFilter)
            {
            }
            column(TotalTours; TotalTours)
            {
            }
            column(TotalDistance; TotalDistance)
            {
            }
            column(TotalMaintenanceCost; TotalMaintenanceCost)
            {
            }
            column(CostPerKilometer; CostPerKilometer)
            {
            }
            column(CostPerTour; CostPerTour)
            {
            }

            trigger OnAfterGetRecord()
            var
                VehicleMaintenance: Record "Vehicle Maintenance";
                PlanificationHeader: Record "Planification Header";
                StartDate: Date;
                EndDate: Date;
                OdometerStart: Decimal;
                OdometerEnd: Decimal;
            begin
                // Initialize counters
                TotalTours := 0;
                TotalDistance := 0;
                TotalMaintenanceCost := 0;
                CostPerKilometer := 0;
                CostPerTour := 0;

                // Parse date filter
                case DateFilterOption of
                    DateFilterOption::"All Time":
                        begin
                            StartDate := 0D;
                            EndDate := DMY2Date(31, 12, 9999);
                        end;
                    DateFilterOption::"Current Month":
                        begin
                            StartDate := CalcDate('<-CM>', WorkDate());
                            EndDate := CalcDate('<CM>', WorkDate());
                        end;
                    DateFilterOption::"Current Year":
                        begin
                            StartDate := CalcDate('<-CY>', WorkDate());
                            EndDate := CalcDate('<CY>', WorkDate());
                        end;
                    DateFilterOption::"Last 3 Months":
                        begin
                            StartDate := CalcDate('<-3M>', WorkDate());
                            EndDate := WorkDate();
                        end;
                    DateFilterOption::"Last 6 Months":
                        begin
                            StartDate := CalcDate('<-6M>', WorkDate());
                            EndDate := WorkDate();
                        end;
                    DateFilterOption::"Last 12 Months":
                        begin
                            StartDate := CalcDate('<-12M>', WorkDate());
                            EndDate := WorkDate();
                        end;
                end;

                // Calculate total tours
                PlanificationHeader.Reset();
                PlanificationHeader.SetRange("Véhicule No.", "No.");
                if StartDate <> 0D then
                    PlanificationHeader.SetFilter("Date de Tournée", '%1..%2', StartDate, EndDate);
                TotalTours := PlanificationHeader.Count;

                // Calculate total distance based on vehicle maintenance records
                VehicleMaintenance.Reset();
                VehicleMaintenance.SetRange("Vehicle No.", "No.");
                VehicleMaintenance.SetRange(Status, VehicleMaintenance.Status::Completed);
                if StartDate <> 0D then
                    VehicleMaintenance.SetFilter("Completion Date", '%1..%2', StartDate, EndDate);

                // Find the earliest and latest odometer readings in the period
                OdometerStart := 0;
                OdometerEnd := 0;

                if VehicleMaintenance.FindSet() then begin
                    // Find the earliest odometer reading
                    VehicleMaintenance.SetCurrentKey("Completion Date");
                    VehicleMaintenance.Ascending(true);
                    if VehicleMaintenance.FindFirst() then
                        OdometerStart := VehicleMaintenance."Odometer Reading";

                    // Find the latest odometer reading
                    VehicleMaintenance.Ascending(false);
                    if VehicleMaintenance.FindFirst() then
                        OdometerEnd := VehicleMaintenance."Odometer Reading";

                    // Calculate distance traveled
                    if (OdometerEnd > OdometerStart) then
                        TotalDistance := OdometerEnd - OdometerStart
                    else
                        // Fallback to estimate if we can't determine from maintenance records
                        TotalDistance := "Current kilometres" * 0.1; // Assuming 10% of current kilometers were driven in the period
                end else
                    // Fallback to estimate if no maintenance records
                    TotalDistance := "Current kilometres" * 0.1; // Assuming 10% of current kilometers were driven in the period

                // Calculate total maintenance cost
                VehicleMaintenance.Reset();
                VehicleMaintenance.SetRange("Vehicle No.", "No.");
                VehicleMaintenance.SetRange(Status, VehicleMaintenance.Status::Completed);
                if StartDate <> 0D then
                    VehicleMaintenance.SetFilter("Completion Date", '%1..%2', StartDate, EndDate);
                TotalMaintenanceCost := 0;
                if VehicleMaintenance.FindSet() then begin
                    repeat
                        TotalMaintenanceCost += VehicleMaintenance."Cost Amount";
                    until VehicleMaintenance.Next() = 0;
                end;

                // Calculate cost per kilometer and cost per tour
                if TotalDistance > 0 then
                    CostPerKilometer := TotalMaintenanceCost / TotalDistance;

                if TotalTours > 0 then
                    CostPerTour := TotalMaintenanceCost / TotalTours;
            end;

            trigger OnPreDataItem()
            begin
                case DateFilterOption of
                    DateFilterOption::"All Time":
                        DateFilter := 'All Dates';
                    DateFilterOption::"Current Month":
                        DateFilter := Format(CalcDate('<-CM>', WorkDate())) + '..' + Format(CalcDate('<CM>', WorkDate()));
                    DateFilterOption::"Current Year":
                        DateFilter := Format(CalcDate('<-CY>', WorkDate())) + '..' + Format(CalcDate('<CY>', WorkDate()));
                    DateFilterOption::"Last 3 Months":
                        DateFilter := Format(CalcDate('<-3M>', WorkDate())) + '..' + Format(WorkDate());
                    DateFilterOption::"Last 6 Months":
                        DateFilter := Format(CalcDate('<-6M>', WorkDate())) + '..' + Format(WorkDate());
                    DateFilterOption::"Last 12 Months":
                        DateFilter := Format(CalcDate('<-12M>', WorkDate())) + '..' + Format(WorkDate());
                end;
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
                    field(DateFilterOption; DateFilterOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';
                        ToolTip = 'Specifies the date filter for the report.';
                    }
                }
            }
        }
    }

    var
        DateFilterOption: Option "All Time","Current Month","Current Year","Last 3 Months","Last 6 Months","Last 12 Months";
        DateFilter: Text;
        TotalTours: Integer;
        TotalDistance: Decimal;
        TotalMaintenanceCost: Decimal;
        CostPerKilometer: Decimal;
        CostPerTour: Decimal;
        ReportTitleLbl: Label 'Vehicle Usage and Costs';

    trigger OnInitReport()
    begin
        DateFilterOption := DateFilterOption::"Last 3 Months";
    end;
}