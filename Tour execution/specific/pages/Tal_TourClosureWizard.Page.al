page 73559 "Tour Closure Wizard"
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

                    field(StatusDetails; StatusDetailsText)
                    {
                        ApplicationArea = All;
                        Caption = 'Détails des Statuts';
                        Editable = false;
                        MultiLine = true;
                        Style = Strong;
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
                group(ReturnedQuantitiesGroup)
                {
                    Caption = 'Résumé des Quantités Retournées';

                    field(TotalPlannedQty; TotalPlannedQty)
                    {
                        ApplicationArea = All;
                        Caption = 'Quantité Planifiée Totale';
                        Editable = false;
                    }

                    field(TotalDeliveredQty; TotalDeliveredQty)
                    {
                        ApplicationArea = All;
                        Caption = 'Quantité Livrée Totale';
                        Editable = true;
                    }

                    field(TotalReturnedQty; TotalReturnedQty)
                    {
                        ApplicationArea = All;
                        Caption = 'Quantité Retournée Totale';
                        Editable = false;
                        Style = Unfavorable;
                        StyleExpr = TotalReturnedQty > 0;
                    }

                    field(ReturnRate; ReturnRate)
                    {
                        ApplicationArea = All;
                        Caption = 'Taux de Retour (%)';
                        Editable = false;
                        Style = Unfavorable;
                        StyleExpr = ReturnRate > 0;
                    }
                }
                group(ReturnTransferGroup)
                {
                    Caption = 'Ordre de Transfert Retour';
                    Visible = ReturnTransferOrderExists;

                    field(ReturnTransferInfo; 'Un ordre de transfert retour a été créé pour les quantités retournées.')
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Strong;
                    }

                    field(ReturnTransferOrderNoField; ReturnTransferOrderNo)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'N° Ordre de transfert retour';
                        Style = Strong;
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
                    ExecutionTracking: Record "Tour Execution Tracking";
                begin
                    // Calculate quantity statistics
                    TotalPlannedQty := 0;
                    TotalDeliveredQty := 0;
                    TotalReturnedQty := 0;
                    ReturnRate := 0;

                    ExecutionTracking.Reset();
                    ExecutionTracking.SetRange("Tour No.", Rec."Logistic Tour No.");
                    if ExecutionTracking.FindSet() then
                        repeat
                            TotalPlannedQty += ExecutionTracking."Planned Quantity";
                            TotalDeliveredQty += ExecutionTracking."Quantity Delivered";
                            TotalReturnedQty += ExecutionTracking."Quantity Returned";
                        until ExecutionTracking.Next() = 0;

                    if TotalPlannedQty > 0 then
                        ReturnRate := Round(TotalReturnedQty / TotalPlannedQty * 100, 0.01);

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

                    // Check if return transfer order was created
                    CheckForReturnTransferOrder();

                    // Inform user about return transfer order if created
                    if ReturnTransferOrderExists then
                        Message('Un ordre de transfert retour %1 a été créé pour les quantités retournées.', ReturnTransferOrderNo);

                    CurrPage.Close();
                end;
            }

            action("View Return Transfer Order")
            {
                ApplicationArea = All;
                Caption = 'Voir Ordre de Transfert Retour';
                Image = Return;
                Promoted = true;
                PromotedCategory = Process;
                Visible = ReturnTransferOrderExists and FinishedStepVisible;

                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                    TransferOrder: Page "Transfer Order";
                begin
                    if ReturnTransferOrderNo = '' then begin
                        Message('Aucun ordre de transfert retour trouvé pour cette tournée.');
                        exit;
                    end;

                    if not TransferHeader.Get(ReturnTransferOrderNo) then begin
                        Message('L''ordre de transfert retour %1 n''a pas été trouvé.', ReturnTransferOrderNo);
                        exit;
                    end;

                    TransferOrder.SetRecord(TransferHeader);
                    TransferOrder.Run();
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
        StatusDetailsText: Text;
        ClosureCommentText: Text;
        ClosureSummaryText: Text;
        PendingDeliveriesExist: Boolean;
        MarkFailedDeliveriesOption: Option Failed,Postponed;
        TotalPlannedQty: Decimal;
        TotalDeliveredQty: Decimal;
        TotalReturnedQty: Decimal;
        ReturnRate: Decimal;
        ReturnTransferOrderExists: Boolean;
        ReturnTransferOrderNo: Code[20];

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
        InProgressCount: Integer;
        PendingPct: Decimal;
        InProgressPct: Decimal;
        DeliveredPct: Decimal;
        FailedPct: Decimal;
        PostponedPct: Decimal;
        CompletionRate: Decimal;
    begin
        DeliveryStatusStepVisible := true;

        // Get delivery status counts
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", Rec."Logistic Tour No.");
        TotalDeliveries := ExecutionTracking.Count;

        if TotalDeliveries = 0 then
            exit;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Attente");
        PendingCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Cours");
        InProgressCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        DeliveredCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
        FailedCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
        PostponedCount := ExecutionTracking.Count;

        // Calculate percentages
        PendingPct := Round(PendingCount * 100 / TotalDeliveries, 0.1);
        InProgressPct := Round(InProgressCount * 100 / TotalDeliveries, 0.1);
        DeliveredPct := Round(DeliveredCount * 100 / TotalDeliveries, 0.1);
        FailedPct := Round(FailedCount * 100 / TotalDeliveries, 0.1);
        PostponedPct := Round(PostponedCount * 100 / TotalDeliveries, 0.1);
        CompletionRate := Round((DeliveredCount + FailedCount + PostponedCount) * 100 / TotalDeliveries, 0.1);

        // Generate status text
        DeliveryStatusText := StrSubstNo(
            'Total des livraisons: %1\n' +
            'Livrées: %2 (%3%)\n' +
            'Échouées: %4 (%5%)\n' +
            'Reportées: %6 (%7%)\n' +
            'En attente ou en cours: %8 (%9%)\n\n' +
            'Taux de complétion: %10%',
            TotalDeliveries,
            DeliveredCount, DeliveredPct,
            FailedCount, FailedPct,
            PostponedCount, PostponedPct,
            PendingCount + InProgressCount, PendingPct + InProgressPct,
            CompletionRate);

        // Generate detailed status text with descriptions
        StatusDetailsText := StrSubstNo(
            'Détails des statuts de livraison:\n\n' +
            '• En Attente de Livraison: %1 (%2%)\n' +
            '  La livraison est programmée mais n''a pas encore commencé.\n\n' +
            '• Livraison En Cours: %3 (%4%)\n' +
            '  Le chauffeur est actuellement chez le client et procède à la livraison.\n\n' +
            '• Livraison Effectuée: %5 (%6%)\n' +
            '  La livraison a été effectuée avec succès.\n\n' +
            '• Livraison Échouée: %7 (%8%)\n' +
            '  La livraison n''a pas pu être effectuée.\n\n' +
            '• Livraison Reportée: %9 (%10%)\n' +
            '  La livraison a été reportée à une date ultérieure.',
            PendingCount, PendingPct,
            InProgressCount, InProgressPct,
            DeliveredCount, DeliveredPct,
            FailedCount, FailedPct,
            PostponedCount, PostponedPct);

        PendingDeliveriesExist := (PendingCount + InProgressCount > 0);

        BackActionEnabled := true;
        NextActionEnabled := not PendingDeliveriesExist;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinalizeStep()
    var
        ExecutionTracking: Record "Tour Execution Tracking";
    begin
        FinalizeStepVisible := true;

        // Calculate quantity statistics
        TotalPlannedQty := 0;
        TotalDeliveredQty := 0;
        TotalReturnedQty := 0;
        ReturnRate := 0;

        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", Rec."Logistic Tour No.");
        if ExecutionTracking.FindSet() then
            repeat
                TotalPlannedQty += ExecutionTracking."Planned Quantity";
                TotalDeliveredQty += ExecutionTracking."Quantity Delivered";
                TotalReturnedQty += ExecutionTracking."Quantity Returned";
            until ExecutionTracking.Next() = 0;

        if TotalPlannedQty > 0 then
            ReturnRate := Round(TotalReturnedQty / TotalPlannedQty * 100, 0.01);

        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ShowFinishedStep()
    begin
        ResetControls();
        FinishedStepVisible := true;
        BackActionEnabled := false;
        NextActionEnabled := false;
        FinishActionEnabled := false;

        // Check if return transfer order was created
        CheckForReturnTransferOrder();
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

    local procedure CheckForReturnTransferOrder()
    var
        TransferHeader: Record "Transfer Header";
    begin
        ReturnTransferOrderExists := false;
        ReturnTransferOrderNo := '';

        TransferHeader.Reset();
        TransferHeader.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
        TransferHeader.SetRange("Return Transfer", true);

        if TransferHeader.FindFirst() then begin
            ReturnTransferOrderExists := true;
            ReturnTransferOrderNo := TransferHeader."No.";
        end;
    end;
}