table 77102 "Planning Document Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(77002; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Sales Order","Purchase Order","Transfer Order";
            OptionCaption = 'Sales Order,Purchase Order,Transfer Order';
        }

        field(77003; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(77004; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Customer,Vendor,Location;
            OptionCaption = 'Customer,Vendor,Location';
        }

        field(77005; "Account No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(77006; "Account Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(77007; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(77008; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(77009; "Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(77010; "Total Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(77011; "Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(77012; "Selected"; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = false;
        }

        field(77013; "Priority"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Low,Normal,High,Critical;
            OptionCaption = 'Low,Normal,High,Critical';
        }
        field(77014; "Tour No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour No.';
            TableRelation = "Planification Header"."Logistic Tour No.";

        }

        field(77015; "Variant Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Variant Code';
        }

        field(77016; "Description 2"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description 2';
        }

        field(77017; "Quantity (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }

        field(77018; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
        }

        field(77019; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Unit of Measure Code';
        }

        field(77020; "Qty. Rounding Precision"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            InitValue = 0;
        }

        field(77021; "Qty. Rounding Precision (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            InitValue = 0;
        }

        field(77022; "Unit Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }

        field(77023; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }

        field(77024; "Net Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }

        field(77025; "Global Dimension 1 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Global Dimension 1 Code';
        }

        field(77026; "Global Dimension 2 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Global Dimension 2 Code';
        }

        field(77027; "Dimension Set ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Dimension Set ID';
        }

        field(77028; "Expected Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Expected Shipment Date';
        }

        field(77029; "Expected Receipt Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Expected Receipt Date';
        }
    }

    keys
    {
        key(PK; "Line No.", "Tour No.") { }
        key(DocumentType; "Document Type", "Document No.") { }
        key(AccountInfo; "Account Type", "Account No.") { }
    }
}