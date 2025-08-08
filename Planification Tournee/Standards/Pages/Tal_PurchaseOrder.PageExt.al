pageextension 73509 "Tal Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter(Status)
        {
            field("Logistic Tour No."; Rec."Logistic Tour No.")
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the logistic tour number associated with this purchase order.';
                Caption = 'Logistic Tour No.';
            }
            field(Priority; Rec.Priority)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the priority of the purchase order.';
                Caption = 'Priority';
                Importance = Promoted;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
        }
    }
}