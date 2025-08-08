page 73638 "Tal Planning Dashboard"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Planning Lines";
    Caption = 'Dashboard de Planning des Tournées';

    layout
    {
        area(Content)
        {
            group(Calendar)
            {
                Caption = '';
                part(PlanningCalendar; "Tal Simple Calendar Page")
                {
                    ApplicationArea = All;
                    Caption = 'Calendrier';
                    UpdatePropagation = Both;
                }
            }
            group(Map)
            {
                Caption = '';
                part(PlanningMap; "Tal Planning Map Page")
                {
                    ApplicationArea = All;
                    Caption = 'Carte de Planning';
                    UpdatePropagation = Both;
                }
            }

            part(PlanningLinesPart; "Planning Lines Subpage")
            {
                ApplicationArea = All;
                Caption = 'Lignes de Planning';
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshAll)
            {
                ApplicationArea = All;
                Caption = '🔄 Actualiser Tout';
                ToolTip = 'Actualiser toutes les données';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Message('✅ Dashboard actualisé');
                end;
            }

            action(FilterByMonth)
            {
                ApplicationArea = All;
                Caption = '📅 Mois Actuel';
                ToolTip = 'Filtrer par mois actuel';
                Image = Calendar;

                trigger OnAction()
                var
                    StartDate: Date;
                    EndDate: Date;
                begin
                    // Calculer le premier et dernier jour du mois
                    StartDate := CalcDate('<-CM>', WorkDate());
                    EndDate := CalcDate('<CM>', WorkDate());

                    // Appliquer le filtre
                    Rec.Reset();
                    Rec.SetFilter("Expected Shipment Date", '%1..%2', StartDate, EndDate);
                    CurrPage.Update(false);

                    Message('📅 Filtrage par mois : %1 - %2',
                        Format(StartDate, 0, '<Day,2>/<Month,2>/<Year4>'),
                        Format(EndDate, 0, '<Day,2>/<Month,2>/<Year4>'));
                end;
            }

            action(ShowAllData)
            {
                ApplicationArea = All;
                Caption = '👁️ Tout Afficher';
                ToolTip = 'Afficher toutes les données';
                Image = AllLines;

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                    Message('👁️ Affichage de toutes les données');
                end;
            }

            action(CalculateOptimalRoute)
            {
                ApplicationArea = All;
                Caption = '🛣️ Calculer Route Optimale';
                ToolTip = 'Calculer la route optimale pour toutes les livraisons';
                Image = GetEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MapPage: Page "Tal Planning Map Page";
                    PlanningLine: Record "Planning Lines";
                    StartLocationId: Text;
                begin
                    // Utiliser la ligne actuelle comme point de départ ou prendre la première ligne
                    if Rec."Line No." <> 0 then
                        StartLocationId := Format(Rec."Line No.")
                    else begin
                        PlanningLine.Reset();
                        if PlanningLine.FindFirst() then
                            StartLocationId := Format(PlanningLine."Line No.")
                        else
                            StartLocationId := '0'; // Valeur par défaut
                    end;

                    // Ouvrir temporairement la page Map pour exécuter l'action
                    MapPage.SetRecord(Rec);
                    // Utiliser l'action plutôt que d'appeler la procédure directement
                    MapPage.RunModal();

                    Message('🧮 Calcul de l''itinéraire optimal en cours...');

                    // Rafraîchir la page principale
                    CurrPage.Update(false);
                end;
            }

            action(CreateLoadingDocument)
            {
                ApplicationArea = All;
                Caption = '📋 Créer Document Préparation';
                ToolTip = 'Créer un document de préparation basé sur l''itinéraire optimisé';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false; // Masquer temporairement jusqu'à ce que les tables requises soient disponibles

                trigger OnAction()
                begin
                    Message('Cette fonctionnalité sera disponible dans une version future.');
                end;
            }
        }

        area(Navigation)
        {
            action(ViewCalendar)
            {
                ApplicationArea = All;
                Caption = '📅 Vue Calendrier';
                ToolTip = 'Afficher la vue calendrier';
                Image = Calendar;

                trigger OnAction()
                var
                    CalendarPage: Page "Tal Simple Calendar Page";
                begin
                    CalendarPage.SetRecord(Rec);
                    CalendarPage.Run();
                end;
            }

            action(ViewMap)
            {
                ApplicationArea = All;
                Caption = '🗺️ Vue Carte';
                ToolTip = 'Afficher la vue carte';
                Image = Map;

                trigger OnAction()
                var
                    MapPage: Page "Tal Planning Map Page";
                begin
                    MapPage.SetRecord(Rec);
                    MapPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Définir un filtre par défaut pour montrer uniquement les données pertinentes
        Rec.SetRange("Expected Shipment Date", CalcDate('<-10D>', WorkDate()), CalcDate('<+30D>', WorkDate()));
    end;

    local procedure ConfirmCalculateRoute(): Boolean
    var
        ConfirmMsg: Label 'Voulez-vous calculer l''itinéraire optimal avant de créer le document de préparation?';
    begin
        // Si l'itinéraire n'a pas déjà été calculé, proposer de le faire
        if Dialog.Confirm(ConfirmMsg, true) then begin
            // Lancer l'action depuis la page (au lieu d'appeler directement la méthode)
            CurrPage.PlanningMap.Page.RunModal();
            Commit(); // S'assurer que les modifications sont enregistrées
            Sleep(2000); // Attendre que le calcul soit terminé
            exit(true);
        end;

        exit(true); // Continuer même sans calcul
    end;

    local procedure GenerateOptimizedStopLines(LoadingNo: Code[20])
    begin
        // Cette fonctionnalité sera implémentée dans une version future
        Message('Génération des lignes d''arrêt optimisées sera disponible dans une version future.');
    end;
}