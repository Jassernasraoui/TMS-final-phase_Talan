page 73510 "Tour Statistics FactBox"
{
    Caption = 'Tour Statistics';
    PageType = CardPart;
    SourceTable = "Planification Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field("Logistic Tour No."; Rec."Logistic Tour No.")
            {
                ApplicationArea = All;
                Caption = 'Tour No.';
                ToolTip = 'Specifies the unique identifier for this tour.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            field("Total Quantity"; Rec."Total Quantity")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total Quantity';
                ToolTip = 'Specifies the total quantity of all planning lines in this tour.';

                trigger OnDrillDown()
                begin
                    DrillDownPlanningLines();
                end;
            }
            field("Estimated Total Weight"; Rec."Estimated Total Weight")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Estimated Total Weight (kg)';
                ToolTip = 'Shows the estimated total weight for all items in this tour.';

                trigger OnDrillDown()
                begin
                    DrillDownPlanningLines();
                end;
            }
            field("Estimated Distance"; Rec."Estimated Distance")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Estimated Distance (km)';
                ToolTip = 'Shows the estimated total distance for this tour.';
            }
            field("Estimated Duration"; Rec."Estimated Duration")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Estimated Duration (hrs)';
                ToolTip = 'Shows the estimated total duration for this tour.';
            }
            field("No. of Planning Lines"; Rec."No. of Planning Lines")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'No. of Planning Lines';
                ToolTip = 'Specifies the number of planning lines for this tour.';

                trigger OnDrillDown()
                begin
                    DrillDownPlanningLines();
                end;
            }
            field("No. of Vehicle Loadings"; CalcVehicleLoadings())
            {
                ApplicationArea = All;
                Caption = 'No. of Vehicle Loadings';
                ToolTip = 'Specifies the number of vehicle loading preparations created for this tour.';

                trigger OnDrillDown()
                begin
                    DrillDownVehicleLoadings();
                end;
            }
            field("Document Date"; Rec."Document Date")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Document Date';
                ToolTip = 'Specifies the date when the tour was last modified.';
            }
            field(TotalTourCost; TotalTourCost)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total Estimated Cost (LCY)';
                ToolTip = 'Specifies the estimated total cost of the tour based on planning lines and vehicle loadings.';
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Total Quantity", "No. of Planning Lines");
    end;

    // trigger OnAfterGetRecord()
    // begin
    //     TotalTourCost := CalculateTotalTourCost();
    // end;

    var
        TotalTourCost: Decimal;

    local procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Planification Document", Rec);
    end;

    local procedure DrillDownPlanningLines()
    var
        PlanningLine: Record "Planning Lines";
        PlanningLinesPage: Page "Planning Lines";
    begin
        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        PlanningLinesPage.SetTableView(PlanningLine);
        PlanningLinesPage.Run();
    end;

    local procedure DrillDownVehicleLoadings()
    var
        VehicleLoadingHeader: Record "Vehicle Loading Header";
        VehicleLoadingMgtPage: Page "Vehicle Loading Management";
    begin
        VehicleLoadingHeader.SetRange("Tour No.", Rec."Logistic Tour No.");
        VehicleLoadingMgtPage.SetTableView(VehicleLoadingHeader);
        VehicleLoadingMgtPage.Run();
    end;

    local procedure CalcVehicleLoadings(): Integer
    var
        VehicleLoadingHeader: Record "Vehicle Loading Header";
    begin
        VehicleLoadingHeader.SetRange("Tour No.", Rec."Logistic Tour No.");
        exit(VehicleLoadingHeader.Count);
    end;

    // local procedure CalculateTotalTourCost(): Decimal
    // var
    //     PlanningLine: Record "Planning Lines";
    //     VehicleLoadingHeader: Record "Vehicle Loading Header";
    //     TotalCost: Decimal;
    // begin
    //     // Calculate cost from planning lines (assuming a cost field exists, e.g., "Line Cost")
    //     PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
    //     if PlanningLine.FindSet() then
    //         repeat
    //             TotalCost += PlanningLine."" * PlanningLine.Quantity; // Adjust field name as per table definition
    //         until PlanningLine.Next() = 0;

    //     // Add any additional costs from vehicle loadings if applicable
    //     VehicleLoadingHeader.SetRange("Tour No.", Rec."Logistic Tour No.");
    //     if VehicleLoadingHeader.FindSet() then
    //         repeat
    //             TotalCost += VehicleLoadingHeader."Loading Cost"; // Adjust field name as per table definition
    //         until VehicleLoadingHeader.Next() = 0;

    //     exit(TotalCost);
    // end;
}