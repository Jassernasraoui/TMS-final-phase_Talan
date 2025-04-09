tableextension 50148 "Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(100; "Logistic Tour Nos."; Code[20])
        {
            caption = 'Logistic Tour Nos';
            TableRelation = "No. Series";
        }
        // Add changes to table fields here
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}