page 77059 "Tour Closure Wizard"
{
    Caption = 'Assistant de Clôture de Tournée';
    PageType = NavigatePage;
    SourceTable = "Planification Header";

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible;
                field(MediaResourcesStandard; MediaResourcesStd."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(WelcomeStep)
            {
                Caption = 'Bienvenue dans l''assistant de clôture de tournée';
                Visible = WelcomeStepVisible;

                group(WelcomeGroup)
                {
                    Caption = '';
                    InstructionalText = 'Cet assistant vous guidera à travers le processus de clôture de la tournée. Assurez-vous que toutes les livraisons sont terminées ou correctement documentées avant de continuer.';

                    field("Logistic Tour No."; Rec."Logistic Tour No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Numéro de tournée';
                        ToolTip = 'Spécifie le numéro de la tournée à clôturer.';
                    }
                    field("Date de Tournée"; Rec."Date de Tournée")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Date de tournée';
                        ToolTip = 'Spécifie la date de la tournée à clôturer.';
                    }
                    field("Driver No."; Rec."Driver No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Chauffeur';
                        ToolTip = 'Spécifie le chauffeur assigné à la tournée.';
                    }
                }
            }

            group(DeliveryStatusStep)
            {
                Caption = 'Vérification des statuts de livraison';
                Visible = DeliveryStatusStepVisible;

                group(DeliveryStatusGroup)
                {
                    Caption = '';
                    InstructionalText = 'Veuillez vérifier les statuts de livraison ci-dessous. Toutes les livraisons doivent avoir un statut final (Livré, Échoué ou Reporté) avant de clôturer la tournée.';

                    field(DeliveryStatusInfo; DeliveryStatusText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        MultiLine = true;
                        Style = StrongAccent;
                    }

                    field(PendingDeliveries; PendingDeliveriesExist)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Livraisons en attente';
                        ToolTip = 'Indique s''il reste des livraisons en attente.';
                        Style = Unfavorable;
                    }
                }
            }

            group(FinalizeStep)
            {
                Caption = 'Finalisation de la clôture';
                Visible = FinalizeStepVisible;

                group(FinalizeGroup)
                {
                    Caption = '';
                    InstructionalText = 'Vous êtes sur le point de clôturer définitivement cette tournée. Cette action ne peut pas être annulée. Veuillez saisir tout commentaire final ci-dessous.';

                    field(ClosureComment; ClosureCommentText)
                    {
                        ApplicationArea = All;
                        Caption = 'Commentaire de clôture';
                        ToolTip = 'Saisissez un commentaire final pour la clôture de cette tournée.';
                        MultiLine = true;
                    }

                    field(MarkFailedDeliveries; MarkFailedDeliveriesOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Marquer les livraisons en attente comme';
                        ToolTip = 'Spécifie comment traiter les livraisons encore en attente.';
                        OptionCaption = 'Échouées,Reportées';
                    }
                }
            }

            group(FinishedStep)
            {
                Caption = 'Terminé';
                Visible = FinishedStepVisible;

                group(FinishedGroup)
                {
                    Caption = '';
                    InstructionalText = 'La tournée a été clôturée avec succès. Vous pouvez maintenant fermer cette fenêtre.';

                    field(ClosureSummary; ClosureSummaryText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        MultiLine = true;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Précédent';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Suivant';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Terminer';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    TourExecutionMgt: Codeunit "Tour Execution Mgt.";
                begin
                    // Complete the tour
                    TourExecutionMgt.CompleteTour(Rec);

                    // Show the final step
                    FinishedStepVisible := true;
                    DeliveryStatusStepVisible := false;
                    FinalizeStepVisible := false;
                    WelcomeStepVisible := false;

                    // ActionFinish.Enabled := false;
                    // ActionNext.Enabled := false;
                    // ActionBack.Enabled := false;

                    // Generate closure summary
                    ClosureSummaryText := TourExecutionMgt.GenerateTourSummary(Rec."Logistic Tour No.");
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Start;
        EnableControls();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if not FinishedStepVisible then
                exit(Confirm('Êtes-vous sûr de vouloir quitter l''assistant sans clôturer la tournée?', true));
    end;

    var
        MediaRepositoryStd: Record "Media Repository";
        MediaResourcesStd: Record "Media Resources";
        Step: Option Start,DeliveryStatus,Finalize,Finished;
        TopBannerVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        DeliveryStatusStepVisible: Boolean;
        FinalizeStepVisible: Boolean;
        FinishedStepVisible: Boolean;
        DeliveryStatusText: Text;
        ClosureCommentText: Text;
        ClosureSummaryText: Text;
        PendingDeliveriesExist: Boolean;
        MarkFailedDeliveriesOption: Option Failed,Postponed;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::DeliveryStatus:
                ShowDeliveryStatusStep();
            Step::Finalize:
                ShowFinalizeStep();
            Step::Finished:
                ShowFinishedStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowWelcomeStep()
    begin
        WelcomeStepVisible := true;

        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDeliveryStatusStep()
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        TotalDeliveries: Integer;
        PendingCount: Integer;
        DeliveredCount: Integer;
        FailedCount: Integer;
        PostponedCount: Integer;
    begin
        DeliveryStatusStepVisible := true;

        // Get delivery status counts
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", Rec."Logistic Tour No.");
        TotalDeliveries := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Attente");
        PendingCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        DeliveredCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
        FailedCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
        PostponedCount := ExecutionTracking.Count;

        // Generate status text
        DeliveryStatusText := StrSubstNo(
            'Total des livraisons: %1\n' +
            'Livrées: %2\n' +
            'Échouées: %3\n' +
            'Reportées: %4\n' +
            'En attente: %5',
            TotalDeliveries, DeliveredCount, FailedCount, PostponedCount, PendingCount);

        PendingDeliveriesExist := PendingCount > 0;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinalizeStep()
    begin
        FinalizeStepVisible := true;

        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ShowFinishedStep()
    begin
        FinishedStepVisible := true;

        BackActionEnabled := false;
        NextActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ResetControls()
    begin
        // Hide all steps
        WelcomeStepVisible := false;
        DeliveryStatusStepVisible := false;
        FinalizeStepVisible := false;
        FinishedStepVisible := false;

        // Disable all actions
        BackActionEnabled := false;
        NextActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStd.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaResourcesStd.Get(MediaRepositoryStd."Media Resources Ref")
        then
            TopBannerVisible := MediaResourcesStd."Media Reference".HasValue;
    end;
}