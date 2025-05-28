page 77013 "Tour Activity Log List"
{
    ApplicationArea = All;
    Caption = 'Journal d''Activité Tournée';
    PageType = List;
    SourceTable = "Tour Activity Log";
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Tour Activity Log Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie le numéro de séquence unique de l''entrée du journal d''activité.';
                }
                field("Tour No."; Rec."Tour No.")
                {
                    ApplicationArea = All;
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie la description détaillée de l''activité.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifie l''identifiant de l''utilisateur qui a enregistré l''activité.';
                }
            }
        }
        area(factboxes)
        {
            part(TourDetails; "Tour Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Logistic Tour No." = field("Tour No.");
                Caption = 'Détails de la Tournée';
                Visible = true;
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
        }
        area(Processing)
        {
            action(FilterByTour)
            {
                ApplicationArea = All;
                Caption = 'Filtrer par Tournée';
                Image = Filter;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Applique un filtre pour afficher uniquement les activités d''une tournée spécifique.';

                trigger OnAction()
                var
                    TourHeader: Record "Planification Header";
                    TourSelectPage: Page "Tour Planning List";
                begin
                    TourSelectPage.LookupMode := true;
                    if TourSelectPage.RunModal = ACTION::LookupOK then begin
                        TourSelectPage.GetRecord(TourHeader);
                        Rec.FilterGroup(2);
                        Rec.SetRange("Tour No.", TourHeader."Logistic Tour No.");
                        Rec.FilterGroup(0);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ClearFilters)
            {
                ApplicationArea = All;
                Caption = 'Effacer les Filtres';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Efface tous les filtres appliqués.';

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                end;
            }
            action(FilterToday)
            {
                ApplicationArea = All;
                Caption = 'Activités du Jour';
                Image = Calendar;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Affiche uniquement les activités d''aujourd''hui.';

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    Rec.SetRange("Activity Date", WorkDate());
                    Rec.FilterGroup(0);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Reporting)
        {
            action("Activity Summary Report")
            {
                ApplicationArea = All;
                Caption = 'Rapport d''activités';
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                ToolTip = 'Génère un rapport sommaire des activités de tournée par période.';

                trigger OnAction()
                begin
                    // This will be implemented when the report is created
                    Message('Rapport en cours de développement.');
                end;
            }
        }
    }
}