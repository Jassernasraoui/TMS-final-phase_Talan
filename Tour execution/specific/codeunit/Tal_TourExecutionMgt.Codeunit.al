codeunit 73551 "Tour Execution Mgt."
{
    procedure StartTourExecution(var TourHeader: Record "Planification Header")
    var
        VehicleLoadingHeader: Record "Vehicle Loading Header";
        VehicleChargingHeader: Record "Vehicle Charging Header";
        VehicleChargingLine: Record "Vehicle Charging Line";
        ActivityLog: Record "Tour Activity Log";
        ExecutionTracking: Record "Tour Execution Tracking";
        PlanningLine: Record "Planning Lines";
        Customer: Record Customer;
        Item: Record Item;
        LineNo: Integer;
    begin
        // Validate tour status - must be in Loading state
        if TourHeader.Statut <> TourHeader.Statut::Loading then
            Error('La tournée doit être en statut Chargement pour démarrer l''exécution');

        // Check if loading document exists and is validated
        VehicleLoadingHeader.Reset();
        VehicleLoadingHeader.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if not VehicleLoadingHeader.FindFirst() then
            Error('Aucun document de chargement trouvé pour la tournée %1', TourHeader."Logistic Tour No.");

        // Check if charging document exists and is completed
        VehicleChargingHeader.Reset();
        VehicleChargingHeader.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        VehicleChargingHeader.SetRange(Status, VehicleChargingHeader.Status::Completed);
        if not VehicleChargingHeader.FindFirst() then
            Error('Aucun document de chargement complété trouvé pour la tournée %1', TourHeader."Logistic Tour No.");

        // Check if execution already started
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if not ExecutionTracking.IsEmpty() then
            Error('L''exécution de la tournée a déjà été démarrée');

        // Update tour status to En Cours (In Progress)       
        TourHeader.Statut := TourHeader.Statut::Inprogress;
        TourHeader.Modify(true);

        // Create tracking records based on charging lines
        VehicleChargingLine.Reset();
        VehicleChargingLine.SetRange("Charging No.", VehicleChargingHeader."Vehicle Charging No.");

        LineNo := 10000;

        if VehicleChargingLine.FindSet() then begin
            repeat
                // Get customer information
                if not Customer.Get(VehicleChargingLine."Customer No.") then
                    Customer.Init();

                // Get item information
                if not Item.Get(VehicleChargingLine."Item No.") then
                    Item.Init();

                // Find corresponding planning line
                PlanningLine.Reset();
                PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                PlanningLine.SetRange("Customer No.", VehicleChargingLine."Customer No.");
                if not PlanningLine.FindFirst() then
                    PlanningLine.Init();

                // Create execution tracking record
                ExecutionTracking.Init();
                ExecutionTracking."Line No." := LineNo;
                ExecutionTracking."Tour No." := TourHeader."Logistic Tour No.";
                ExecutionTracking."Customer No." := VehicleChargingLine."Customer No.";
                ExecutionTracking."Customer Name" := Customer.Name;
                ExecutionTracking."Planning Line No." := PlanningLine."Line No.";
                ExecutionTracking.Status := ExecutionTracking.Status::"En Attente";
                ExecutionTracking."Date Livraison" := Today;
                ExecutionTracking."Tournée Terminée" := false;

                // Ajouter les informations de l'article depuis la ligne de chargement
                ExecutionTracking."Item No." := VehicleChargingLine."Item No.";
                ExecutionTracking."Item Description" := Item.Description;
                ExecutionTracking."Unit of Measure Code" := VehicleChargingLine."Unit of Measure Code";
                ExecutionTracking."Planned Quantity" := VehicleChargingLine."Actual Quantity";
                ExecutionTracking."Delivery Address" := Customer.Address;

                // Pour les documents de type achat, remplir automatiquement la quantité retournée avec la quantité planifiée
                if VehicleChargingLine."Document Type" = VehicleChargingLine."Document Type"::Purchase then begin
                    ExecutionTracking."Quantity Returned" := VehicleChargingLine."Actual Quantity";
                    ExecutionTracking."Quantity Delivered" := 0;
                end;

                // Ajouter des notes de livraison si nécessaire
                // if VehicleChargingLine."Loading Status" <> '' then
                ExecutionTracking."Notes Livraison" := StrSubstNo('Statut de chargement: %1', VehicleChargingLine."Loading Status");

                ExecutionTracking.Insert(true);
                LineNo += 10000;
            until VehicleChargingLine.Next() = 0;
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
        TotalReturnedQty: Decimal;
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

        // Mark all tracking records as tour completed and calculate total returned quantity
        TotalReturnedQty := 0;
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if ExecutionTracking.FindSet() then begin
            repeat
                ExecutionTracking."Tournée Terminée" := true;
                ExecutionTracking.Modify(true);
                TotalReturnedQty += ExecutionTracking."Quantity Returned";
            until ExecutionTracking.Next() = 0;
        end;

        // Create return transfer order if there are returned quantities
        if TotalReturnedQty > 0 then
            CreateReturnTransferOrder(TourHeader);

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
        TotalPlannedQty: Decimal;
        TotalDeliveredQty: Decimal;
        TotalReturnedQty: Decimal;
        Summary: Text;
    begin
        if not TourHeader.Get(TourNo) then
            exit('Tournée non trouvée');

        // Get statistics
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        DeliveredCount := ExecutionTracking.Count;

        // Calculer les totaux des quantités
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        if ExecutionTracking.FindSet() then
            repeat
                TotalPlannedQty += ExecutionTracking."Planned Quantity";
                TotalDeliveredQty += ExecutionTracking."Quantity Delivered";
                TotalReturnedQty += ExecutionTracking."Quantity Returned";
            until ExecutionTracking.Next() = 0;

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

        Summary += '\n\nRésumé des quantités:\n';
        Summary += StrSubstNo('- Quantité planifiée totale: %1\n', Format(TotalPlannedQty));
        Summary += StrSubstNo('- Quantité livrée totale: %1\n', Format(TotalDeliveredQty));
        Summary += StrSubstNo('- Quantité retournée totale: %1\n', Format(TotalReturnedQty));

        if TotalReturnedQty > 0 then
            Summary += StrSubstNo('- Taux de retour: %1 %\n', Format(Round(TotalReturnedQty / TotalPlannedQty * 100, 0.01)));

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

    local procedure CreateReturnTransferOrder(TourHeader: Record "Planification Header")
    var
        ExecutionTracking: Record "Tour Execution Tracking";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        VehicleChargingHeader: Record "Vehicle Charging Header";
        LineNo: Integer;
        ReturnTransferOrderNo: Code[20];
    begin
        // Find the vehicle charging header for this tour
        VehicleChargingHeader.Reset();
        VehicleChargingHeader.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if not VehicleChargingHeader.FindFirst() then
            Error('Aucun document de chargement trouvé pour la tournée %1', TourHeader."Logistic Tour No.");

        // Create new transfer header for returns
        TransferHeader.Init();
        TransferHeader."No." := '';
        TransferHeader.Insert(true);
        ReturnTransferOrderNo := TransferHeader."No.";

        // Set Transfer Header fields - reverse direction from original transfer
        TransferHeader.Validate("Transfer-from Code", VehicleChargingHeader."Truck No."); // From the vehicle
        TransferHeader.Validate("Transfer-to Code", 'blanc'); // Back to warehouse
        TransferHeader.Validate("In-Transit Code", 'INTERNE');
        TransferHeader.Validate("Shipment Date", Today);
        TransferHeader.Validate("Receipt Date", Today);
        TransferHeader.Validate("Logistic Tour No.", TourHeader."Logistic Tour No.");
        TransferHeader.Validate("Document DateTime", CurrentDateTime);
        TransferHeader.Validate("Requested Shipment DateTime", CurrentDateTime);
        TransferHeader.Validate("Return Transfer", true); // Mark as return transfer
        TransferHeader.Modify(true);

        // Create Transfer Lines for returned quantities
        LineNo := 10000;
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourHeader."Logistic Tour No.");
        if ExecutionTracking.FindSet() then begin
            repeat
                if ExecutionTracking."Quantity Returned" > 0 then begin
                    TransferLine.Init();
                    TransferLine."Document No." := ReturnTransferOrderNo;
                    TransferLine."Line No." := LineNo;
                    TransferLine.Validate("Item No.", ExecutionTracking."Item No.");
                    TransferLine.Validate("Unit of Measure Code", ExecutionTracking."Unit of Measure Code");
                    TransferLine.Validate(Quantity, ExecutionTracking."Quantity Returned");
                    TransferLine.Validate("Logistic Tour No.", TourHeader."Logistic Tour No.");
                    TransferLine.Validate("Qty. to Ship", ExecutionTracking."Quantity Returned");

                    // Add return reason if available
                    // if ExecutionTracking."Return Reason Code" <> '' then
                    //     TransferLine.Validate("Return Reason Code", ExecutionTracking."Return Reason Code");

                    TransferLine.Insert(true);
                    LineNo += 10000;
                end;
            until ExecutionTracking.Next() = 0;
        end;

        // Log the creation of return transfer order
        LogTourActivity(
            TourHeader."Logistic Tour No.",
            'Ordre de transfert retour créé',
            StrSubstNo('Ordre de transfert retour %1 créé pour les quantités retournées', ReturnTransferOrderNo));
    end;
}