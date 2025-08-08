tableextension 73504 "Tal Sales Header" extends "Sales header"
{
    fields
    {
        field(73501; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
        field(73502; "Priority"; Option)
        {
            OptionMembers = Low,Normal,High,Critical;
            Caption = 'Priority';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the priority of the sales order.';
            Editable = true;
        }
        field(73503; "Document DateTime"; DateTime)
        {
            Caption = 'Document DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the document was created.';
            Editable = true;
        }
    }
    trigger OnInsert()
    begin
        "Document DateTime" := CurrentDateTime;

    end;




}
