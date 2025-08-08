tableextension 73508 "Tal Transfer Header" extends "Transfer Header"
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
            ToolTip = 'Specifies the priority of the transfer order.';
            Editable = true;
        }
        field(73503; "Document DateTime"; DateTime)
        {
            Caption = 'Document DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the document was created.';
            Editable = true;
        }
        field(73504; "Requested Shipment DateTime"; DateTime)
        {
            Caption = 'Requested Shipment DateTime';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date and time when the shipment is requested.';
            Editable = true;
        }
        field(73505; "Return Transfer"; Boolean)
        {
            Caption = 'Transfert Retour';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if this is a return transfer order for returned quantities.';
            Editable = true;
        }
    }
}