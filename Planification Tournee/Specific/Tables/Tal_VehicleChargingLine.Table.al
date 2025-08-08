table 73602 "Vehicle Charging Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Charging No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Vehicle Charging Header"."Vehicle Charging No.";
        }
        field(77002; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(77003; "Stop No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77004; "Customer No."; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77005; "Delivery Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77006; "prepapred Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77007; "Actual Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            trigger OnValidate()
            begin
                "Quantity Difference" := "prepapred Quantity" - "Actual Quantity";
                if "Actual Quantity" > "prepapred Quantity" then
                    Error('Actual quantity cannot exceed the prepared quantity.');
            end;
        }
        field(77008; "Quantity Difference"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77009; "Remarks"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(77010; "Loading Status"; Option)
        {
            OptionMembers = Pending,Loaded,PartiallyLoaded,NotLoaded;
            DataClassification = CustomerContent;
        }
        field(77011; "Loaded By"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(77012; "Loading Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(77013; "Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            ToolTip = 'Specifies the description of the delivery.';
        }
        field(77014; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Editable = false;
        }

        field(77015; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
            Editable = false;
        }
        field(77016; "Document Type"; Option)
        {
            OptionMembers = Sales,Purchase,Transfer;
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            Editable = false;
        }
        field(77017; "Purchased Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchased Quantity';
            Editable = true;

            trigger OnValidate()
            begin
                if "Document Type" <> "Document Type"::Purchase then
                    Error('Purchased Quantity can only be set for Purchase document type.');
            end;
        }
    }

    keys
    {
        key(PK; "Charging No.", "Line No.")
        {
            Clustered = true;
        }
        key(SK; "Stop No.")
        {
        }
    }
}