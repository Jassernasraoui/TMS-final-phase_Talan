table 77101 "Planning Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Logistic Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77002; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(77003; "Type"; Option)
        {
            OptionMembers = Sales,Purchase,Transfer;
            DataClassification = ToBeClassified;
        }
        field(77004; "Source ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77005; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77006; "Variant Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(77007; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(77008; "Description 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(77009; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77010; "Quantity (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77011; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77012; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(77013; "Qty. Rounding Precision"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77014; "Qty. Rounding Precision (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77015; "Unit Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77016; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77017; "Transfer-from Code"; Code[100]) { }
        field(17; "Net Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(77018; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(77019; " Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(77020; "Expected Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(77021; "Expected Receipt Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(77022; "Created At"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(77023; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(77024; "Modified At"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(77025; "Modified By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }

        // Champs pour l'attribution des jours et créneaux horaires
        field(77026; "Assigned Day"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Assigned Day';
        }

        field(77027; "Time Slot Start"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Time Slot Start';
        }

        field(77028; "Time Slot End"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Time Slot End';
        }

        field(77029; "Estimated Duration"; Duration)
        {
            DataClassification = ToBeClassified;
            Caption = 'Estimated Duration';
        }

        field(77030; "Priority"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Priority';
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }

        // Champs pour le regroupement des missions
        field(77031; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }

        field(77032; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }

        field(77033; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }

        field(77034; "Geographic Coordinates"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Geographic Coordinates';
        }

        field(77035; "Grouped With"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Grouped With';
            Description = 'Line No. of the main line in a group';
        }

        field(77036; "Group Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Type';
            OptionMembers = "None","By Proximity","By Customer","By Type";
            OptionCaption = 'None,By Proximity,By Customer,By Type';
        }

        field(77037; "Activity Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Activity Type';
            OptionMembers = "Delivery","Pickup","Service","Installation","Maintenance","Other";
            OptionCaption = 'Delivery,Pickup,Service,Installation,Maintenance,Other';
        }

        field(77038; "Deadline"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Deadline';
        }

        field(77039; "Selected"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Selected';
            Description = 'Used for optimization suggestions';
        }
        field(77040; Status; Option)
        {
            OptionMembers = Open,Released,Completed;
            DataClassification = ToBeClassified;
        }
        field(77041; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));

            // trigger OnValidate()
            // begin
            //     Rec.ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            // end;
        }
        field(77042; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

            // trigger OnValidate()
            // begin
            //     Rec.ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            // end;
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
