table 50155 "Planning Optimization Suggest."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour No.';
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line No.';
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No.';
        }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(6; "Current Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Current Day';
        }
        field(7; "Suggested Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Suggested Day';
        }
        field(8; "Optimization Reason"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Optimization Reason';
        }
        field(9; Priority; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Priority';
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }
        field(10; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
        }
        field(11; "Source Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Type';
            OptionMembers = Sales,Purchase,Transfer;
            OptionCaption = 'Sales,Purchase,Transfer';
        }
        field(12; "Source ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source ID';
        }
        field(13; Selected; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Selected';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(TourLine; "Tour No.", "Line No.") { }
        key(Location; "Tour No.", "Location Code") { }
        key(Priority; "Tour No.", Priority) { }
    }
}