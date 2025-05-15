table 77104 "Planning Optimization Suggest."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(77002; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour No.';
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
        field(77003; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line No.';
        }
        field(77004; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No.';
        }
        field(77005; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(77006; "Current Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Current Day';
        }
        field(77007; "Suggested Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Suggested Day';
        }
        field(77008; "Optimization Reason"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Optimization Reason';
        }
        field(77009; Priority; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Priority';
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }
        field(77010; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
        }
        field(77011; "Source Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Type';
            OptionMembers = Sales,Purchase,Transfer;
            OptionCaption = 'Sales,Purchase,Transfer';
        }
        field(77012; "Source ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source ID';
        }
        field(77013; Selected; Boolean)
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