tableextension 73507 "Tal Purchase Header" extends "Purchase Header"
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
            OptionMembers = All,Low,Normal,High,Critical;
            Caption = 'Priority';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the priority of the purchase order.';
            Editable = true;
        }
        field(73503; "Document DateTime"; DateTime)
        {
            Caption = 'Document DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the document was created.';
            Editable = true;
        }
        field(73504; "Requested Receipt DateTime"; DateTime)
        {
            Caption = 'Requested Receipt DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the vendor is requested to deliver.';
            Editable = true;
        }
    }
}