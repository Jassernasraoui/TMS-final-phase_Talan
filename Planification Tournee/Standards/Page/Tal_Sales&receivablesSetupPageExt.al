pageextension 50180 "Sales& rece" extends "Sales & Receivables Setup"
{
    layout
    {


        addbefore("Customer Nos.")
        {
            field(Tournee; Rec."Logistic Tour Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Spécifice the Planned Tour Numbers that will be assigned for each saving';
                // TableRelation = "No. Series";
            }
        }
    }
}
