table 50100 "Planning Lines"
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

        // Champs pour l'attribution des jours et créneaux horaires
        field(33; "Assigned Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Assigned Day';
        }

        field(34; "Time Slot Start"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Time Slot Start';
        }

        field(35; "Time Slot End"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Time Slot End';
        }

        field(36; "Estimated Duration"; Duration)
        {
            DataClassification = ToBeClassified;
            Caption = 'Estimated Duration';
        }

        field(37; "Priority"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Priority';
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }

        // Champs pour le regroupement des missions
        field(38; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }

        field(39; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }

        field(40; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }

        field(41; "Geographic Coordinates"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Geographic Coordinates';
        }

        field(42; "Grouped With"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Grouped With';
            Description = 'Line No. of the main line in a group';
        }

        field(43; "Group Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Type';
            OptionMembers = "None","By Proximity","By Customer","By Type";
            OptionCaption = 'None,By Proximity,By Customer,By Type';
        }

        field(44; "Activity Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Activity Type';
            OptionMembers = "Delivery","Pickup","Service","Installation","Maintenance","Other";
            OptionCaption = 'Delivery,Pickup,Service,Installation,Maintenance,Other';
        }

        field(45; "Deadline"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Deadline';
        }

        field(46; "Selected"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Selected';
            Description = 'Used for optimization suggestions';
        }
    }

    keys
    {
        key(PK; "Logistic Tour No.", "Line No.") { Clustered = true; }
        key(AssignedDay; "Logistic Tour No.", "Assigned Day") { }
        key(Priority; "Logistic Tour No.", "Priority") { }
        key(Customer; "Logistic Tour No.", "Customer No.") { }
        key(Location; "Logistic Tour No.", "Location Code") { }
        key(ActivityType; "Logistic Tour No.", "Activity Type") { }
    }
}
