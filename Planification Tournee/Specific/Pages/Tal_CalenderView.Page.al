page 73636 "Tal Simple Calendar Page"
{
    PageType = CardPart;
    SourceTable = "Planning Lines";
    ApplicationArea = All;
    Caption = 'Calendrier de Planning';

    layout
    {
        area(content)
        {
            usercontrol(Calendar; PlanningCalendarAddIn)
            {
                ApplicationArea = All;

                trigger OnControlReady()
                begin
                    Message('🎯 Calendrier prêt et initialisé !');
                end;

                trigger OnDateChanged(selectedDate: Text)
                var
                    SelectedDateVar: Date;
                    DateText: Text;
                    PlanningLine: Record "Planning Lines";
                    Counter: Integer;
                begin
                    // Validation de la date
                    if not Evaluate(SelectedDateVar, selectedDate) then begin
                        Error('❌ Format de date invalide : %1', selectedDate);
                        exit;
                    end;

                    // Formatage pour affichage
                    DateText := Format(SelectedDateVar, 0, '<Day,2>/<Month,2>/<Year4>');

                    // Message de confirmation
                    Message('📅 Date reçue du calendrier : %1', DateText);

                    // Recherche dans les lignes de planning
                    PlanningLine.Reset();
                    PlanningLine.SetRange(" Delivery Date", SelectedDateVar);

                    if PlanningLine.FindSet() then begin
                        Counter := PlanningLine.Count();
                        Message('📊 %1 ligne(s) de planning trouvée(s) pour le %2', Counter, DateText);

                        // Ici vous pouvez ajouter votre logique métier
                        ProcessPlanningData(SelectedDateVar);

                    end else begin
                        Message('ℹ️ Aucune donnée de planning pour le %1', DateText);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshCalendar)
            {
                ApplicationArea = All;
                Caption = '🔄 Actualiser';
                ToolTip = 'Actualiser le calendrier';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Message('✅ Calendrier actualisé');
                end;
            }
        }
    }

    local procedure ProcessPlanningData(PlanningDate: Date)
    var
        PlanningLine: Record "Planning Lines";
        TotalQuantity: Decimal;
        TotalAmount: Decimal;
    begin
        PlanningLine.Reset();
        PlanningLine.SetRange(" Delivery Date", PlanningDate);

        if PlanningLine.FindSet() then begin
            repeat
                TotalQuantity += PlanningLine.Quantity;
            // TotalAmount += PlanningLine.Amount; // Si ce champ existe
            until PlanningLine.Next() = 0;

            Message('📈 Résumé Planning :\Quantité totale : %1\Date : %2',
                    TotalQuantity,
                    Format(PlanningDate, 0, '<Day,2>/<Month,2>/<Year4>'));
        end;
    end;
}