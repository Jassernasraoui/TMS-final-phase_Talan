table 50101 "vehicle Stop Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Fiche No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Stop No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Delivery Address"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Estimated Arrival Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Estimated Departure Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Quantity to Deliver"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Remarks"; Text[250])
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
