table 73512 "Tour Activity Log"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'N° Séquence';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Tour No."; Code[20])
        {
            Caption = 'N° Tournée';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
        field(3; "Activity Date"; Date)
        {
            Caption = 'Date Activité';
            DataClassification = CustomerContent;
        }
        field(4; "Activity Time"; Time)
        {
            Caption = 'Heure Activité';
            DataClassification = CustomerContent;
        }
        field(5; "Activity Type"; Text[100])
        {
            Caption = 'Type Activité';
            DataClassification = CustomerContent;
        }
        field(6; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'ID Utilisateur';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Tour No.", "Activity Date", "Activity Time")
        {
        }
    }
}
