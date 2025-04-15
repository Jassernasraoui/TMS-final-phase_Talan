pageextension 50101 " TAL_PersonResource Card" extends "Resource Card"
{
    layout
    {
        modify(Type)
        { Editable = false; }
        modify(Education)
        { Visible = false; }
        modify("Address 2")
        { Visible = false; }
        modify("Job Title")
        { Visible = false; }
        modify("Social Security No.")
        { Visible = true; }
        moveafter(General; "Personal Data")
        addlast(General)
        {

        }
        addlast("Personal Data")
        {
            field(" Birth Date "; rec."Birth Date")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the date of birth of the Person.';

            }
            field("Identity Card No."; rec."Identity Card No.")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the identity card number of the Person.';


            }
            field("additional certifications"; rec."Additional Certifications")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies any additional certifications held by the person ';
            }
            group("Personal Contact")

            {
                field("Phone No."; rec."Phone No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies  the phone number of the person.';

                }
                field("Email"; rec.Email)
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies the email address of the person.';

                }
            }
            group("License Details")
            {
                field("License No."; rec."License No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'specifies the License number of the person';
                }
                field("License Type"; rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'specifies the type of License held by the person.';

                }
                field("License Expiration Date"; rec."License Expiration Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'specifies the expiration date of license held by the person.';

                }
            }
        }
    }

    actions
    {

    }
    trigger OnOpenPage()
    begin
        if Rec.Type <> Rec.Type::Person then begin
            Rec.Type := Rec.Type::Person;
            Rec.Modify(); // Enregistre la modification dans la base de données
        end;
    end;
}
