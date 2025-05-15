table 77402 "Vehicle Charging Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Charging No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Vehicle Charging Header"."No.";
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
        field(77004; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77005; "Delivery Address"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77006; "Planned Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77007; "Actual Quantity"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Quantity Difference" := "Actual Quantity" - "Planned Quantity";
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