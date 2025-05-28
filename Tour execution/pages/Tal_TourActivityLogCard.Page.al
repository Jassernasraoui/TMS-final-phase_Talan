page 77058 "Tour Activity Log Card"
{
    Caption = 'Fiche Journal d''Activité';
    PageType = Card;
    SourceTable = "Tour Activity Log";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Général';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le numéro de séquence unique de l''entrée du journal d''activité.';
                }
                field("Tour No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie le numéro de la tournée associée à cette activité.';
                }
                field("Activity Date"; Rec."Activity Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la date à laquelle l''activité a eu lieu.';
                }
                field("Activity Time"; Rec."Activity Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''heure à laquelle l''activité a eu lieu.';
                }
                field("Activity Type"; Rec."Activity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le type d''activité enregistré.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Spécifie l''identifiant de l''utilisateur qui a enregistré l''activité.';
                }
            }
            group(Details)
            {
                Caption = 'Détails';

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Spécifie la description détaillée de l''activité.';
                }
            }
        }
        area(FactBoxes)
        {
            part(TourDetails; "Tour Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Logistic Tour No." = field("Tour No.");
                Caption = 'Détails de la Tournée';
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Tour Card")
            {
                ApplicationArea = All;
                Caption = 'Fiche Tournée';
                Image = Document;
                RunObject = Page "Planification Document";
                RunPageLink = "Logistic Tour No." = field("Tour No.");
                ToolTip = 'Affiche la fiche de planification de la tournée associée.';
            }
            action("Activity Log List")
            {
                ApplicationArea = All;
                Caption = 'Liste des Activités';
                Image = List;
                RunObject = Page "Tour Activity Log List";
                RunPageLink = "Tour No." = field("Tour No.");
                ToolTip = 'Affiche la liste complète des activités pour cette tournée.';
            }
        }
    }
}