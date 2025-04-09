pageextension 50100 "Person " extends "Resource List"

{
    Caption = 'Person Resources List';

    // Ajout de nouveaux champs et actions ici
    layout

    {
        addlast(Control1)
        {

            field("Phone No."; rec."Phone No.")
            {
                ApplicationArea = all;
                ToolTip = 'specifies  the phone number of the person.';

            }
            field("Identity Card No."; rec."Identity Card No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the identity card number of the Person.';
            }
            field("License No."; rec."License No.")
            {
                ApplicationArea = All;
                ToolTip = 'specifies the Licence number of the person';

            }
            field("License Type"; rec."License Type")
            {
                ApplicationArea = All;
                ToolTip = 'specifies the type of license held by the person.';


            }
            field("License Expiration Date"; rec."License Expiration Date")
            {
                ApplicationArea = all;
                ToolTip = 'specifies the expiration date of license held by the person.';

            }
            field("Email"; rec.Email)
            {
                ApplicationArea = all;
                ToolTip = 'specifies the email address of the person.';

            }
            field(" Birth Date "; rec."Birth Date")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {

        modify("New Resource Group")
        {
            Visible = false;
        }
        addlast(processing)
        {
        }

    }
    trigger OnOpenPage()
    begin
        Rec.SETFILTER(Type, '%1', Rec.Type::Person);
    end;
}
