table 77107 "vehicle Stop Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(77001; "Fiche No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(77002; "Stop No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(77003; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(77004; "Delivery Address"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(77005; "Estimated Arrival Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(77006; "Estimated Departure Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(77007; "Quantity to Deliver"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(77008; "Remarks"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Fiche No.", "Stop No.")
        {
            Clustered = true;
        }
    }
}
