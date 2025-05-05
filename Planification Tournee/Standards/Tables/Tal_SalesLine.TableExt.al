tableextension 50151 " Tal Sales Line" extends "Sales Line"
{
    fields
    {
        field(50100; "Logistic Tour No."; Code[20])
        {
            Caption = ' Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
    }
}
