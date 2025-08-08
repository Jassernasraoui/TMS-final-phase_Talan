pageextension 73510 "Tal Transfer Order" extends "Transfer Order"
{
    layout
    {
        addafter(Status)
        {
            field("Logistic Tour No."; Rec."Logistic Tour No.")
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the logistic tour number associated with this transfer order.';
                Caption = 'Logistic Tour No.';
            }
            field(Priority; Rec.Priority)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the priority of the transfer order.';
                Caption = 'Priority';
                Importance = Promoted;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
            field("Return Transfer"; Rec."Return Transfer")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this is a return transfer order for returned quantities.';
                Caption = 'Transfert Retour';
                Importance = Promoted;
                Editable = false;
                Style = Strong;
                StyleExpr = Rec."Return Transfer";
                //Bilel : check for returned sales/pyrchase order ken najmou na3mlouha
            }
        }
    }
}