table 50132 "Vehicle Loading Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Loading Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Truck No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Driver No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Loading Location"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Departure Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Arrival Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Total Weight (kg)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Total Volume (m³)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Number of Deliveries"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Goods Type"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Status"; Option)
        {
            OptionMembers = Planned,Loading,InProgress,Completed,Canceled,Validated;
            DataClassification = ToBeClassified;
        }
        field(14; "Validated By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Validation Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Itinerary No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Total Distance (km)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Estimated Duration"; Duration)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Itinerary Type"; Option)
        {
            OptionMembers = Optimized,Manual,Fastest,Shortest;
            DataClassification = ToBeClassified;
        }
        field(20; "Planned Route"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            // Make sure the no. series exists
            InitVehicleLoadingNoSeries();
            // Get the next number
            "No." := NoSeriesMgt.GetNextNo('VLOAD', Today, true);
        end;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;

    local procedure InitVehicleLoadingNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Check if VLOAD No. Series exists
        if not NoSeries.Get('VLOAD') then begin
            // Create No. Series for Vehicle Loading
            NoSeries.Init();
            NoSeries.Code := 'VLOAD';
            NoSeries.Description := 'Vehicle Loading Sheets';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            if NoSeries.Insert() then;

            // Create No. Series Line
            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'VLOAD';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'VL-0001';
            NoSeriesLine."Ending No." := 'VL-9999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine."Last No. Used" := '';
            if NoSeriesLine.Insert() then;
        end;
    end;
}
