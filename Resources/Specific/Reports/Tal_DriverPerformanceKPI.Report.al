report 73615 "Tal Driver Performance KPI"
{
    ApplicationArea = All;
    Caption = 'Driver Performance KPI';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = DriverPerformanceKPI;

    dataset
    {
        dataitem(Resource; Resource)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Person));
            RequestFilterFields = "No.", "License No.";

            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ReportTitle; 'Driver Performance KPI Report')
            {
            }
            column(DateFilter; DateFilterText)
            {
            }
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(License_No; "License No.")
            {
            }
            column(TotalTrips; TotalTrips)
            {
            }
            column(OnTimePercentage; OnTimePercentage)
            {
            }
            column(OnTimePercentageFormats; Format(OnTimePercentage, 0, '<Precision,2:2><Standard Format,0>'))
            {
                // Format percentage with 2 decimal places
            }
            column(FuelEfficiency; FuelEfficiency)
            {
            }
            column(FuelEfficiencyFormats; Format(FuelEfficiency, 0, '<Precision,2:2><Standard Format,0>'))
            {
                // Format fuel efficiency with 2 decimal places
            }
            column(SafetyScore; SafetyScore)
            {
            }
            column(SafetyScoreFormats; Format(SafetyScore, 0, '<Precision,1:1><Standard Format,0>'))
            {
                // Format safety score with 1 decimal place
            }
            column(PerformanceRating; PerformanceRating)
            {
            }

            trigger OnAfterGetRecord()
            var
                TourHeader: Record "Planification Header";
                TourLine: Record "Planning Lines";
                OnTimeCount: Integer;
                TotalDistance: Decimal;
                TotalFuel: Decimal;
            begin
                // Initialize variables
                TotalTrips := 0;
                OnTimePercentage := 0;
                FuelEfficiency := 0;
                SafetyScore := 0;
                PerformanceRating := 'NEW';

                // Calculate total trips and on-time percentage
                TourHeader.Reset();
                TourHeader.SetRange("Driver No.", "No.");
                if DateFilter <> '' then
                    TourHeader.SetFilter("Date de Tournée", DateFilter);
                TourHeader.SetRange(Statut, TourHeader.Statut::Completed);
                
                if TourHeader.FindSet() then begin
                    TotalTrips := TourHeader.Count;
                    OnTimeCount := 0;
                    TotalDistance := 0;
                    TotalFuel := 0;
                    
                    repeat
                        // Count on-time deliveries
                        if TourHeader."Actual End Time" <= TourHeader."Planned End Time" then
                            OnTimeCount += 1;
                            
                        // Sum up distance and fuel for efficiency calculation
                        TotalDistance += TourHeader."Total Distance";
                        TotalFuel += TourHeader."Fuel Consumption";
                        
                        // Add to safety score (based on incidents, violations, etc.)
                        // This is a placeholder - actual implementation would depend on how safety data is stored
                        if TourHeader."Incidents Count" = 0 then
                            SafetyScore += 10
                        else
                            SafetyScore += (10 - TourHeader."Incidents Count");
                            
                    until TourHeader.Next() = 0;
                    
                    // Calculate metrics
                    if TotalTrips > 0 then begin
                        OnTimePercentage := (OnTimeCount * 100) / TotalTrips;
                        SafetyScore := SafetyScore / TotalTrips;
                        
                        // Calculate fuel efficiency (km/l)
                        if TotalFuel > 0 then
                            FuelEfficiency := TotalDistance / TotalFuel;
                            
                        // Determine performance rating
                        if (OnTimePercentage >= 90) and (SafetyScore >= 9) and (FuelEfficiency >= 8) then
                            PerformanceRating := 'EXCELLENT'
                        else if (OnTimePercentage >= 80) and (SafetyScore >= 7) and (FuelEfficiency >= 6) then
                            PerformanceRating := 'GOOD'
                        else if (OnTimePercentage >= 70) and (SafetyScore >= 5) and (FuelEfficiency >= 4) then
                            PerformanceRating := 'AVERAGE'
                        else
                            PerformanceRating := 'POOR';
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                DateFilterText := GetFilter("Date Filter");
                if DateFilterText = '' then begin
                    SetRange("Date Filter", CalcDate('<-30D>', WorkDate()), WorkDate());
                    DateFilterText := GetFilter("Date Filter");
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DateFilter; DateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';
                        ToolTip = 'Specifies the date range for the report';
                    }
                }
            }
        }
    }

    rendering
    {
        layout(DriverPerformanceKPI)
        {
            Type = RDLC;
            LayoutFile = './Resources/Specific/Reports/DriverPerformanceKPI.rdl';
            Caption = 'Driver Performance KPI';
            Summary = 'Shows performance metrics for drivers';
        }
    }

    var
        DateFilter: Text;
        DateFilterText: Text;
        TotalTrips: Integer;
        OnTimePercentage: Decimal;
        FuelEfficiency: Decimal;
        SafetyScore: Decimal;
        PerformanceRating: Text;
}