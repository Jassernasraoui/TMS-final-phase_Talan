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

        // field(2; "Série Fiches Chargement"; Code[20])
        // {
        //     Caption = 'Série Fiches Chargement';
        //     TableRelation = "No. Series";
        //     DataClassification = CustomerContent;
        // }
        // field(3; "Série Itinéraires"; Code[20])
        // {
        //     Caption = 'Série Itinéraires';
        //     TableRelation = "No. Series";
        //     DataClassification = CustomerContent;
        // }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}