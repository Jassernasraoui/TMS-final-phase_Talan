codeunit 73652 "Planning Lines Management"
{
    // Codeunit pour gérer les fonctionnalités de la planification des tournées

    procedure AddDocumentToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Debug information
        Message('Adding document to tour: %1, Document: %2-%3',
                TourHeader."Logistic Tour No.", Format(DocBuffer."Document Type"), DocBuffer."Document No.");

        // Validate that we have a valid tour number
        if TourHeader."Logistic Tour No." = '' then begin
            Error('Tour number is missing in the TourHeader record.');
            exit;
        end;

        // Ensure the DocBuffer has the correct tour number
        DocBuffer."Tour No." := TourHeader."Logistic Tour No.";

        // Proceed with document addition based on type
        case DocBuffer."Document Type" of
            DocBuffer."Document Type"::"Sales Order":
                begin
                    AddSalesOrderToTour(TourHeader, DocBuffer);
                    // Update the Sales Header with the tour number
                    UpdateSalesHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding all lines
                    CheckVehicleCompatibility(TourHeader);
                end;
            DocBuffer."Document Type"::"Purchase Order":
                begin
                    AddPurchaseOrderToTour(TourHeader, DocBuffer);
                    // Update the Purchase Header with the tour number
                    UpdatePurchaseHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding all lines
                    CheckVehicleCompatibility(TourHeader);
                end;
            DocBuffer."Document Type"::"Transfer Order":
                begin
                    AddTransferOrderToTour(TourHeader, DocBuffer);
                    // Update the Transfer Header with the tour number
                    UpdateTransferHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding all lines
                    CheckVehicleCompatibility(TourHeader);
                end;
            else
                Error('Unsupported document type: %1', Format(DocBuffer."Document Type"));
        end;
    end;

    local procedure AddSalesOrderToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Debug message to track execution
        Message('Starting to add Sales Order %1 to Tour %2', DocBuffer."Document No.", TourHeader."Logistic Tour No.");

        // Vérifier que la commande client existe
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", DocBuffer."Document No.");
        if not SalesHeader.FindFirst() then begin
            Error('Sales Order %1 not found', DocBuffer."Document No.");
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Ajouter chaque ligne de la commande
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then begin
            repeat
                if SalesLine.Type = SalesLine.Type::Item then begin
                    Clear(PlanningLine);
                    PlanningLine.Init();
                    PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
                    PlanningLine."Line No." := NextLineNo;
                    PlanningLine.Type := PlanningLine.Type::Sales;
                    PlanningLine."Source ID" := SalesLine."Document No.";
                    PlanningLine."Item No." := SalesLine."No.";
                    PlanningLine.Description := SalesLine.Description;
                    PlanningLine."Description 2" := SalesLine."Description 2";
                    PlanningLine.Quantity := SalesLine.Quantity;
                    PlanningLine."Quantity (Base)" := SalesLine."Quantity (Base)";
                    PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
                    PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                    PlanningLine."Expected Shipment Date" := SalesLine."Shipment Date";
                    PlanningLine."Customer No." := SalesLine."Sell-to Customer No.";
                    //Bilel - salah hedhi jasser + dans les purch+transfer orders +( dans les vehicle preparation +salah lines no)
                    PlanningLine."Account No." := SalesLine."Sell-to Customer no.";
                    PlanningLine."Location Code" := Salesline."Location Code";
                    PlanningLine." Delivery Date" := SalesLine."Shipment Date";
                    PlanningLine."Net Weight" := SalesLine."Net Weight";
                    PlanningLine."Gross Weight" := SalesLine."Gross Weight";
                    PlanningLine."Unit Volume" := SalesLine."Unit Volume";

                    // Valeurs par défaut pour les nouveaux champs
                    if (SalesLine."planned Shipment Date" >= TourHeader."Start Date") and
                       (SalesLine."planned Shipment Date" <= TourHeader."End Date") then
                        PlanningLine."Assigned Day" := SalesLine."Shipment Date"
                    else if (SalesLine."planned Shipment Date" >= TourHeader."Start Date") and
                            (SalesLine."planned Shipment Date" <= TourHeader."End Date") then
                        PlanningLine."Assigned Day" := SalesLine."planned Shipment Date"
                    else
                        PlanningLine."Assigned Day" := TourHeader."Start Date";

                    // Extraire ou définir la priorité
                    case DocBuffer.Priority of
                        DocBuffer.Priority::Low:
                            PlanningLine.Priority := PlanningLine.Priority::Low;
                        DocBuffer.Priority::Normal:
                            PlanningLine.Priority := PlanningLine.Priority::Normal;
                        DocBuffer.Priority::High:
                            PlanningLine.Priority := PlanningLine.Priority::High;
                        DocBuffer.Priority::Critical:
                            PlanningLine.Priority := PlanningLine.Priority::Critical;
                    end;

                    // Définir le type d'activité à Livraison pour une commande client
                    PlanningLine."Activity Type" := PlanningLine."Activity Type"::Delivery;

                    if PlanningLine.Insert() then begin
                        NextLineNo += 10000;
                        LinesAdded += 1;
                        Message('Successfully added line %1 for item %2', PlanningLine."Line No.", PlanningLine."Item No.");
                    end else begin
                        Error('Failed to insert planning line for Sales Order %1, Line %2: %3',
                            SalesLine."Document No.", SalesLine."Line No.", GetLastErrorText);
                    end;
                end;
            until SalesLine.Next() = 0;

            if LinesAdded > 0 then
                Message('%1 lines were added from Sales Order %2 to tour %3',
                        LinesAdded, SalesHeader."No.", TourHeader."Logistic Tour No.");
        end else
            Message('No valid sales lines found in Sales Order %1', SalesHeader."No.");

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    local procedure AddPurchaseOrderToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Vérifier que la commande fournisseur existe
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("No.", DocBuffer."Document No.");
        if not PurchHeader.FindFirst() then begin
            PlanningDiag.LogPlanningLineIssues(TourHeader."Logistic Tour No.", '',
                StrSubstNo('Purchase Order %1 not found', DocBuffer."Document No."));
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Ajouter chaque ligne de la commande
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindSet() then begin
            repeat
                if PurchLine.Type = PurchLine.Type::Item then begin
                    Clear(PlanningLine);
                    PlanningLine.Init();
                    PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
                    PlanningLine."Line No." := NextLineNo;
                    PlanningLine.Type := PlanningLine.Type::Purchase;
                    PlanningLine."Source ID" := PurchLine."Document No.";
                    PlanningLine."Item No." := PurchLine."No.";
                    PlanningLine.Description := PurchLine.Description;
                    PlanningLine."Description 2" := PurchLine."Description 2";
                    PlanningLine.Quantity := PurchLine.Quantity;
                    PlanningLine."Quantity (Base)" := PurchLine."Quantity (Base)";
                    PlanningLine."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
                    PlanningLine."Unit of Measure Code" := PurchLine."Unit of Measure Code";
                    PlanningLine."Expected Receipt Date" := PurchLine."Expected Receipt Date";
                    PlanningLine."Vendor No." := PurchLine."Buy-from Vendor No.";
                    // PlanningLine."Account No." := PurchHeader."Buy-from Vendor Name";
                    PlanningLine."Account No." := PurchLine."Buy-from Vendor No.";

                    PlanningLine."Location Code" := PurchLine."Location Code";
                    PlanningLine." Delivery Date" := PurchLine."Expected Receipt Date";

                    // Valeurs par défaut pour les nouveaux champs
                    if (PurchLine."Expected Receipt Date" >= TourHeader."Start Date") and
                       (PurchLine."Expected Receipt Date" <= TourHeader."End Date") then
                        PlanningLine."Assigned Day" := PurchLine."Expected Receipt Date"
                    else
                        PlanningLine."Assigned Day" := TourHeader."Start Date";

                    // Extraire ou définir la priorité
                    case DocBuffer.Priority of
                        DocBuffer.Priority::Low:
                            PlanningLine.Priority := PlanningLine.Priority::Low;
                        DocBuffer.Priority::Normal:
                            PlanningLine.Priority := PlanningLine.Priority::Normal;
                        DocBuffer.Priority::High:
                            PlanningLine.Priority := PlanningLine.Priority::High;
                        DocBuffer.Priority::Critical:
                            PlanningLine.Priority := PlanningLine.Priority::Critical;
                    end;

                    // Définir le type d'activité à Ramassage pour une commande fournisseur
                    PlanningLine."Activity Type" := PlanningLine."Activity Type"::Pickup;

                    if PlanningLine.Insert() then begin
                        NextLineNo += 10000;
                        LinesAdded += 1;
                    end else
                        PlanningDiag.LogPlanningLineIssues(TourHeader."Logistic Tour No.", PurchLine."No.",
                            StrSubstNo('Failed to insert planning line for Purchase Order %1, Line %2',
                                PurchLine."Document No.", PurchLine."Line No."));
                end;
            until PurchLine.Next() = 0;

            if LinesAdded > 0 then
                Message('%1 lines were added from Purchase Order %2', LinesAdded, PurchHeader."No.");
        end else
            Message('No valid purchase lines found in Purchase Order %1', PurchHeader."No.");

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    local procedure AddTransferOrderToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Vérifier que l'ordre de transfert existe
        if not TransferHeader.Get(DocBuffer."Document No.") then begin
            PlanningDiag.LogPlanningLineIssues(TourHeader."Logistic Tour No.", '',
                StrSubstNo('Transfer Order %1 not found', DocBuffer."Document No."));
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Ajouter chaque ligne de l'ordre de transfert
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindSet() then begin
            repeat
                Clear(PlanningLine);
                PlanningLine.Init();
                PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
                PlanningLine."Line No." := NextLineNo;
                PlanningLine.Type := PlanningLine.Type::Transfer;
                PlanningLine."Source ID" := TransferLine."Document No.";
                PlanningLine."Item No." := TransferLine."Item No.";
                PlanningLine.Description := TransferLine.Description;
                PlanningLine."Description 2" := '';
                PlanningLine.Quantity := TransferLine.Quantity;
                PlanningLine."Quantity (Base)" := TransferLine."Quantity (Base)";
                PlanningLine."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                PlanningLine."Unit of Measure Code" := TransferLine."Unit of Measure Code";
                PlanningLine."Transfer-from Code" := TransferLine."Transfer-from Code";
                PlanningLine."Location Code" := TransferLine."Transfer-to Code";
                PlanningLine."Expected Receipt Date" := TransferLine."Receipt Date";
                PlanningLine." Delivery Date" := TransferLine."Receipt Date";

                // Valeurs par défaut pour les nouveaux champs
                if (TransferHeader."Receipt Date" >= TourHeader."Start Date") and
                   (TransferHeader."Receipt Date" <= TourHeader."End Date") then
                    PlanningLine."Assigned Day" := TransferHeader."Receipt Date"
                else if (TransferHeader."Shipment Date" >= TourHeader."Start Date") and
                        (TransferHeader."Shipment Date" <= TourHeader."End Date") then
                    PlanningLine."Assigned Day" := TransferHeader."Shipment Date"
                else
                    PlanningLine."Assigned Day" := TourHeader."Start Date";

                // Extraire ou définir la priorité
                case DocBuffer.Priority of
                    DocBuffer.Priority::Low:
                        PlanningLine.Priority := PlanningLine.Priority::Low;
                    DocBuffer.Priority::Normal:
                        PlanningLine.Priority := PlanningLine.Priority::Normal;
                    DocBuffer.Priority::High:
                        PlanningLine.Priority := PlanningLine.Priority::High;
                    DocBuffer.Priority::Critical:
                        PlanningLine.Priority := PlanningLine.Priority::Critical;
                end;

                // Définir le type d'activité à Livraison pour un ordre de transfert
                PlanningLine."Activity Type" := PlanningLine."Activity Type"::Delivery;

                if PlanningLine.Insert() then begin
                    NextLineNo += 10000;
                    LinesAdded += 1;
                end else
                    PlanningDiag.LogPlanningLineIssues(TourHeader."Logistic Tour No.", TransferLine."Item No.",
                        StrSubstNo('Failed to insert planning line for Transfer Order %1, Line %2',
                            TransferLine."Document No.", TransferLine."Line No."));
            until TransferLine.Next() = 0;

            if LinesAdded > 0 then
                Message('%1 lines were added from Transfer Order %2', LinesAdded, TransferHeader."No.");
        end else
            Message('No valid transfer lines found in Transfer Order %1', TransferHeader."No.");

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    procedure AutoAssignDays(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        PlanningLine2: Record "Planning Lines";
        PlanningLineSuggestion: Record "Planning Lines" temporary;
        StartDate: Date;
        EndDate: Date;
        CurrentDate: Date;
        DayCount: Integer;
        LinesPerDay: Integer;
        NonWorkingDays: Text;
        IsWorkingDay: Boolean;
        OptimalDay: Date;
        DayWorkload: array[100] of Integer;
        DayArray: array[100] of Date;
        i: Integer;
        LeastBusyDayIndex: Integer;
        LeastBusyCount: Integer;
        Window: Dialog;
        ProgressCounter: Integer;
        TotalLines: Integer;
        LinesModified: Integer;
        DocType: Text;
        DayAssignment: Text;
        SuggestionPage: Page "Planning Optimization";
        ApplyChanges: Boolean;
    begin
        // Basic validation
        if TourHeader."Logistic Tour No." = '' then
            Error('Le numéro de tournée n''est pas défini. Veuillez sauvegarder d''abord la tournée.');

        if (TourHeader."Start Date" = 0D) or (TourHeader."End Date" = 0D) then
            Error('Les dates de début et de fin de la tournée doivent être définies.');

        // Get date range
        StartDate := TourHeader."Start Date";
        EndDate := TourHeader."End Date";

        if StartDate > EndDate then
            Error('La date de début ne peut pas être postérieure à la date de fin.');

        // Build array of working days
        NonWorkingDays := TourHeader."Non-Working Days";
        CurrentDate := StartDate;
        i := 0;

        while CurrentDate <= EndDate do begin
            IsWorkingDay := not IsNonWorkingDay(CurrentDate, NonWorkingDays);
            if IsWorkingDay then begin
                i += 1;
                DayArray[i] := CurrentDate;
            end;
            CurrentDate := CalcDate('<+1D>', CurrentDate);
        end;

        DayCount := i;

        if DayCount = 0 then
            Error('Aucun jour ouvré disponible dans l''intervalle de tournée.');

        // Count existing lines and initialize workload array
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        TotalLines := PlanningLine.Count();

        if TotalLines = 0 then
            Error('Aucune ligne de planification trouvée pour cette tournée.');

        // Calculate average lines per day
        LinesPerDay := TotalLines div DayCount;
        if (TotalLines mod DayCount) > 0 then
            LinesPerDay += 1;

        // Calculate current workload for each day
        for i := 1 to DayCount do begin
            PlanningLine.Reset();
            PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
            PlanningLine.SetRange("Assigned Day", DayArray[i]);
            DayWorkload[i] := PlanningLine.Count();
        end;

        // Show progress dialog
        Window.Open('Création des suggestions: @1@@@@@@@@@@\Ligne: #2#### / #3####');
        Window.Update(1, 0);
        Window.Update(3, TotalLines);

        // Clear any existing temporary records
        PlanningLineSuggestion.Reset();
        PlanningLineSuggestion.DeleteAll();

        // Process all planning lines - create suggestions
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");

        if PlanningLine.FindSet() then begin
            repeat
                ProgressCounter += 1;
                Window.Update(1, Round(ProgressCounter / TotalLines * 10000, 1));
                Window.Update(2, ProgressCounter);

                // Determine document type for report
                case PlanningLine.Type of
                    PlanningLine.Type::Sales:
                        DocType := 'Commande client';
                    PlanningLine.Type::Purchase:
                        DocType := 'Commande fournisseur';
                    PlanningLine.Type::Transfer:
                        DocType := 'Ordre de transfert';
                end;

                // Determine optimal day based on various factors
                Clear(OptimalDay);
                Clear(DayAssignment);

                // 1. Check if planned date is valid
                if (PlanningLine." Delivery Date" >= StartDate) and (PlanningLine." Delivery Date" <= EndDate) then begin
                    // Verify it's a working day
                    if IsWorkingDay(PlanningLine." Delivery Date", NonWorkingDays) then begin
                        OptimalDay := PlanningLine." Delivery Date";
                        DayAssignment := 'Date planifiée du document';
                    end;
                end;

                // 2. If no planned date, check document dates
                if OptimalDay = 0D then begin
                    case PlanningLine.Type of
                        PlanningLine.Type::Sales:
                            if PlanningLine."Expected Shipment Date" <> 0D then begin
                                if (PlanningLine."Expected Shipment Date" >= StartDate) and
                                    (PlanningLine."Expected Shipment Date" <= EndDate) and
                                    IsWorkingDay(PlanningLine."Expected Shipment Date", NonWorkingDays) then begin
                                    OptimalDay := PlanningLine."Expected Shipment Date";
                                    DayAssignment := 'Date d''expédition';
                                end;
                            end;
                        PlanningLine.Type::Purchase:
                            if PlanningLine."Expected Receipt Date" <> 0D then begin
                                if (PlanningLine."Expected Receipt Date" >= StartDate) and
                                    (PlanningLine."Expected Receipt Date" <= EndDate) and
                                    IsWorkingDay(PlanningLine."Expected Receipt Date", NonWorkingDays) then begin
                                    OptimalDay := PlanningLine."Expected Receipt Date";
                                    DayAssignment := 'Date de réception';
                                end;
                            end;
                        PlanningLine.Type::Transfer:
                            if PlanningLine."Expected Receipt Date" <> 0D then begin
                                if (PlanningLine."Expected Receipt Date" >= StartDate) and
                                    (PlanningLine."Expected Receipt Date" <= EndDate) and
                                    IsWorkingDay(PlanningLine."Expected Receipt Date", NonWorkingDays) then begin
                                    OptimalDay := PlanningLine."Expected Receipt Date";
                                    DayAssignment := 'Date de réception transfert';
                                end;
                            end;
                    end;
                end;

                // 3. If still no day, use priority-based assignment
                if OptimalDay = 0D then begin
                    if PlanningLine.Priority in [PlanningLine.Priority::High, PlanningLine.Priority::Critical] then begin
                        OptimalDay := DayArray[1]; // First day for high priority
                        DayAssignment := 'Priorité élevée (début de tournée)';
                    end
                    else if PlanningLine.Priority = PlanningLine.Priority::Low then begin
                        OptimalDay := DayArray[DayCount]; // Last day for low priority
                        DayAssignment := 'Priorité basse (fin de tournée)';
                    end
                    else begin
                        // Normal priority - look for least busy day with similar locations
                        PlanningLine2.Reset();
                        PlanningLine2.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                        PlanningLine2.SetRange("Location Code", PlanningLine."Location Code");
                        PlanningLine2.SetFilter("Line No.", '<>%1', PlanningLine."Line No.");

                        // Check if there are other lines with same location
                        if PlanningLine2.FindSet() then begin
                            // Try to find a day where we already have this location
                            LeastBusyCount := 9999;
                            LeastBusyDayIndex := 1;

                            repeat
                                if PlanningLine2."Assigned Day" <> 0D then begin
                                    // Check if this day is in our working day range
                                    for i := 1 to DayCount do begin
                                        if DayArray[i] = PlanningLine2."Assigned Day" then begin
                                            // Prefer days with this location but fewer lines
                                            if DayWorkload[i] < LeastBusyCount then begin
                                                LeastBusyCount := DayWorkload[i];
                                                LeastBusyDayIndex := i;
                                                DayAssignment := 'Groupé par emplacement';
                                            end;
                                            break;
                                        end;
                                    end;
                                end;
                            until PlanningLine2.Next() = 0;

                            // If we found a match, use it
                            if DayAssignment = 'Groupé par emplacement' then
                                OptimalDay := DayArray[LeastBusyDayIndex];
                        end;

                        // If still no day, find least busy day
                        if OptimalDay = 0D then begin
                            LeastBusyCount := 9999;
                            LeastBusyDayIndex := 1;

                            for i := 1 to DayCount do begin
                                if DayWorkload[i] < LeastBusyCount then begin
                                    LeastBusyCount := DayWorkload[i];
                                    LeastBusyDayIndex := i;
                                end;
                            end;

                            OptimalDay := DayArray[LeastBusyDayIndex];
                            DayAssignment := 'Équilibrage de charge';
                        end;
                    end;
                end;

                // If we found an optimal day and it's different from current, create suggestion
                if (OptimalDay <> 0D) and (OptimalDay <> PlanningLine."Assigned Day") then begin
                    // Create suggestion record
                    PlanningLineSuggestion.Init();
                    PlanningLineSuggestion.TransferFields(PlanningLine);
                    PlanningLineSuggestion."Line No." := PlanningLine."Line No.";

                    // Store original day in Description 2 field for reference
                    PlanningLineSuggestion."Description 2" := Format(PlanningLine."Assigned Day") + ' -> ' + Format(OptimalDay) + ' (' + DayAssignment + ')';

                    // Set new assigned day
                    PlanningLineSuggestion."Assigned Day" := OptimalDay;

                    // Set flag in a field to indicate it's a suggestion
                    PlanningLineSuggestion."Selected" := true;

                    // Insert suggestion
                    PlanningLineSuggestion.Insert();

                    LinesModified += 1;

                    // Update workload counters for accurate subsequent suggestions
                    // Decrement old day (if valid)
                    if PlanningLine."Assigned Day" <> 0D then begin
                        for i := 1 to DayCount do begin
                            if DayArray[i] = PlanningLine."Assigned Day" then begin
                                DayWorkload[i] -= 1;
                                break;
                            end;
                        end;
                    end;

                    // Increment new day
                    for i := 1 to DayCount do begin
                        if DayArray[i] = OptimalDay then begin
                            DayWorkload[i] += 1;
                            break;
                        end;
                    end;
                end;
            until PlanningLine.Next() = 0;
        end;

        Window.Close();

        // Show suggestions and ask for confirmation
        if LinesModified > 0 then begin
            // Set data in suggestions page and show
            SuggestionPage.SetSuggestions(PlanningLineSuggestion, TourHeader."Logistic Tour No.");

            if SuggestionPage.RunModal() = Action::OK then begin
                Window.Open('Application des changements: @1@@@@@@@@@@');
                Window.Update(1, 0);

                // Clear our temporary table to get only selected suggestions
                PlanningLineSuggestion.Reset();
                PlanningLineSuggestion.DeleteAll();

                // Get selected suggestions from the page
                SuggestionPage.GetSelectedSuggestions(PlanningLineSuggestion);

                if PlanningLineSuggestion.FindSet() then begin
                    i := 0;
                    LinesModified := PlanningLineSuggestion.Count();

                    repeat
                        i += 1;
                        Window.Update(1, Round(i / LinesModified * 10000, 1));

                        // Find the original record
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                        PlanningLine.SetRange("Line No.", PlanningLineSuggestion."Line No.");

                        if PlanningLine.FindFirst() then begin
                            // Apply the change
                            PlanningLine."Assigned Day" := PlanningLineSuggestion."Assigned Day";
                            PlanningLine.Modify();
                        end;
                    until PlanningLineSuggestion.Next() = 0;

                    Window.Close();
                    Message('%1 lignes de planification ont été optimisées.', i);
                end else
                    Message('Aucune suggestion n''a été sélectionnée.');
            end else begin
                Message('Aucune modification n''a été appliquée.');
            end;
        end else
            Message('Toutes les lignes de planification ont déjà des jours optimaux.');
    end;

    // Helper function to check if a date is a working day
    local procedure IsWorkingDay(CheckDate: Date; NonWorkingDays: Text): Boolean
    begin
        // If the date is in the non-working days text, it's not a working day
        exit(not IsNonWorkingDay(CheckDate, NonWorkingDays));
    end;

    procedure GroupByProximity(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        PlanningLine2: Record "Planning Lines";
        MainLineNo: Integer;
    begin
        // Logique simplifiée pour le regroupement par proximité
        // Dans un environnement réel, utiliserait des coordonnées géographiques

        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLine.SetRange("Assigned Day", TourHeader."Start Date", TourHeader."End Date");

        if PlanningLine.FindSet() then
            repeat
                // Utiliser le code de localisation comme approximation de proximité
                if PlanningLine."Group Type" = PlanningLine."Group Type"::None then begin
                    MainLineNo := PlanningLine."Line No.";
                    PlanningLine."Group Type" := PlanningLine."Group Type"::"By Proximity";
                    PlanningLine.Modify();

                    // Trouver d'autres lignes pour le même emplacement et la même journée
                    PlanningLine2.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                    PlanningLine2.SetRange("Location Code", PlanningLine."Location Code");
                    PlanningLine2.SetRange("Assigned Day", PlanningLine."Assigned Day");
                    PlanningLine2.SetFilter("Line No.", '<>%1', PlanningLine."Line No.");

                    if PlanningLine2.FindSet() then
                        repeat
                            if PlanningLine2."Group Type" = PlanningLine2."Group Type"::None then begin
                                PlanningLine2."Group Type" := PlanningLine2."Group Type"::"By Proximity";
                                PlanningLine2."Grouped With" := MainLineNo;
                                PlanningLine2.Modify();
                            end;
                        until PlanningLine2.Next() = 0;
                end;
            until PlanningLine.Next() = 0;
    end;

    procedure GroupByCustomer(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        PlanningLine2: Record "Planning Lines";
        MainLineNo: Integer;
    begin
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLine.SetRange("Assigned Day", TourHeader."Start Date", TourHeader."End Date");
        PlanningLine.SetFilter("Customer No.", '<>%1', '');

        if PlanningLine.FindSet() then
            repeat
                if PlanningLine."Group Type" = PlanningLine."Group Type"::None then begin
                    MainLineNo := PlanningLine."Line No.";
                    PlanningLine."Group Type" := PlanningLine."Group Type"::"By Customer";
                    PlanningLine.Modify();

                    // Trouver d'autres lignes pour le même client et la même journée
                    PlanningLine2.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                    PlanningLine2.SetRange("Customer No.", PlanningLine."Customer No.");
                    PlanningLine2.SetRange("Assigned Day", PlanningLine."Assigned Day");
                    PlanningLine2.SetFilter("Line No.", '<>%1', PlanningLine."Line No.");

                    if PlanningLine2.FindSet() then
                        repeat
                            if PlanningLine2."Group Type" = PlanningLine2."Group Type"::None then begin
                                PlanningLine2."Group Type" := PlanningLine2."Group Type"::"By Customer";
                                PlanningLine2."Grouped With" := MainLineNo;
                                PlanningLine2.Modify();
                            end;
                        until PlanningLine2.Next() = 0;
                end;
            until PlanningLine.Next() = 0;
    end;

    procedure GroupByActivityType(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        PlanningLine2: Record "Planning Lines";
        MainLineNo: Integer;
    begin
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLine.SetRange("Assigned Day", TourHeader."Start Date", TourHeader."End Date");

        if PlanningLine.FindSet() then
            repeat
                if PlanningLine."Group Type" = PlanningLine."Group Type"::None then begin
                    MainLineNo := PlanningLine."Line No.";
                    PlanningLine."Group Type" := PlanningLine."Group Type"::"By Type";
                    PlanningLine.Modify();

                    // Trouver d'autres lignes pour le même type d'activité et la même journée
                    PlanningLine2.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                    PlanningLine2.SetRange("Activity Type", PlanningLine."Activity Type");
                    PlanningLine2.SetRange("Assigned Day", PlanningLine."Assigned Day");
                    PlanningLine2.SetFilter("Line No.", '<>%1', PlanningLine."Line No.");

                    if PlanningLine2.FindSet() then
                        repeat
                            if PlanningLine2."Group Type" = PlanningLine2."Group Type"::None then begin
                                PlanningLine2."Group Type" := PlanningLine2."Group Type"::"By Type";
                                PlanningLine2."Grouped With" := MainLineNo;
                                PlanningLine2.Modify();
                            end;
                        until PlanningLine2.Next() = 0;
                end;
            until PlanningLine.Next() = 0;
    end;

    procedure BalanceWorkload(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        WorkloadByDay: array[100] of Integer;  // Tableau pour stocker la charge par jour
        DayIndex: array[100] of Date;  // Tableau pour stocker les dates
        DayCount: Integer;
        AvgWorkload: Integer;
        i: Integer;
        j: Integer;
        CurrentDate: Date;
        LowestWorkloadIdx: Integer;
        NonWorkingDays: Text;
        IsWorkingDay: Boolean;
    begin
        NonWorkingDays := TourHeader."Non-Working Days";

        // Initialiser le tableau de dates
        DayCount := 0;
        CurrentDate := TourHeader."Start Date";
        while (CurrentDate <= TourHeader."End Date") and (DayCount < 100) do begin
            IsWorkingDay := not IsNonWorkingDay(CurrentDate, NonWorkingDays);
            if IsWorkingDay then begin
                DayCount += 1;
                DayIndex[DayCount] := CurrentDate;
            end;
            CurrentDate := CalcDate('<+1D>', CurrentDate);
        end;

        if DayCount = 0 then
            exit;

        // Calculer la charge actuelle par jour
        for i := 1 to DayCount do begin
            PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
            PlanningLine.SetRange("Assigned Day", DayIndex[i]);
            WorkloadByDay[i] := PlanningLine.Count;
        end;

        // Calculer la charge moyenne
        AvgWorkload := Round(PlanningLine.Count / DayCount, 1, '=');

        // Équilibrer la charge
        for i := 1 to DayCount do begin
            if WorkloadByDay[i] > AvgWorkload + 1 then begin
                // Ce jour a trop de travail, déplacer des lignes
                PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
                PlanningLine.SetRange("Assigned Day", DayIndex[i]);
                PlanningLine.SetCurrentKey(Priority); // Déplacer d'abord les tâches de faible priorité

                while (WorkloadByDay[i] > AvgWorkload) and PlanningLine.FindFirst() do begin
                    // Trouver le jour avec la charge la plus faible
                    LowestWorkloadIdx := 1;
                    for j := 2 to DayCount do
                        if WorkloadByDay[j] < WorkloadByDay[LowestWorkloadIdx] then
                            LowestWorkloadIdx := j;

                    // Déplacer la ligne vers ce jour
                    PlanningLine."Assigned Day" := DayIndex[LowestWorkloadIdx];
                    PlanningLine.Modify();

                    // Mettre à jour les compteurs
                    WorkloadByDay[i] -= 1;
                    WorkloadByDay[LowestWorkloadIdx] += 1;
                end;
            end;
        end;
    end;

    procedure OptimizeRoutes(var TourHeader: Record "Planification Header")
    var
        PlanningLine: Record "Planning Lines";
        CurrentDate: Date;
        NonWorkingDays: Text;
        IsWorkingDay: Boolean;
    begin
        NonWorkingDays := TourHeader."Non-Working Days";

        // Pour chaque jour de l'intervalle
        CurrentDate := TourHeader."Start Date";
        while CurrentDate <= TourHeader."End Date" do begin
            IsWorkingDay := not IsNonWorkingDay(CurrentDate, NonWorkingDays);
            if IsWorkingDay then
                OptimizeDailyRoute(TourHeader, CurrentDate);

            CurrentDate := CalcDate('<+1D>', CurrentDate);
        end;
    end;

    local procedure OptimizeDailyRoute(var TourHeader: Record "Planification Header"; ScheduleDate: Date)
    var
        PlanningLine: Record "Planning Lines";
        StartLocation: Record Location;
        EndLocation: Record Location;
        LocationSequence: array[100] of Code[20];  // Tableau pour stocker la séquence des lieux
        LocationCount: Integer;
        i: Integer;
        j: Integer;
        BestDistance: Decimal;
        CurrentDistance: Decimal;
        TempCode: Code[20];
        TimeSlot: Time;
        TimeSlotEnd: Time;
        OneHour: Duration;
    begin
        // Simplification: tri basique pour optimiser le routage
        // Dans un système réel, utiliserait un algorithme plus sophistiqué

        // Obtenir tous les lieux à visiter ce jour
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLine.SetRange("Assigned Day", ScheduleDate);

        if not PlanningLine.FindSet() then
            exit;

        // Collecter les lieux uniques
        LocationCount := 0;
        repeat
            if not LocationExists(LocationSequence, LocationCount, PlanningLine."Location Code") then begin
                LocationCount += 1;
                LocationSequence[LocationCount] := PlanningLine."Location Code";
            end;
        until PlanningLine.Next() = 0;

        if LocationCount <= 1 then
            exit;  // Pas besoin d'optimisation

        // Algorithme de tri simple (échange)
        for i := 1 to LocationCount - 1 do
            for j := i + 1 to LocationCount do begin
                // Échanger et comparer
                TempCode := LocationSequence[i];
                LocationSequence[i] := LocationSequence[j];
                LocationSequence[j] := TempCode;

                // Calculer la distance approximative
                // CurrentDistance := CalculateRouteDistance(LocationSequence, LocationCount);

                // Si meilleure distance, garder la séquence
                // Sinon, annuler l'échange
                if CurrentDistance > BestDistance then
                    BestDistance := CurrentDistance
                else begin
                    TempCode := LocationSequence[i];
                    LocationSequence[i] := LocationSequence[j];
                    LocationSequence[j] := TempCode;
                end;
            end;

        // Mettre à jour l'ordre dans les lignes de planification
        TimeSlot := 080000T; // 8:00
        OneHour := 3600000; // 1 heure en millisecondes

        for i := 1 to LocationCount do begin
            PlanningLine.SetRange("Location Code", LocationSequence[i]);
            if PlanningLine.FindSet() then
                repeat
                    // Mettre à jour l'heure de début estimée en fonction de l'ordre
                    PlanningLine."Time Slot Start" := TimeSlot;
                    TimeSlotEnd := TimeSlot;
                    TimeSlotEnd := TimeSlotEnd + OneHour;
                    PlanningLine."Time Slot End" := TimeSlotEnd;
                    PlanningLine.Modify();
                until PlanningLine.Next() = 0;

            TimeSlot := TimeSlot + OneHour; // Ajouter 1 heure pour le prochain emplacement
        end;
    end;

    local procedure LocationExists(var LocationArray: array[100] of Code[20]; Count: Integer; LocationCode: Code[20]): Boolean
    var
        i: Integer;
    begin
        for i := 1 to Count do
            if LocationArray[i] = LocationCode then
                exit(true);

        exit(false);
    end;

    local procedure IsNonWorkingDay(CheckDate: Date; NonWorkingDaysText: Text): Boolean
    var
        DateText: Text;
        Pos: Integer;
        CommaPos: Integer;
        NonWorkingDate: Date;
    begin
        // Vérifier si la date est un jour non-ouvré (défini dans le champ "Non-Working Days")
        if NonWorkingDaysText = '' then
            exit(false);

        Pos := 1;
        while Pos <= StrLen(NonWorkingDaysText) do begin
            CommaPos := StrPos(CopyStr(NonWorkingDaysText, Pos), ',');
            if CommaPos = 0 then
                CommaPos := StrLen(NonWorkingDaysText) - Pos + 1;

            DateText := CopyStr(NonWorkingDaysText, Pos, CommaPos - 1);
            if Evaluate(NonWorkingDate, DateText) then
                if NonWorkingDate = CheckDate then
                    exit(true);

            Pos := Pos + CommaPos;
        end;

        exit(false);
    end;

    procedure VerifyDocumentValid(DocumentType: Option "Sales Order","Purchase Order","Transfer Order"; DocumentNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ErrorMessage: Text;
    begin
        case DocumentType of
            DocumentType::"Sales Order":
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", DocumentNo);

                    if not SalesHeader.FindFirst() then begin
                        ErrorMessage := StrSubstNo('Sales Order %1 not found', DocumentNo);
                        Error(ErrorMessage);
                    end;

                    if not (SalesHeader.Status in [SalesHeader.Status::Open, SalesHeader.Status::Released]) then begin
                        ErrorMessage := StrSubstNo('Sales Order %1 has invalid status %2',
                            DocumentNo, Format(SalesHeader.Status));
                        Error(ErrorMessage);
                    end;
                end;

            DocumentType::"Purchase Order":
                begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("No.", DocumentNo);

                    if not PurchHeader.FindFirst() then begin
                        ErrorMessage := StrSubstNo('Purchase Order %1 not found', DocumentNo);
                        Error(ErrorMessage);
                    end;

                    if not (PurchHeader.Status in [PurchHeader.Status::Open, PurchHeader.Status::Released]) then begin
                        ErrorMessage := StrSubstNo('Purchase Order %1 has invalid status %2',
                            DocumentNo, Format(PurchHeader.Status));
                        Error(ErrorMessage);
                    end;
                end;

            DocumentType::"Transfer Order":
                begin
                    if not TransferHeader.Get(DocumentNo) then begin
                        ErrorMessage := StrSubstNo('Transfer Order %1 not found', DocumentNo);
                        Error(ErrorMessage);
                    end;

                    if not (TransferHeader.Status in [TransferHeader.Status::Open, TransferHeader.Status::Released]) then begin
                        ErrorMessage := StrSubstNo('Transfer Order %1 has invalid status %2',
                            DocumentNo, Format(TransferHeader.Status));
                        Error(ErrorMessage);
                    end;
                end;

            else
                Error('Unsupported document type: %1', Format(DocumentType));
        end;

        exit(true);
    end;

    procedure AddDocumentLineToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Debug information
        Message('Adding document line to tour: %1, Document: %2-%3, Item: %4',
                TourHeader."Logistic Tour No.", Format(DocBuffer."Document Type"), DocBuffer."Document No.", DocBuffer."Item No.");

        // Validate that we have a valid tour number
        if TourHeader."Logistic Tour No." = '' then begin
            Error('Tour number is missing in the TourHeader record.');
            exit;
        end;

        // Ensure the DocBuffer has the correct tour number
        DocBuffer."Tour No." := TourHeader."Logistic Tour No.";

        // Proceed with line addition based on document type
        case DocBuffer."Document Type" of
            DocBuffer."Document Type"::"Sales Order":
                begin
                    AddSalesLineToTour(TourHeader, DocBuffer);
                    // Update the Sales Header with the tour number
                    UpdateSalesHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding the line
                    CheckVehicleCompatibility(TourHeader);
                end;
            DocBuffer."Document Type"::"Purchase Order":
                begin
                    AddPurchaseLineToTour(TourHeader, DocBuffer);
                    // Update the Purchase Header with the tour number
                    UpdatePurchaseHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding the line
                    CheckVehicleCompatibility(TourHeader);
                end;
            DocBuffer."Document Type"::"Transfer Order":
                begin
                    AddTransferLineToTour(TourHeader, DocBuffer);
                    // Update the Transfer Header with the tour number
                    UpdateTransferHeaderTourNo(DocBuffer."Document No.", TourHeader."Logistic Tour No.");
                    // Check compatibility after adding the line
                    CheckVehicleCompatibility(TourHeader);
                end;
            else
                Error('Unsupported document type: %1', Format(DocBuffer."Document Type"));
        end;
    end;

    local procedure AddSalesLineToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Vérifier que la commande client existe
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", DocBuffer."Document No.");
        if not SalesHeader.FindFirst() then begin
            Error('Sales Order %1 not found', DocBuffer."Document No.");
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Rechercher la ligne spécifique
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("No.", DocBuffer."Item No.");
        if not SalesLine.FindFirst() then begin
            Error('Sales Line for item %1 in order %2 not found', DocBuffer."Item No.", DocBuffer."Document No.");
            exit;
        end;

        // Créer la ligne de planification
        Clear(PlanningLine);
        PlanningLine.Init();
        PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
        PlanningLine."Line No." := NextLineNo;
        PlanningLine.Type := PlanningLine.Type::Sales;
        PlanningLine."Source ID" := SalesLine."Document No.";
        PlanningLine."Item No." := SalesLine."No.";
        PlanningLine.Description := SalesLine.Description;
        PlanningLine."Description 2" := SalesLine."Description 2";
        PlanningLine.Quantity := SalesLine.Quantity;
        PlanningLine."Quantity (Base)" := SalesLine."Quantity (Base)";
        PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
        PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
        PlanningLine."Expected Shipment Date" := SalesLine."Shipment Date";
        PlanningLine."Customer No." := SalesLine."Sell-to Customer No.";
        PlanningLine."Account No." := SalesLine."Sell-to Customer no.";
        PlanningLine."Location Code" := SalesLine."Location Code";
        PlanningLine." Delivery Date" := SalesLine."Shipment Date";
        PlanningLine."Ship-to Address" := SalesHeader."Ship-to Address";
        PlanningLine."Net Weight" := SalesLine."Net Weight";
        PlanningLine."Gross Weight" := SalesLine."Gross Weight";
        PlanningLine."Unit Volume" := SalesLine."Unit Volume";

        // Valeurs par défaut pour les nouveaux champs
        if (SalesLine."Shipment Date" >= TourHeader."Start Date") and
           (SalesLine."Shipment Date" <= TourHeader."End Date") then
            PlanningLine."Assigned Day" := SalesLine."Shipment Date"
        else if (SalesHeader."Requested Delivery Date" >= TourHeader."Start Date") and
                (SalesHeader."Requested Delivery Date" <= TourHeader."End Date") then
            PlanningLine."Assigned Day" := SalesHeader."Requested Delivery Date"
        else
            PlanningLine."Assigned Day" := TourHeader."Start Date";

        // Extraire ou définir la priorité
        case DocBuffer.Priority of
            DocBuffer.Priority::Low:
                PlanningLine.Priority := PlanningLine.Priority::Low;
            DocBuffer.Priority::Normal:
                PlanningLine.Priority := PlanningLine.Priority::Normal;
            DocBuffer.Priority::High:
                PlanningLine.Priority := PlanningLine.Priority::High;
            DocBuffer.Priority::Critical:
                PlanningLine.Priority := PlanningLine.Priority::Critical;
        end;

        // Définir le type d'activité à Livraison pour une commande client
        PlanningLine."Activity Type" := PlanningLine."Activity Type"::Delivery;

        if PlanningLine.Insert() then begin
            LinesAdded += 1;
            Message('Successfully added line for item %1 from Sales Order %2 to tour %3',
                    PlanningLine."Item No.", SalesHeader."No.", TourHeader."Logistic Tour No.");
        end else begin
            Error('Failed to insert planning line for Sales Order %1, Item %2: %3',
                SalesLine."Document No.", SalesLine."No.", GetLastErrorText);
        end;

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    local procedure AddPurchaseLineToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Vérifier que la commande fournisseur existe
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("No.", DocBuffer."Document No.");
        if not PurchHeader.FindFirst() then begin
            Error('Purchase Order %1 not found', DocBuffer."Document No.");
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Rechercher la ligne spécifique
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange("No.", DocBuffer."Item No.");
        if not PurchLine.FindFirst() then begin
            Error('Purchase Line for item %1 in order %2 not found', DocBuffer."Item No.", DocBuffer."Document No.");
            exit;
        end;

        // Créer la ligne de planification
        Clear(PlanningLine);
        PlanningLine.Init();
        PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
        PlanningLine."Line No." := NextLineNo;
        PlanningLine.Type := PlanningLine.Type::Purchase;
        PlanningLine."Source ID" := PurchLine."Document No.";
        PlanningLine."Item No." := PurchLine."No.";
        PlanningLine.Description := PurchLine.Description;
        PlanningLine."Description 2" := PurchLine."Description 2";
        PlanningLine.Quantity := PurchLine.Quantity;
        PlanningLine."Quantity (Base)" := PurchLine."Quantity (Base)";
        PlanningLine."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
        PlanningLine."Unit of Measure Code" := PurchLine."Unit of Measure Code";
        PlanningLine."Expected Receipt Date" := PurchLine."Expected Receipt Date";
        PlanningLine."Vendor No." := PurchLine."Buy-from Vendor No.";
        // PlanningLine."Account No." := PurchHeader."Buy-from Vendor Name";
        PlanningLine."Account No." := PurchLine."Buy-from Vendor no.";

        PlanningLine."Location Code" := PurchLine."Location Code";
        PlanningLine." Delivery Date" := PurchLine."Expected Receipt Date";
        PlanningLine."Net Weight" := PurchLine."Net Weight";
        PlanningLine."Gross Weight" := PurchLine."Gross Weight";
        PlanningLine."Unit Volume" := PurchLine."Unit Volume";
        PlanningLine."Ship-to Address" := PurchHeader."Ship-to Address";
        // Valeurs par défaut pour les nouveaux champs
        if (PurchLine."Expected Receipt Date" >= TourHeader."Start Date") and
           (PurchLine."Expected Receipt Date" <= TourHeader."End Date") then
            PlanningLine."Assigned Day" := PurchLine."Expected Receipt Date"
        else
            PlanningLine."Assigned Day" := TourHeader."Start Date";

        // Extraire ou définir la priorité
        case DocBuffer.Priority of
            DocBuffer.Priority::Low:
                PlanningLine.Priority := PlanningLine.Priority::Low;
            DocBuffer.Priority::Normal:
                PlanningLine.Priority := PlanningLine.Priority::Normal;
            DocBuffer.Priority::High:
                PlanningLine.Priority := PlanningLine.Priority::High;
            DocBuffer.Priority::Critical:
                PlanningLine.Priority := PlanningLine.Priority::Critical;
        end;

        // Définir le type d'activité à Ramassage pour une commande fournisseur
        PlanningLine."Activity Type" := PlanningLine."Activity Type"::Pickup;

        if PlanningLine.Insert() then begin
            LinesAdded += 1;
            Message('Successfully added line for item %1 from Purchase Order %2 to tour %3',
                    PlanningLine."Item No.", PurchHeader."No.", TourHeader."Logistic Tour No.");
        end else
            Error('Failed to insert planning line for Purchase Order %1, Item %2: %3',
                PurchLine."Document No.", PurchLine."No.", GetLastErrorText);

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    local procedure AddTransferLineToTour(var TourHeader: Record "Planification Header"; var DocBuffer: Record "Planning Document Buffer")
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        PlanningLine: Record "Planning Lines";
        NextLineNo: Integer;
        LinesAdded: Integer;
        PlanningDiag: Codeunit "Planning Diagnostics";
    begin
        // Vérifier que l'ordre de transfert existe
        TransferHeader.SetRange("No.", DocBuffer."Document No.");
        if not TransferHeader.FindFirst() then begin
            Error('Transfer Order %1 not found', DocBuffer."Document No.");
            exit;
        end;

        // Chercher le prochain numéro de ligne
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        if PlanningLine.FindLast() then
            NextLineNo := PlanningLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Rechercher la ligne spécifique
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Item No.", DocBuffer."Item No.");
        if not TransferLine.FindFirst() then begin
            Error('Transfer Line for item %1 in order %2 not found', DocBuffer."Item No.", DocBuffer."Document No.");
            exit;
        end;

        // Créer la ligne de planification
        Clear(PlanningLine);
        PlanningLine.Init();
        PlanningLine."Logistic Tour No." := TourHeader."Logistic Tour No.";
        PlanningLine."Line No." := NextLineNo;
        PlanningLine.Type := PlanningLine.Type::Transfer;
        PlanningLine."Source ID" := TransferLine."Document No.";
        PlanningLine."Item No." := TransferLine."Item No.";
        PlanningLine.Description := TransferLine.Description;
        PlanningLine.Quantity := TransferLine.Quantity;
        PlanningLine."Quantity (Base)" := TransferLine."Quantity (Base)";
        PlanningLine."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
        PlanningLine."Unit of Measure Code" := TransferLine."Unit of Measure Code";
        PlanningLine."Expected Shipment Date" := TransferLine."Shipment Date";
        PlanningLine."Expected Receipt Date" := TransferLine."Receipt Date";
        PlanningLine."Location Code" := TransferLine."Transfer-from Code";
        PlanningLine." Delivery Date" := TransferLine."Receipt Date";
        PlanningLine."Account No." := TransferHeader."Transfer-to Code";
        PlanningLine."Net Weight" := TransferLine."Net Weight";
        PlanningLine."Gross Weight" := TransferLine."Gross Weight";
        PlanningLine."Unit Volume" := TransferLine."Unit Volume";

        // Valeurs par défaut pour les nouveaux champs
        if (TransferHeader."Shipment Date" >= TourHeader."Start Date") and
           (TransferHeader."Shipment Date" <= TourHeader."End Date") then
            PlanningLine."Assigned Day" := TransferHeader."Shipment Date"
        else
            PlanningLine."Assigned Day" := TourHeader."Start Date";

        // Extraire ou définir la priorité
        case DocBuffer.Priority of
            DocBuffer.Priority::Low:
                PlanningLine.Priority := PlanningLine.Priority::Low;
            DocBuffer.Priority::Normal:
                PlanningLine.Priority := PlanningLine.Priority::Normal;
            DocBuffer.Priority::High:
                PlanningLine.Priority := PlanningLine.Priority::High;
            DocBuffer.Priority::Critical:
                PlanningLine.Priority := PlanningLine.Priority::Critical;
        end;

        // Définir le type d'activité pour un ordre de transfert
        PlanningLine."Activity Type" := PlanningLine."Activity Type"::Delivery;

        if PlanningLine.Insert() then begin
            LinesAdded += 1;
            Message('Successfully added line for item %1 from Transfer Order %2 to tour %3',
                    PlanningLine."Item No.", TransferHeader."No.", TourHeader."Logistic Tour No.");
        end else
            Error('Failed to insert planning line for Transfer Order %1, Item %2: %3',
                TransferLine."Document No.", TransferLine."Item No.", GetLastErrorText);

        // Mettre à jour le nombre total de lignes de planification
        TourHeader.CalcFields("No. of Planning Lines", "Total Quantity");
    end;

    local procedure UpdateSalesHeaderTourNo(DocumentNo: Code[20]; TourNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        // Rechercher l'en-tête de vente
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", DocumentNo);
        if SalesHeader.FindFirst() then begin
            // Mettre à jour le numéro de tournée
            SalesHeader."Logistic Tour No." := TourNo;
            SalesHeader.Modify(true);
            Message('Le numéro de tournée %1 a été mis à jour dans la commande client %2', TourNo, DocumentNo);
        end else
            Error('Commande client %1 introuvable', DocumentNo);
    end;

    local procedure UpdatePurchaseHeaderTourNo(DocumentNo: Code[20]; TourNo: Code[20])
    var
        PurchHeader: Record "Purchase Header";
    begin
        // Rechercher l'en-tête d'achat
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("No.", DocumentNo);
        if PurchHeader.FindFirst() then begin
            // Mettre à jour le numéro de tournée
            PurchHeader."Logistic Tour No." := TourNo;
            PurchHeader.Modify(true);
            Message('Le numéro de tournée %1 a été mis à jour dans la commande fournisseur %2', TourNo, DocumentNo);
        end else
            Error('Commande fournisseur %1 introuvable', DocumentNo);
    end;

    local procedure UpdateTransferHeaderTourNo(DocumentNo: Code[20]; TourNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
    begin
        // Rechercher l'en-tête de transfert
        TransferHeader.SetRange("No.", DocumentNo);
        if TransferHeader.FindFirst() then begin
            // Mettre à jour le numéro de tournée
            TransferHeader."Logistic Tour No." := TourNo;
            TransferHeader.Modify(true);
            Message('Le numéro de tournée %1 a été mis à jour dans l\ordre de transfert %2', TourNo, DocumentNo);
        end else
            Error('Ordre de transfert %1 introuvable', DocumentNo);
    end;

    procedure CheckVehicleCompatibility(var TourHeader: Record "Planification Header")
    var
        CompatCheck: Codeunit "Vehicle Item Compat. Check";
    begin
        CompatCheck.CheckVehicleItemCompatibilityForTour(TourHeader);
    end;
}