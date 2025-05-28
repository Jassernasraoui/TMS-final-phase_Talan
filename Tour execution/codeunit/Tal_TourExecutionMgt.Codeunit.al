codeunit 77051 "Tour Execution Mgt."
{
    procedure StartTourExecution(var TourHeader: Record "Planification Header")
    var
        VehicleLoadingHeader: Record "Vehicle Loading Header";
        ActivityLog: Record "Tour Activity Log";
        ExecutionTracking: Record "Tour Execution Tracking";
        PlanningLine: Record "Planning Lines";
        Customer: Record Customer;
    begin
        // Validate tour status - must be in Loading state
        if TourHeader.Statut <> TourHeader.Statut::Loading then
            Error('La tournée doit être en statut Chargement pour démarrer l''exécution');

        // Check if loading document exists and is validated
        VehicleLoadingHeader.Reset();
        VehicleLoadingHeader.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if not VehicleLoadingHeader.FindFirst() then
            Error('Aucun document de chargement trouvé pour la tournée %1', TourHeader."Logistic Tour No.");

        // Check if execution already started
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if not ExecutionTracking.IsEmpty() then
            Error('L''exécution de la tournée a déjà été démarrée');

        // Update tour status to En Cours (In Progress)        TourHeader.Statut := TourHeader.Statut::EnCours;
        TourHeader.Modify(true);

        // Create tracking records for each customer in planning lines
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLine.SetCurrentKey("Customer No.");

        if PlanningLine.FindSet() then begin
            repeat
                if not Customer.Get(PlanningLine."Customer No.") then
                    Customer.Init();

                if not ExecutionTracking.Get(0, TourHeader."Logistic Tour No.") then begin
                    ExecutionTracking.Init();
                    ExecutionTracking."Line No." := GetNextTrackingLineNo();
                    ExecutionTracking."Tour No." := TourHeader."Logistic Tour No.";
                    ExecutionTracking."Customer No." := PlanningLine."Customer No.";
                    ExecutionTracking."Customer Name" := Customer.Name;
                    ExecutionTracking."Planning Line No." := PlanningLine."Line No.";
                    ExecutionTracking.Status := ExecutionTracking.Status::"En Attente";
                    ExecutionTracking."Date Livraison" := Today;
                    ExecutionTracking."Tournée Terminée" := false;
                    ExecutionTracking.Insert(true);
                end;
            until PlanningLine.Next() = 0;
        end;

        // Log the execution start
        LogTourActivity(TourHeader."Logistic Tour No.", 'Démarrage de l''exécution', 'La tournée a démarré avec le chauffeur ' + TourHeader."Driver No.");
    end;

    procedure UpdateDeliveryStatus(var ExecutionTracking: Record "Tour Execution Tracking"; NewStatus: Option)
    var
        TourActivityLog: Record "Tour Activity Log";
        Customer: Record Customer;
        StatusText: Text[50];
    begin
        if not Customer.Get(ExecutionTracking."Customer No.") then
            Customer.Init();

        // Update status and timestamps
        ExecutionTracking.Status := NewStatus;

        case NewStatus of
            ExecutionTracking.Status::"En Cours":
                StatusText := 'En Cours';
            ExecutionTracking.Status::"Livré":
                StatusText := 'Livré';
            ExecutionTracking.Status::"Échoué":
                StatusText := 'Échoué';
            ExecutionTracking.Status::"Reporté":
                StatusText := 'Reporté';
        end;

        ExecutionTracking."Heure Livraison" := Time;
        ExecutionTracking."Date Livraison" := Today;
        ExecutionTracking.Modify(true);

        // Log the activity
        LogTourActivity(
            ExecutionTracking."Tour No.",
            'Mise à jour statut livraison',
            StrSubstNo('Client %1: %2', Customer.Name, StatusText));
    end;

    procedure AddDeliveryNote(var ExecutionTracking: Record "Tour Execution Tracking"; Note: Text[250])
    begin
        ExecutionTracking."Notes Livraison" := Note;
        ExecutionTracking.Modify(true);

        // Log the note addition
        LogTourActivity(
            ExecutionTracking."Tour No.",
            'Note de livraison ajoutée',
            StrSubstNo('Note pour client %1', ExecutionTracking."Customer No."));
    end;

    // procedure CaptureSignature(var ExecutionTracking: Record "Tour Execution Tracking"; SignatureText: Text)
    // var
    //     TempBlob: Codeunit "Temp Blob";
    //     OutStream: OutStream;
    //     InStream: InStream;
    // begin
    //     // Store simple text signature (in real app this would be image data)
    //     TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
    //     OutStream.WriteText(SignatureText);
    //     TempBlob.CreateInStream(InStream, TextEncoding::UTF8);

    //     ExecutionTracking."Signature Client".ImportStream(InStream, 'Signature');
    //     ExecutionTracking.Modify(true);

    //     // Log the signature capture
    //     LogTourActivity(
    //         ExecutionTracking."Tour No.",
    //         'Signature client capturée',
    //         StrSubstNo('Signature capturée pour client %1', ExecutionTracking."Customer No."));
    // end;

    procedure RecordGPSLocation(var ExecutionTracking: Record "Tour Execution Tracking"; GPSCoords: Text[50])
    begin
        ExecutionTracking."GPS Coordonnées" := GPSCoords;
        ExecutionTracking.Modify(true);

        // Log the GPS recording
        LogTourActivity(
            ExecutionTracking."Tour No.",
            'Position GPS enregistrée',
            StrSubstNo('Position GPS pour client %1: %2', ExecutionTracking."Customer No.", GPSCoords));
    end;

    procedure CompleteTour(var TourHeader: Record "Planification Header")
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        PendingDeliveries: Boolean;
    begin
        // Validate tour is in execution        if TourHeader.Statut <> TourHeader.Statut::EnCours then            Error('La tournée doit être en statut En Cours pour être terminée');

        // Check if all deliveries are complete or failed
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"En Attente");
        PendingDeliveries := not ExecutionTracking.IsEmpty();

        // Update all remaining deliveries as failed
        if PendingDeliveries then begin
            if ExecutionTracking.FindSet() then begin
                repeat
                    ExecutionTracking.Status := ExecutionTracking.Status::"Échoué";
                    ExecutionTracking.Modify(true);
                until ExecutionTracking.Next() = 0;
            end;
        end;

        // Update tour status to Stopped/Terminé
        TourHeader.Statut := TourHeader.Statut::Stopped; // Using existing status as Terminé
        TourHeader.Modify(true);

        // Mark all tracking records as tour completed
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if ExecutionTracking.FindSet() then begin
            repeat
                ExecutionTracking."Tournée Terminée" := true;
                ExecutionTracking.Modify(true);
            until ExecutionTracking.Next() = 0;
        end;

        // Log the completion
        LogTourActivity(
            TourHeader."Logistic Tour No.",
            'Tournée terminée',
            'Tournée terminée avec ' + Format(GetDeliveryStats(TourHeader."Logistic Tour No.")));
    end;

    procedure GenerateTourSummary(TourNo: Code[20]): Text
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        TourHeader: Record "Planification Header";
        DeliveredCount: Integer;
        FailedCount: Integer;
        PostponedCount: Integer;
        Summary: Text;
    begin
        if not TourHeader.Get(TourNo) then
            exit('Tournée non trouvée');

        // Get statistics
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        DeliveredCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
        FailedCount := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
        PostponedCount := ExecutionTracking.Count;

        // Generate summary text
        Summary := StrSubstNo(
            'Récapitulatif tournée %1:\n' +
            'Livrés: %2\n' +
            'Échoués: %3\n' +
            'Reportés: %4\n' +
            'Date de tournée: %5\n' +
            'Chauffeur: %6',
            TourNo, DeliveredCount, FailedCount, PostponedCount,
            Format(TourHeader."Date de Tournée"), TourHeader."Driver No.");

        exit(Summary);
    end;

    local procedure LogTourActivity(TourNo: Code[20]; ActivityType: Text[100]; Description: Text[250])
    var
        TourActivityLog: Record "Tour Activity Log";
    begin
        TourActivityLog.Init();
        TourActivityLog."Entry No." := 0; // Auto-increment
        TourActivityLog."Tour No." := TourNo;
        TourActivityLog."Activity Date" := Today;
        TourActivityLog."Activity Time" := Time;
        TourActivityLog."Activity Type" := ActivityType;
        TourActivityLog.Description := Description;
        TourActivityLog."User ID" := UserId;
        TourActivityLog.Insert(true);
    end;

    local procedure GetNextTrackingLineNo(): Integer
    var
        ExecutionTracking: Record "Tour Execution Tracking";
    begin
        ExecutionTracking.Reset();
        if ExecutionTracking.FindLast() then
            exit(ExecutionTracking."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetDeliveryStats(TourNo: Code[20]): Text
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        Delivered: Integer;
        Failed: Integer;
        Postponed: Integer;
        TotalStops: Integer;
    begin
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        TotalStops := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        Delivered := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Échoué");
        Failed := ExecutionTracking.Count;

        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Reporté");
        Postponed := ExecutionTracking.Count;

        exit(StrSubstNo('%1 livraisons sur %2 (%3 échouées, %4 reportées)',
            Delivered, TotalStops, Failed, Postponed));
    end;
}