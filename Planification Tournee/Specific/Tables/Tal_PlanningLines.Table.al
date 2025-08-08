table 73611 "Planning Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(73500; "Show Calender"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Show All';
            Description = 'Show all schedule items regardless of the selected day.';
        }
        field(73501; "Logistic Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(73502; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(73503; "Type"; Option)
        {
            OptionMembers = Sales,Purchase,Transfer;
            DataClassification = ToBeClassified;
        }
        field(73504; "Source ID"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(73505; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(73506; "Variant Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(73507; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(73508; "Description 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(73509; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73510; "Quantity (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73511; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73512; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(73513; "Qty. Rounding Precision"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73514; "Qty. Rounding Precision (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73515; "Unit Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73516; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73517; "Transfer-from Code"; Code[100]) { }
        field(17; "Net Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(73518; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(73519; " Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(73520; "Expected Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(73521; "Expected Receipt Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(73522; "Created At"; DateTime)
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
        field(77031; "Customer No."; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }

        field(77032; "Vendor No."; Code[100])
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

        field(77034; "Geographic Coordinates"; Decimal)
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
        field(77043; "Account No."; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(77044; "Address"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Assigned To';
        }
        field(77045; "City"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'City';
        }
        field(77046; "State (County)"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Postal Code';
        }
        field(77047; "Country/Region Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Postal Code';
        }
        field(77048; "Ship-to Address"; text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(77049; "Is Start Location"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Start Location';
            Description = 'Indicates if this line represents the start location of the tour';
        }
        field(77050; "Is End Location"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is End Location';
            Description = 'Indicates if this line represents the end location of the tour';
        }
    }

    keys
    {
        key(PK; "Logistic Tour No.", "Line No.") { Clustered = true; }
        key(AssignedDay; "Logistic Tour No.", "Assigned Day") { }
        key(Priority; "Logistic Tour No.", "Priority") { }
        key(Customer; "Address", "Country/Region Code", "City") { }
        key(Location; "Logistic Tour No.", "Location Code") { }
        key(ActivityType; "Logistic Tour No.", "Activity Type") { }
    }

    procedure DisplayMap()
    var
        OnlineMapManagement: Codeunit "Online Map Management";
    begin
        OnlineMapManagement.MakeSelectionIfMapEnabled(Database::Customer, GetPosition());
    end;

    procedure GetFullAddress(): Text
    var
        Address: Text;
    begin
        // Construct a simple Google Maps-compatible address
        Address := Rec.Address + ', ' + Rec."State (County)" + ' ' + Rec.City + ', ' + Format(Rec."Country/Region Code");
        exit(Address);
    end;



}
