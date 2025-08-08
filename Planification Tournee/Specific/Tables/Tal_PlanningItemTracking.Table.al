table 73616 "Planning Item Tracking"
{
    Caption = 'Planning Item Tracking';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Planning Tour No."; Code[20])
        {
            Caption = 'Planning Tour No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Planning Line No."; Integer)
        {
            Caption = 'Planning Line No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(5; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
        }
        field(7; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            DataClassification = ToBeClassified;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(9; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "SN Required"; Boolean)
        {
            Caption = 'SN Required';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Lot Required"; Boolean)
        {
            Caption = 'Lot Required';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Package Required"; Boolean)
        {
            Caption = 'Package Required';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Tracking Code"; Code[20])
        {
            Caption = 'Tracking Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Tracking Code";
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PlanningLine; "Planning Tour No.", "Planning Line No.")
        {
        }
        key(ItemSerialLot; "Item No.", "Serial No.", "Lot No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created At" := CurrentDateTime;
    end;
}