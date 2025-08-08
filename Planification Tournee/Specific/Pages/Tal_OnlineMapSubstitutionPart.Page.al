page 73651 "Online Map Substitution Part"
{
    Caption = 'Online Map Substitution Parameter';
    PageType = ListPart;
    SourceTable = "Online Map Substitution";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Parameter ID"; Rec."Parameter ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the ID of the parameter.';
                }
                field("Parameter Name"; Rec."Parameter Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the parameter.';
                }
            }
        }
    }
}