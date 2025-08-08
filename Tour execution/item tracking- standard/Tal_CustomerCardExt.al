pageextension 73599 "TAL_Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Statistics)
        {
            group("Delivery Statistics")
            {
                Caption = 'Statistiques des Livraisons';

                field("Total Deliveries"; TotalDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Total de Livraisons';
                    ToolTip = 'Affiche le nombre total de livraisons associées à ce client.';
                    Editable = false;
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Toutes les Livraisons';
                        TrackingList.RunModal();
                    end;
                }

                field("Pending Deliveries"; PendingDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Livraisons en Attente';
                    ToolTip = 'Affiche le nombre de livraisons en attente pour ce client.';
                    Editable = false;
                    StyleExpr = 'Ambiguous';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Attente");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Livraisons en Attente';
                        TrackingList.RunModal();
                    end;
                }

                field("In Progress Deliveries"; InProgressDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Livraisons en Cours';
                    ToolTip = 'Affiche le nombre de livraisons en cours pour ce client.';
                    Editable = false;
                    StyleExpr = 'Attention';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Cours");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Livraisons en Cours';
                        TrackingList.RunModal();
                    end;
                }

                field("Completed Deliveries"; CompletedDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Livraisons Effectuées';
                    ToolTip = 'Affiche le nombre de livraisons effectuées pour ce client.';
                    Editable = false;
                    StyleExpr = 'Favorable';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Livraisons Effectuées';
                        TrackingList.RunModal();
                    end;
                }

                field("Failed Deliveries"; FailedDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Livraisons Échouées';
                    ToolTip = 'Affiche le nombre de livraisons échouées pour ce client.';
                    Editable = false;
                    StyleExpr = 'Unfavorable';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Livraisons Échouées';
                        TrackingList.RunModal();
                    end;
                }

                field("Postponed Deliveries"; PostponedDeliveries)
                {
                    ApplicationArea = All;
                    Caption = 'Livraisons Reportées';
                    ToolTip = 'Affiche le nombre de livraisons reportées pour ce client.';
                    Editable = false;
                    StyleExpr = 'Subordinate';

                    trigger OnDrillDown()
                    var
                        ExecutionTracking: Record "Tour Execution Tracking";
                        TrackingList: Page "Tour Execution Tracking List";
                    begin
                        ExecutionTracking.Reset();
                        ExecutionTracking.SetRange("Customer No.", Rec."No.");
                        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
                        TrackingList.SetTableView(ExecutionTracking);
                        TrackingList.Caption := 'Livraisons Reportées';
                        TrackingList.RunModal();
                    end;
                }

                field("Delivery Success Rate"; DeliverySuccessRate)
                {
                    ApplicationArea = All;
                    Caption = 'Taux de Réussite des Livraisons';
                    ToolTip = 'Affiche le pourcentage de livraisons réussies pour ce client.';
                    Editable = false;
                    StyleExpr = DeliveryRateStyle;
                }
            }

            group("Delivery Visualization")
            {
                Caption = 'Visualisation des Livraisons';

                field(DeliveryStatusChart; DeliveryStatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Statut des Livraisons';
                    ToolTip = 'Affiche une représentation visuelle des statuts de livraison.';
                    Editable = false;
                    MultiLine = true;
                    Style = Strong;
                }

                field(DeliveryQuantityStats; DeliveryQuantityText)
                {
                    ApplicationArea = All;
                    Caption = 'Statistiques des Quantités';
                    ToolTip = 'Affiche les statistiques des quantités livrées et retournées.';
                    Editable = false;
                    MultiLine = true;
                    Style = Strong;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateTourStatistics();
    end;

    local procedure UpdateTourStatistics()
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        TotalPlannedQty: Decimal;
        TotalDeliveredQty: Decimal;
        TotalReturnedQty: Decimal;
        ReturnRate: Decimal;
        PendingPct: Decimal;
        InProgressPct: Decimal;
        CompletedPct: Decimal;
        FailedPct: Decimal;
        PostponedPct: Decimal;
        BarLength: Integer;
        BarChar: Text[1];
        EmptyChar: Text[1];
        StatusBar: Text;
        i: Integer;
    begin
        // Initialiser les compteurs
        TotalDeliveries := 0;
        PendingDeliveries := 0;
        InProgressDeliveries := 0;
        CompletedDeliveries := 0;
        FailedDeliveries := 0;
        PostponedDeliveries := 0;
        DeliverySuccessRate := 0;
        TotalPlannedQty := 0;
        TotalDeliveredQty := 0;
        TotalReturnedQty := 0;

        // Compter les livraisons via le suivi d'exécution
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Customer No.", Rec."No.");
        TotalDeliveries := ExecutionTracking.Count;

        if TotalDeliveries = 0 then begin
            DeliveryStatusText := 'Aucune livraison trouvée pour ce client.';
            DeliveryQuantityText := 'Aucune donnée de quantité disponible.';
            DeliveryRateStyle := 'Standard';
            exit;
        end;

        // Compter par statut
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Attente");
        PendingDeliveries := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Cours");
        InProgressDeliveries := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        CompletedDeliveries := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
        FailedDeliveries := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
        PostponedDeliveries := ExecutionTracking.Count;

        // Calculer les pourcentages
        if TotalDeliveries > 0 then begin
            PendingPct := Round(PendingDeliveries * 100 / TotalDeliveries, 0.1);
            InProgressPct := Round(InProgressDeliveries * 100 / TotalDeliveries, 0.1);
            CompletedPct := Round(CompletedDeliveries * 100 / TotalDeliveries, 0.1);
            FailedPct := Round(FailedDeliveries * 100 / TotalDeliveries, 0.1);
            PostponedPct := Round(PostponedDeliveries * 100 / TotalDeliveries, 0.1);
            DeliverySuccessRate := Round(CompletedDeliveries * 100 / TotalDeliveries, 0.1);
        end;

        // Définir le style du taux de réussite
        if DeliverySuccessRate >= 90 then
            DeliveryRateStyle := 'Favorable'
        else if DeliverySuccessRate >= 75 then
            DeliveryRateStyle := 'Ambiguous'
        else
            DeliveryRateStyle := 'Unfavorable';

        // Calculer les quantités totales
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Customer No.", Rec."No.");
        if ExecutionTracking.FindSet() then
            repeat
                TotalPlannedQty += ExecutionTracking."Planned Quantity";
                TotalDeliveredQty += ExecutionTracking."Quantity Delivered";
                TotalReturnedQty += ExecutionTracking."Quantity Returned";
            until ExecutionTracking.Next() = 0;

        if TotalPlannedQty > 0 then
            ReturnRate := Round(TotalReturnedQty * 100 / TotalPlannedQty, 0.1);

        // Créer une visualisation ASCII des statuts (style PowerBI)
        BarChar := '█';
        EmptyChar := ' ';
        BarLength := 20; // Longueur maximale de la barre

        // Générer le texte de statut avec barres de progression
        DeliveryStatusText := StrSubstNo('Statut des Livraisons (%1 total):\n', TotalDeliveries);

        // Barre pour Livraisons Effectuées
        StatusBar := 'Effectuées (%1%): ';
        for i := 1 to Round(BarLength * CompletedPct / 100, 1) do
            StatusBar += BarChar;
        DeliveryStatusText += StrSubstNo(StatusBar, CompletedPct) + '\n';

        // Barre pour Livraisons en Attente
        StatusBar := 'En Attente (%1%): ';
        for i := 1 to Round(BarLength * PendingPct / 100, 1) do
            StatusBar += BarChar;
        DeliveryStatusText += StrSubstNo(StatusBar, PendingPct) + '\n';

        // Barre pour Livraisons en Cours
        StatusBar := 'En Cours (%1%): ';
        for i := 1 to Round(BarLength * InProgressPct / 100, 1) do
            StatusBar += BarChar;
        DeliveryStatusText += StrSubstNo(StatusBar, InProgressPct) + '\n';

        // Barre pour Livraisons Échouées
        StatusBar := 'Échouées (%1%): ';
        for i := 1 to Round(BarLength * FailedPct / 100, 1) do
            StatusBar += BarChar;
        DeliveryStatusText += StrSubstNo(StatusBar, FailedPct) + '\n';

        // Barre pour Livraisons Reportées
        StatusBar := 'Reportées (%1%): ';
        for i := 1 to Round(BarLength * PostponedPct / 100, 1) do
            StatusBar += BarChar;
        DeliveryStatusText += StrSubstNo(StatusBar, PostponedPct) + '\n';

        // Générer le texte des statistiques de quantité
        DeliveryQuantityText := 'Statistiques des Quantités:\n';
        DeliveryQuantityText += StrSubstNo('Quantité Planifiée: %1\n', Format(TotalPlannedQty));

        if TotalPlannedQty > 0 then
            DeliveryQuantityText += StrSubstNo('Quantité Livrée: %1 (%2%)\n',
                                    Format(TotalDeliveredQty),
                                    Format(Round(TotalDeliveredQty * 100 / TotalPlannedQty, 0.1)))
        else
            DeliveryQuantityText += StrSubstNo('Quantité Livrée: %1 (0%)\n', Format(TotalDeliveredQty));

        if TotalPlannedQty > 0 then
            DeliveryQuantityText += StrSubstNo('Quantité Retournée: %1 (%2%)\n',
                                    Format(TotalReturnedQty),
                                    Format(ReturnRate))
        else
            DeliveryQuantityText += StrSubstNo('Quantité Retournée: %1 (0%)\n', Format(TotalReturnedQty));
    end;

    var
        TotalDeliveries: Integer;
        PendingDeliveries: Integer;
        InProgressDeliveries: Integer;
        CompletedDeliveries: Integer;
        FailedDeliveries: Integer;
        PostponedDeliveries: Integer;
        DeliverySuccessRate: Decimal;
        DeliveryStatusText: Text;
        DeliveryQuantityText: Text;
        DeliveryRateStyle: Text;
}