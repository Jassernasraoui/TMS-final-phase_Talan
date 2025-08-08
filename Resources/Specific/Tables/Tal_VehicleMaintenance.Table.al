table 73657 "Vehicle Maintenance"
{
    DataClassification = CustomerContent;
    Caption = 'Vehicle Maintenance';
    LookupPageId = "Vehicle Maintenance List";
    DrillDownPageId = "Vehicle Maintenance List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
            TableRelation = Resource where(Type = const(Machine));
        }
        field(3; "Maintenance Type"; Enum "Vehicle Maintenance Type")
        {
            Caption = 'Maintenance Type';
            DataClassification = CustomerContent;
        }
        field(4; "Maintenance Date"; Date)
        {
            Caption = 'Maintenance Date';
            DataClassification = CustomerContent;
        }
        field(5; "Scheduled Date"; Date)
        {
            Caption = 'Scheduled Date';
            DataClassification = CustomerContent;
        }
        field(6; "Completion Date"; Date)
        {
            Caption = 'Completion Date';
            DataClassification = CustomerContent;
        }
        field(7; Status; Enum "Vehicle Maintenance Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; "Service Provider"; Text[100])
        {
            Caption = 'Service Provider';
            DataClassification = CustomerContent;
        }
        field(10; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            DataClassification = CustomerContent;
        }
        field(11; "Odometer Reading"; Decimal)
        {
            Caption = 'Odometer Reading';
            DataClassification = CustomerContent;
        }
        field(12; "Next Service Due"; Date)
        {
            Caption = 'Next Service Due';
            DataClassification = CustomerContent;
        }
        field(13; "Next Service Odometer"; Decimal)
        {
            Caption = 'Next Service Odometer';
            DataClassification = CustomerContent;
        }
        field(14; Notes; Text[2048])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(VehicleNo; "Vehicle No.", "Maintenance Date")
        {
        }
        key(Status; Status, "Scheduled Date")
        {
        }
    }

    trigger OnInsert()
    var
        Resource: Record Resource;
    begin
        if Resource.Get("Vehicle No.") then begin
            Resource."Last Maintenance Date" := "Maintenance Date";
            Resource."Next Maintenance Date" := "Next Service Due";
            Resource.Modify();
        end;
    end;

    trigger OnModify()
    var
        Resource: Record Resource;
    begin
        if (Status = Status::Completed) and (Resource.Get("Vehicle No.")) then begin
            Resource."Last Maintenance Date" := "Maintenance Date";
            Resource."Next Maintenance Date" := "Next Service Due";
            Resource.Modify();
        end;
    end;
}