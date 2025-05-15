table 77401 "Vehicle Charging Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77002; "Loading Sheet No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Vehicle Loading Header"."No." where(Status = const(Validated));
            NotBlank = true;

            trigger OnValidate()
            begin
                GetLoadingInfo();
            end;
        }
        field(77003; "Charging Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(77004; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(77005; "Truck No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(77006; "Driver No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(77007; "Loading Location"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(77008; "Start Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(77009; "End Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(77010; "Actual Weight (kg)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77011; "Actual Volume (m³)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77012; "Status"; Option)
        {
            OptionMembers = InProgress,Completed,Cancelled;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Status = Status::Completed then
                    CheckRequiredFieldsAndLines();
            end;
        }
        field(77013; "Completed By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(77014; "Completion Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(77015; "Notes"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(77016; "Released"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Released';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SK; "Loading Sheet No.")
        {
        }
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            // Make sure the no. series exists
            InitVehicleChargingNoSeries();
            // Get the next number
            "No." := NoSeriesMgt.GetNextNo('VCHARGE', Today, true);
        end;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;

    local procedure InitVehicleChargingNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Check if VCHARGE No. Series exists
        if not NoSeries.Get('VCHARGE') then begin
            // Create No. Series for Vehicle Charging
            NoSeries.Init();
            NoSeries.Code := 'VCHARGE';
            NoSeries.Description := 'Vehicle Charging Sheets';
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            if NoSeries.Insert() then;
        end;
    end;

    procedure GetLoadingInfo()
    var
        LoadingHeader: Record "Vehicle Loading Header";
    begin
        if "Loading Sheet No." <> '' then begin
            if LoadingHeader.Get("Loading Sheet No.") then begin
                "Tour No." := LoadingHeader."Tour No.";
                "Truck No." := LoadingHeader."Truck No.";
                "Driver No." := LoadingHeader."Driver No.";
                "Loading Location" := LoadingHeader."Loading Location";
                "Actual Weight (kg)" := LoadingHeader."Total Weight (kg)";
                "Actual Volume (m³)" := LoadingHeader."Total Volume (m³)";
                Modify(true);
            end;
        end;
    end;

    procedure CheckRequiredFieldsAndLines()
    var
        ErrorMsg: Text;
        ChargingLine: Record "Vehicle Charging Line";
        HasLines: Boolean;
        HasPendingLines: Boolean;
    begin
        ErrorMsg := '';

        if "Loading Sheet No." = '' then
            ErrorMsg += 'Loading Sheet No. must be specified.\';

        if "Charging Date" = 0D then
            ErrorMsg += 'Charging Date must be specified.\';

        if "Tour No." = '' then
            ErrorMsg += 'Tour No. should be populated from the loading sheet.\';

        if "Truck No." = '' then
            ErrorMsg += 'Truck No. should be populated from the loading sheet.\';

        if "Driver No." = '' then
            ErrorMsg += 'Driver No. should be populated from the loading sheet.\';

        if "Start Time" = 0T then
            ErrorMsg += 'Start Time must be specified.\';

        if "End Time" = 0T then
            "End Time" := Time;

        // Check if there are any charging lines
        ChargingLine.Reset();
        ChargingLine.SetRange("Charging No.", "No.");
        HasLines := not ChargingLine.IsEmpty();

        if not HasLines then
            ErrorMsg += 'At least one charging line must be created.\';

        // Check if there are any pending lines
        if HasLines then begin
            ChargingLine.Reset();
            ChargingLine.SetRange("Charging No.", "No.");
            ChargingLine.SetRange("Loading Status", ChargingLine."Loading Status"::Pending);
            HasPendingLines := not ChargingLine.IsEmpty();

            if HasPendingLines then
                ErrorMsg += 'All charging lines must have a loading status other than Pending.\';
        end;

        if ErrorMsg <> '' then
            Error(ErrorMsg);
    end;
}