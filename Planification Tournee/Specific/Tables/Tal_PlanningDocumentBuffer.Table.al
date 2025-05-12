table 50122 "Planning Document Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Sales Order","Purchase Order","Transfer Order";
            OptionCaption = 'Sales Order,Purchase Order,Transfer Order';
        }

        field(3; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(4; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Customer,Vendor,Location;
            OptionCaption = 'Customer,Vendor,Location';
        }

        field(5; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(6; "Account Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(7; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(8; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(9; "Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(10; "Total Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(11; "Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(12; "Selected"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(13; "Priority"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }
        field(14; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour No.';
            TableRelation = "Planification Header"."Logistic Tour No.";

        }

    }

    keys
    {
        key(PK; "Line No.", "Tour No.") { }
        key(DocumentType; "Document Type", "Document No.") { }
        key(AccountInfo; "Account Type", "Account No.") { }
    }
}