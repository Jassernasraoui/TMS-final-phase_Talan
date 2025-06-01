codeunit 77060 "Tour Execution Management"
{
    Description = 'Gère le processus dexécution des tournées et leur liaison avec le chargement et la planification';

    // Fonction principale pour démarrer l'exécution d'une tournée
    procedure InitiateTourExecution(TourNo: Code[20]; ExecutionOption: Option FromPlanning,FromLoading)
    var
        PlanificationHeader: Record "Planification Header";
        VehicleChargingHeader: Record "Vehicle Charging Header";
        TourExecutionTracking: Record "Tour Execution Tracking";
        PlanningLines: Record "Planning Lines";
        ErrorMessage: Text;
    begin
        // Vérifier que la tournée existe
        if not PlanificationHeader.Get(TourNo) then
            Error('La tournée %1 n''existe pas.', TourNo);

        // Vérifier les conditions préalables selon le chemin d'exécution
        case ExecutionOption of
            ExecutionOption::FromPlanning:
                begin
                    // Vérifier que la tournée est au statut planifiée
                    if PlanificationHeader.Statut <> PlanificationHeader.Statut::Plannified then
                        Error('La tournée %1 n''est pas au statut "Planifiée". Statut actuel: %2',
                              TourNo, Format(PlanificationHeader.Statut));

                    // Vérifier les ressources minimales
                    if PlanificationHeader."Driver No." = '' then
                        ErrorMessage += 'Aucun chauffeur assigné.\';
                    if PlanificationHeader."Véhicule No." = '' then
                        ErrorMessage += 'Aucun véhicule assigné.\';

                    if ErrorMessage <> '' then
                        Error('Impossible de démarrer l''exécution de la tournée %1:\%2', TourNo, ErrorMessage);

                    // Initialiser le suivi d'exécution directement depuis la planification
                    InitializeExecutionTrackingFromPlanning(TourNo);

                    // Mettre à jour le statut de la tournée à "En Cours"
                    PlanificationHeader.Statut := PlanificationHeader.Statut::Inprogress;
                    PlanificationHeader.Modify(true);

                    // Loguer l'activité
                    LogTourActivity(TourNo, 'Exécution directe démarrée sans chargement', '');
                end;

            ExecutionOption::FromLoading:
                begin
                    // Trouver la fiche de chargement validée pour cette tournée
                    VehicleChargingHeader.Reset();
                    VehicleChargingHeader.SetRange("Tour No.", TourNo);
                    VehicleChargingHeader.SetRange(Status, VehicleChargingHeader.Status::Completed);

                    if not VehicleChargingHeader.FindLast() then
                        Error('Aucun chargement complété trouvé pour la tournée %1.', TourNo);

                    // Vérifier que la tournée est au statut chargement
                    if PlanificationHeader.Statut <> PlanificationHeader.Statut::Loading then
                        Error('La tournée %1 n''est pas au statut "Chargement". Statut actuel: %2',
                              TourNo, Format(PlanificationHeader.Statut));

                    // Initialiser le suivi d'exécution à partir du chargement
                    InitializeExecutionTrackingFromLoading(TourNo, VehicleChargingHeader."Vehicle Charging No.");

                    // Mettre à jour le statut de la tournée à "En Cours"
                    PlanificationHeader.Statut := PlanificationHeader.Statut::Inprogress;
                    PlanificationHeader.Modify(true);

                    // Loguer l'activité
                    LogTourActivity(TourNo, 'Exécution démarrée après chargement',
                                   'Chargement: ' + VehicleChargingHeader."Vehicle Charging No.");
                end;
        end;

        // Mettre à jour le statut des ressources
        UpdateResourceStatus(PlanificationHeader."Driver No.", PlanificationHeader."Véhicule No.", true);
    end;

    // Initialise le suivi d'exécution à partir de la planification (sans chargement)
    local procedure InitializeExecutionTrackingFromPlanning(TourNo: Code[20])
    var
        PlanningLines: Record "Planning Lines";
        TourExecutionTracking: Record "Tour Execution Tracking";
        LineNo: Integer;
    begin
        // Supprimer toute entrée existante
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        TourExecutionTracking.DeleteAll();

        // Créer une entrée de suivi pour chaque ligne de planification
        PlanningLines.Reset();
        PlanningLines.SetRange("Logistic Tour No.", TourNo);

        if PlanningLines.FindSet() then begin
            LineNo := 0;
            repeat
                LineNo += 10;

                TourExecutionTracking.Init();
                TourExecutionTracking."Line No." := LineNo;
                TourExecutionTracking."Tour No." := TourNo;
                TourExecutionTracking."Customer No." := PlanningLines."Customer No.";
                TourExecutionTracking."Planning Line No." := PlanningLines."Line No.";
                TourExecutionTracking.Status := TourExecutionTracking.Status::"En Attente";
                TourExecutionTracking."Date Livraison" := PlanningLines." Delivery Date";
                TourExecutionTracking."Tournée Terminée" := false;
                TourExecutionTracking.Insert(true);
            until PlanningLines.Next() = 0;
        end;
    end;

    // Initialise le suivi d'exécution à partir du chargement
    local procedure InitializeExecutionTrackingFromLoading(TourNo: Code[20]; ChargingNo: Code[20])
    var
        VehicleChargingLine: Record "Vehicle Charging Line";
        TourExecutionTracking: Record "Tour Execution Tracking";
        PlanningLines: Record "Planning Lines";
        LineNo: Integer;
    begin
        // Supprimer toute entrée existante
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        TourExecutionTracking.DeleteAll();

        // Créer une entrée de suivi pour chaque ligne de chargement
        VehicleChargingLine.Reset();
        VehicleChargingLine.SetRange("Charging No.", ChargingNo);

        if VehicleChargingLine.FindSet() then begin
            LineNo := 0;
            repeat
                LineNo += 10;

                // Trouver la ligne de planification correspondante
                PlanningLines.Reset();
                PlanningLines.SetRange("Logistic Tour No.", TourNo);
                PlanningLines.SetRange("Line No.", VehicleChargingLine."Line No.");

                if PlanningLines.FindFirst() then begin
                    TourExecutionTracking.Init();
                    TourExecutionTracking."Line No." := LineNo;
                    TourExecutionTracking."Tour No." := TourNo;
                    TourExecutionTracking."Customer No." := PlanningLines."Customer No.";
                    TourExecutionTracking."Planning Line No." := PlanningLines."Line No.";
                    TourExecutionTracking.Status := TourExecutionTracking.Status::"En Attente";
                    TourExecutionTracking."Date Livraison" := PlanningLines." Delivery Date";
                    TourExecutionTracking."Notes Livraison" := StrSubstNo('Chargé: %1 %2',
                                                          Format(VehicleChargingLine."Actual Quantity"),
                                                          VehicleChargingLine."Loading Status");
                    TourExecutionTracking."Tournée Terminée" := false;
                    TourExecutionTracking.Insert(true);
                end;
            until VehicleChargingLine.Next() = 0;
        end;
    end;

    // Met à jour le statut d'un arrêt
    procedure UpdateStopStatus(TourNo: Code[20]; LineNo: Integer; NewStatus: Option "En Attente","En Cours","Livré","Échoué","Reporté"; Notes: Text[250])
    var
        TourExecutionTracking: Record "Tour Execution Tracking";
    begin
        // Trouver et mettre à jour la ligne d'exécution
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        TourExecutionTracking.SetRange("Line No.", LineNo);

        if TourExecutionTracking.FindFirst() then begin
            TourExecutionTracking.Status := NewStatus;

            if NewStatus in [NewStatus::"Livré", NewStatus::"Échoué", NewStatus::"Reporté"] then
                TourExecutionTracking."Heure Livraison" := Time;

            if Notes <> '' then
                TourExecutionTracking."Notes Livraison" := CopyStr(Notes, 1, 250);

            TourExecutionTracking.Modify(true);

            // Loguer l'activité
            LogTourActivity(TourNo, StrSubstNo('Mise à jour arrêt %1: %2', LineNo, Format(NewStatus)), Notes);

            // Vérifier si tous les arrêts sont terminés
            CheckIfAllStopsCompleted(TourNo);
        end else
            Error('Ligne d''exécution %1 non trouvée pour la tournée %2.', LineNo, TourNo);
    end;

    // Termine une tournée
    procedure CompleteTour(TourNo: Code[20]; Notes: Text[250])
    var
        PlanificationHeader: Record "Planification Header";
        TourExecutionTracking: Record "Tour Execution Tracking";
        PendingStops: Boolean;
    begin
        // Vérifier que la tournée existe et est en cours
        if not PlanificationHeader.Get(TourNo) then
            Error('La tournée %1 n''existe pas.', TourNo);

        if PlanificationHeader.Statut <> PlanificationHeader.Statut::Inprogress then
            Error('La tournée %1 n''est pas au statut "En Cours". Statut actuel: %2',
                  TourNo, Format(PlanificationHeader.Statut));

        // Vérifier s'il reste des arrêts en attente ou en cours
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        TourExecutionTracking.SetFilter(Status, '%1|%2',
            TourExecutionTracking.Status::"En Attente",
            TourExecutionTracking.Status::"En Cours");

        PendingStops := not TourExecutionTracking.IsEmpty();

        if PendingStops then begin
            if not Confirm('Il reste des arrêts non terminés. Voulez-vous quand même clôturer la tournée?') then
                exit;

            // Marquer tous les arrêts en attente comme reportés
            if TourExecutionTracking.FindSet() then
                repeat
                    TourExecutionTracking.Status := TourExecutionTracking.Status::Reporté;
                    TourExecutionTracking."Notes Livraison" := CopyStr('Clôture forcée: ' + Notes, 1, 250);
                    TourExecutionTracking.Modify(true);
                until TourExecutionTracking.Next() = 0;
        end;

        // Marquer toutes les lignes comme tournée terminée
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        if TourExecutionTracking.FindSet() then
            repeat
                TourExecutionTracking."Tournée Terminée" := true;
                TourExecutionTracking.Modify(true);
            until TourExecutionTracking.Next() = 0;

        // Mettre à jour le statut de la tournée à "Terminée"
        PlanificationHeader.Statut := PlanificationHeader.Statut::Stopped;
        PlanificationHeader.Modify(true);

        // Libérer les ressources
        UpdateResourceStatus(PlanificationHeader."Driver No.", PlanificationHeader."Véhicule No.", false);

        // Loguer l'activité
        LogTourActivity(TourNo, 'Tournée terminée', Notes);
    end;

    // Vérifie si tous les arrêts sont terminés
    local procedure CheckIfAllStopsCompleted(TourNo: Code[20])
    var
        TourExecutionTracking: Record "Tour Execution Tracking";
        PendingStops: Boolean;
    begin
        // Vérifier s'il reste des arrêts en attente ou en cours
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);
        TourExecutionTracking.SetFilter(Status, '%1|%2',
            TourExecutionTracking.Status::"En Attente",
            TourExecutionTracking.Status::"En Cours");

        PendingStops := not TourExecutionTracking.IsEmpty();

        if not PendingStops then begin
            // Suggérer la clôture de la tournée
            if Confirm('Tous les arrêts sont terminés. Voulez-vous clôturer la tournée?') then
                CompleteTour(TourNo, 'Clôture automatique - tous les arrêts terminés');
        end;
    end;

    // Met à jour le statut des ressources
    local procedure UpdateResourceStatus(DriverNo: Code[20]; VehicleNo: Code[20]; InMission: Boolean)
    var
        Resource: Record Resource;
    begin
        // Mettre à jour le statut du chauffeur
        if Resource.Get(DriverNo) then begin
            Resource."Resource Status" := SelectResourceStatus(InMission);
            Resource.Modify(true);
        end;

        // Mettre à jour le statut du véhicule
        if Resource.Get(VehicleNo) then begin
            Resource."Resource Status" := SelectResourceStatus(InMission);
            Resource.Modify(true);
        end;
    end;

    // Sélectionne le statut de ressource approprié
    local procedure SelectResourceStatus(InMission: Boolean): Enum "Resource Status"
    begin
        if InMission then
            exit("Resource Status"::OnLeave);
        exit("Resource Status"::Available);
    end;

    // Enregistre une activité de tournée
    local procedure LogTourActivity(TourNo: Code[20]; Activity: Text[100]; Details: Text[250])
    var
        TourActivityLog: Record "Tour Activity Log";
    begin
        TourActivityLog.Init();
        TourActivityLog."Entry No." := 0; // Auto-incrémenté
        TourActivityLog."Tour No." := TourNo;
        //TourActivityLog."Activity Type"" := CopyStr(Activity, 1, 100);
        TourActivityLog."Activity type" := CopyStr(Details, 1, 250);
        TourActivityLog."User ID" := UserId;
        TourActivityLog."Activity Date" := Today;
        TourActivityLog.Insert(true);
    end;

    // Crée un lien entre planification et chargement
    procedure LinkPlanningToLoading(TourNo: Code[20])
    var
        PlanificationHeader: Record "Planification Header";
    begin
        // Vérifier que la tournée existe
        if not PlanificationHeader.Get(TourNo) then
            Error('La tournée %1 n''existe pas.', TourNo);

        // Changer le statut de planifiée à chargement
        if PlanificationHeader.Statut = PlanificationHeader.Statut::Plannified then begin
            PlanificationHeader.Statut := PlanificationHeader.Statut::Loading;
            PlanificationHeader.Modify(true);

            // Loguer l'activité
            LogTourActivity(TourNo, 'Tournée passée en chargement', '');
        end else
            Error('La tournée %1 n''est pas au statut "Planifiée". Statut actuel: %2',
                  TourNo, Format(PlanificationHeader.Statut));
    end;

    procedure InitializeTourExecution(TourNo: Code[20])
    var
        TourHeader: Record "Planification Header";
        VehicleLoadingHeader: Record "Vehicle Loading Header";
        VehicleChargingHeader: Record "Vehicle Charging Header";
        TourExecutionTracking: Record "Tour Execution Tracking";
        TourExecutionMgt: Codeunit "Tour Execution Mgt.";
        IsReadyForExecution: Boolean;
    begin
        // Validate Tour exists
        if not TourHeader.Get(TourNo) then begin
            Message('Tour %1 not found.', TourNo);
            exit;
        end;

        // Check if the tour is ready for execution (has completed loading and charging)
        IsReadyForExecution := false;

        // Check if a loading document exists and is validated
        VehicleLoadingHeader.Reset();
        VehicleLoadingHeader.SetRange("Tour No.", TourNo);
        VehicleLoadingHeader.SetRange(Status, VehicleLoadingHeader.Status::Validated);

        if not VehicleLoadingHeader.FindFirst() then begin
            Message('No validated loading document found for Tour %1. Please complete the loading phase first.', TourNo);
            exit;
        end;

        // Check if a charging document exists and is completed
        VehicleChargingHeader.Reset();
        VehicleChargingHeader.SetRange("Tour No.", TourNo);
        VehicleChargingHeader.SetRange(Status, VehicleChargingHeader.Status::Completed);

        if not VehicleChargingHeader.FindFirst() then begin
            Message('No completed charging document found for Tour %1. Please complete the charging phase first.', TourNo);
            exit;
        end;

        // Check if execution tracking records already exist
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);

        if not TourExecutionTracking.IsEmpty() then begin
            // Records exist, just open the execution page
            Page.Run(PAGE::"Tour Execution Page", TourExecutionTracking);
            exit;
        end;

        // Initialize the execution by calling the Tour Execution Management codeunit
        TourExecutionMgt.StartTourExecution(TourHeader);

        // Refresh the execution tracking records
        TourExecutionTracking.Reset();
        TourExecutionTracking.SetRange("Tour No.", TourNo);

        if TourExecutionTracking.IsEmpty() then begin
            Message('Failed to initialize tour execution records.');
            exit;
        end;

        // Open the execution page with the created records
        Message('Tour execution initialized for Tour %1. Proceeding to execution page.', TourNo);
        Page.Run(PAGE::"Tour Execution Page", TourExecutionTracking);
    end;

    procedure NavigateFromChargingToExecution(ChargingNo: Code[20])
    var
        VehicleChargingHeader: Record "Vehicle Charging Header";
        TourHeader: Record "Planification Header";
    begin
        // Validate Charging Sheet exists
        if not VehicleChargingHeader.Get(ChargingNo) then begin
            Message('Charging Sheet %1 not found.', ChargingNo);
            exit;
        end;

        // Check if charging is completed
        if VehicleChargingHeader.Status <> VehicleChargingHeader.Status::Completed then begin
            Message('Charging Sheet %1 must be completed before proceeding to execution.', ChargingNo);
            exit;
        end;

        // Once all validations pass, initialize the tour execution
        InitializeTourExecution(VehicleChargingHeader."Tour No.");
    end;
}
