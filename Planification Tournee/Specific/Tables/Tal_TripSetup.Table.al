table 77106 "Trip Setup"
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
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}