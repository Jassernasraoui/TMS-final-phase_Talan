table 73606 "Trip Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Configuration Tourné';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Logistic Tour Nos."; Code[20])
        {
            caption = 'Logistic Tour Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }

        field(3; "Loading Sheet No."; Code[20])
        {
            Caption = 'Loading Sheet Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }

        field(4; "Vehicle Charging No."; Code[20])
        {
            Caption = 'Vehicle Charging Nos';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(5; "Logistics Cutoff Time"; Time)
        {
            Caption = 'Logistics Cutoff Time';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the cutoff time for logistics operations. Documents before this time will be included in the filter.';
        }
        field(6; "Vehicle as Location"; Code[100])
        {
            Caption = 'Vehicles as Locations';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the vehicle is used as a location for the trip.';
        }
        field(7; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ToolTip = 'Specifies the location code for the trip.';
        }
        field(8; "Default Start Location"; Code[20])
        {
            Caption = 'Default Start Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ToolTip = 'Specifies the default start location for new tours.';
        }
        field(9; "Default End Location"; Code[20])
        {
            Caption = 'Default End Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ToolTip = 'Specifies the default end location for new tours.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}