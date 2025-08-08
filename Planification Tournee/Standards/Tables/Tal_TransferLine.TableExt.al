tableextension 73502 "Tal Transfer Line" extends "Transfer Line"
{
    fields
    {
        field(73501; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
    }
}
