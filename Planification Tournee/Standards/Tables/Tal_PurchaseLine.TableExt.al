tableextension 77006 "Tal Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(77001; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
    }
}
