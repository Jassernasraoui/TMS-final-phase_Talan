table 50100 "Planning Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Logistic Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Type"; Option)
        {
            OptionMembers = Sales,Purchase,Transfer;
            DataClassification = ToBeClassified;
        }
        field(4; "Source ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Variant Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Description 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Quantity (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Qty. Rounding Precision"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Qty. Rounding Precision (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Unit Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Transfer-from Code"; Code[100]) { }
        field(17; "Net Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; Status; Option)
        {
            OptionMembers = Open,Released,Completed;
            DataClassification = ToBeClassified;
        }
        field(19; "Project Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Department Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Inventory Posting Group"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Item Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Planned Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Expected Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Expected Receipt Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Created At"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Modified At"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Modified By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "System ID"; Guid)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Logistic Tour No.", "Line No.") { Clustered = true; }
    }
}
