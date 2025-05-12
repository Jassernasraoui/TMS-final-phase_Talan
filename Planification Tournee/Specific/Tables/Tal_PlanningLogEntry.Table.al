table 50126 "Planning Log Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'Planning Log Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';
        }

        field(2; "Timestamps"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Timestamp';
        }

        field(3; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour No.';
            TableRelation = "Planification Header"."Logistic Tour No.";
        }

        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }

        field(5; "Source"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source';
        }

        field(6; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'User ID';
            TableRelation = User."User Name";
        }

        field(7; "Message"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Message';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Timestamps; "Timestamps") { }
        key(TourNo; "Tour No.") { }
    }
}