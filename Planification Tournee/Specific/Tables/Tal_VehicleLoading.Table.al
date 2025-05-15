table 77400 "Vehicle Loading Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77002; "Loading Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77003; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77004; "Truck No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77005; "Driver No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77006; "Loading Location"; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77007; "Departure Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(77008; "Arrival Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(77009; "Total Weight (kg)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(770010; "Total Volume (m³)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(770011; "Number of Deliveries"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(770012; "Goods Type"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(770013; "Status"; Option)
        {
            OptionMembers = Planned,Loading,InProgress,Completed,Canceled,Validated;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Status = Status::Validated then
                    CheckRequiredFields();
            end;
        }
        field(770014; "Validated By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(77015; "Validation Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(77016; "Itinerary No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77017; "Total Distance (km)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77018; "Estimated Duration"; Duration)
        {
            DataClassification = ToBeClassified;
        }
        field(77019; "Itinerary Type"; Option)
        {
            OptionMembers = Optimized,Manual,Fastest,Shortest;
            DataClassification = ToBeClassified;
        }
        field(77020; "Planned Route"; Text[250])
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

    procedure CheckRequiredFields()
    var
        ErrorMsg: Text;
        StopLine: Record "vehicle Stop Line";
        HasLines: Boolean;
    begin
        ErrorMsg := '';

        if "Loading Date" = 0D then
            ErrorMsg += 'Loading Date must be specified.\';

        if "Tour No." = '' then
            ErrorMsg += 'Tour No. must be specified.\';

        if "Truck No." = '' then
            ErrorMsg += 'Truck No. must be specified.\';

        if "Driver No." = '' then
            ErrorMsg += 'Driver No. must be specified.\';

        if "Loading Location" = '' then
            ErrorMsg += 'Loading Location must be specified.\';

        // Check if there are any stop lines
        StopLine.Reset();
        StopLine.SetRange("Fiche No.", "No.");
        HasLines := not StopLine.IsEmpty();

        if not HasLines then
            ErrorMsg += 'At least one stop line must be created.\';

        if ErrorMsg <> '' then
            Error(ErrorMsg);
    end;
}
