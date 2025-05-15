tableextension 77002 "Tal Transfer Line" extends "Transfer Line"
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
