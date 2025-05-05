tableextension 50152 "Purchase Line Extension" extends "Purchase Line"
{
    fields
    {
        field(50100; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
    }
}
