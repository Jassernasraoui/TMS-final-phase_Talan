table 50132 "Truck Loading Header"
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
            OptionMembers = Planned,Loading,InProgress,Completed,Canceled;
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
}
