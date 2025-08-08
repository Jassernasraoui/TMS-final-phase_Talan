page 73554 "Tour Activity Log ListPart"
{
    Caption = 'Journal d''Activité Tournée';
    PageType = ListPart;
    SourceTable = "Tour Activity Log";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Activity Date"; Rec."Activity Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la date de l''activité.';
                }
                field("Activity Time"; Rec."Activity Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''heure de l''activité.';
                }
                field("Activity Type"; Rec."Activity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le type d''activité.';
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la description détaillée de l''activité.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Spécifie l''identifiant de l''utilisateur qui a enregistré l''activité.';
                }
            }
        }
    }
}