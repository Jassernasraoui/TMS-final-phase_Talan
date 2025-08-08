codeunit 73561 "Tour Posting Management"
{
    procedure PostTourDocuments(TourNo: Code[20])
    var
        TourHeader: Record "Planification Header";
        ExecutionTracking: Record "Tour Execution Tracking";
        PlanningLine: Record "Planning Lines";
        DocumentsPosted: Integer;
        DocumentsFailed: Integer;
        Window: Dialog;
        ProgressMsg: Label 'Posting documents for tour #1##########\Document type: #2################\Document: #3##############\@4@@@@@@@@@@@@@';
        ProgressCounter: Integer;
        TotalLines: Integer;
        ErrorText: Text;
        ErrorOccurred: Boolean;
    begin
        // Validate tour number
        if not TourHeader.Get(TourNo) then
            Error('Tour %1 not found.', TourNo);

        if TourHeader.Statut <> TourHeader.Statut::Stopped then
            Error('Tour %1 must be in Stopped status to post documents. Current status: %2',
                  TourNo, Format(TourHeader.Statut));

        // Count total lines for progress bar
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourNo);
        TotalLines := PlanningLine.Count();

        if TotalLines = 0 then begin
            Message('No planning lines found for tour %1.', TourNo);
            exit;
        end;

        // Initialize progress window
        Window.Open(ProgressMsg);
        Window.Update(1, TourNo);
        ProgressCounter := 0;

        // Log start of posting process
        LogActivity(TourNo, 'Posting Started', StrSubstNo('Starting to post documents for tour %1', TourNo));

        // Clear any previous errors
        ClearLastError();
        ErrorOccurred := false;

        // Process documents one by one to avoid transaction issues
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourNo);

        if PlanningLine.FindSet() then begin
            repeat
                ProgressCounter += 1;
                Window.Update(4, Round(ProgressCounter / TotalLines * 10000, 1));

                // Check execution tracking for this planning line to determine if it was delivered
                ExecutionTracking.Reset();
                ExecutionTracking.SetRange("Tour No.", TourNo);
                ExecutionTracking.SetRange("Planning Line No.", PlanningLine."Line No.");
                ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");

                if not ExecutionTracking.IsEmpty() then begin
                    // Only process delivered items
                    case PlanningLine.Type of
                        PlanningLine.Type::Sales:
                            begin
                                Window.Update(2, 'Sales Document');
                                Window.Update(3, PlanningLine."Source ID");

                                // Check if this document has already been processed
                                if not IsDocumentAlreadyProcessed(TourNo, PlanningLine."Source ID", 'Sales') then begin
                                    // Process with error handling
                                    ClearLastError();

                                    if PostSalesDocumentSafe(TourNo, PlanningLine."Source ID") then begin
                                        DocumentsPosted += 1;
                                        // Mark as processed to avoid duplicate posting
                                        MarkDocumentAsProcessed(TourNo, PlanningLine."Source ID", 'Sales');
                                    end else begin
                                        DocumentsFailed += 1;
                                        ErrorOccurred := true;
                                    end;
                                end;
                            end;
                        PlanningLine.Type::Purchase:
                            begin
                                Window.Update(2, 'Purchase Document');
                                Window.Update(3, PlanningLine."Source ID");

                                // Check if this document has already been processed
                                if not IsDocumentAlreadyProcessed(TourNo, PlanningLine."Source ID", 'Purchase') then begin
                                    // Process with error handling
                                    ClearLastError();

                                    if PostPurchaseDocumentSafe(TourNo, PlanningLine."Source ID") then begin
                                        DocumentsPosted += 1;
                                        // Mark as processed to avoid duplicate posting
                                        MarkDocumentAsProcessed(TourNo, PlanningLine."Source ID", 'Purchase');
                                    end else begin
                                        DocumentsFailed += 1;
                                        ErrorOccurred := true;
                                    end;
                                end;
                            end;
                        PlanningLine.Type::Transfer:
                            begin
                                Window.Update(2, 'Transfer Document');
                                Window.Update(3, PlanningLine."Source ID");

                                // Check if this document has already been processed
                                if not IsDocumentAlreadyProcessed(TourNo, PlanningLine."Source ID", 'Transfer') then begin
                                    // Process with error handling
                                    ClearLastError();

                                    if PostTransferDocumentSafe(TourNo, PlanningLine."Source ID") then begin
                                        DocumentsPosted += 1;
                                        // Mark as processed to avoid duplicate posting
                                        MarkDocumentAsProcessed(TourNo, PlanningLine."Source ID", 'Transfer');
                                    end else begin
                                        DocumentsFailed += 1;
                                        ErrorOccurred := true;
                                    end;
                                end;
                            end;
                    end;
                end;
            until PlanningLine.Next() = 0;
        end;

        Window.Close();

        // Update tour status to indicate documents have been posted
        if DocumentsPosted > 0 then begin
            TourHeader.Statut := TourHeader.Statut::Completed;
            TourHeader."Documents Posted" := true;
            TourHeader."Posting Date" := WorkDate();
            TourHeader.Modify(true);

            LogActivity(TourNo, 'Posting Completed',
                StrSubstNo('Successfully posted %1 documents for tour %2. %3 documents failed.',
                DocumentsPosted, TourNo, DocumentsFailed));
        end else begin
            LogActivity(TourNo, 'Posting Failed',
                StrSubstNo('Failed to post any documents for tour %1. %2 documents attempted.',
                TourNo, DocumentsFailed));
        end;

        // Show summary message
        if DocumentsPosted > 0 then
            Message('%1 document(s) posted successfully. %2 document(s) failed.',
                    DocumentsPosted, DocumentsFailed)
        else
            Message('No documents were posted. %1 document(s) failed.', DocumentsFailed);

        // If errors occurred, show a message with instructions
        if ErrorOccurred then
            Message('Some errors occurred during posting. Check the activity log for details.');
    end;

    local procedure PostSalesDocumentSafe(TourNo: Code[20]; DocumentNo: Code[20]): Boolean
    var
        ErrorText: Text;
    begin
        // Try to post with error handling
        ClearLastError();

        if not PostSalesDocument(DocumentNo) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during posting';

            LogActivity(TourNo, 'Posting Error', StrSubstNo('Failed to post sales order %1: %2', DocumentNo, ErrorText));
            exit(false);
        end;

        exit(true);
    end;

    local procedure PostPurchaseDocumentSafe(TourNo: Code[20]; DocumentNo: Code[20]): Boolean
    var
        ErrorText: Text;
    begin
        // Try to post with error handling
        ClearLastError();

        if not PostPurchaseDocument(DocumentNo) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during posting';

            LogActivity(TourNo, 'Posting Error', StrSubstNo('Failed to post purchase order %1: %2', DocumentNo, ErrorText));
            exit(false);
        end;

        exit(true);
    end;

    local procedure PostTransferDocumentSafe(TourNo: Code[20]; DocumentNo: Code[20]): Boolean
    var
        ErrorText: Text;
    begin
        // Try to post with error handling
        ClearLastError();

        if not PostTransferDocument(DocumentNo) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during posting';

            LogActivity(TourNo, 'Posting Error', StrSubstNo('Failed to post transfer order %1: %2', DocumentNo, ErrorText));
            exit(false);
        end;

        exit(true);
    end;

    local procedure IsDocumentAlreadyProcessed(TourNo: Code[20]; DocumentNo: Code[20]; DocType: Text[20]): Boolean
    var
        TourActivityLog: Record "Tour Activity Log";
    begin
        TourActivityLog.Reset();
        TourActivityLog.SetRange("Tour No.", TourNo);
        TourActivityLog.SetRange("Activity Type", 'Document Processed');
        TourActivityLog.SetFilter(Description, '%1|%2',
            StrSubstNo('Processed %1 document %2', DocType, DocumentNo),
            StrSubstNo('Successfully posted %1 order %2', DocType, DocumentNo));

        exit(not TourActivityLog.IsEmpty());
    end;

    local procedure MarkDocumentAsProcessed(TourNo: Code[20]; DocumentNo: Code[20]; DocType: Text[20])
    begin
        LogActivity(TourNo, 'Document Processed', StrSubstNo('Processed %1 document %2', DocType, DocumentNo));
    end;

    procedure CreateDeliveryDocuments(TourNo: Code[20])
    var
        TourHeader: Record "Planification Header";
        ExecutionTracking: Record "Tour Execution Tracking";
        PlanningLine: Record "Planning Lines";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeliveryHeader: Record "Sales Header";
        DeliveryLine: Record "Sales Line";
        Window: Dialog;
        ProgressMsg: Label 'Creating delivery documents for tour #1##########\Processing: #2################\@3@@@@@@@@@@@@@';
        ProgressCounter: Integer;
        TotalLines: Integer;
        DeliveryNo: Code[20];
        LineNo: Integer;
        DeliveriesCreated: Integer;
    begin
        // Validate tour number
        if not TourHeader.Get(TourNo) then
            Error('Tour %1 not found.', TourNo);

        if TourHeader.Statut <> TourHeader.Statut::Stopped then
            Error('Tour %1 must be in Stopped status to create delivery documents. Current status: %2',
                  TourNo, Format(TourHeader.Statut));

        // Count total lines for progress bar
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");
        TotalLines := ExecutionTracking.Count();

        if TotalLines = 0 then begin
            Message('No delivered items found for tour %1.', TourNo);
            exit;
        end;

        // Initialize progress window
        Window.Open(ProgressMsg);
        Window.Update(1, TourNo);
        ProgressCounter := 0;
        DeliveriesCreated := 0;

        // Process all execution tracking records with "Livré" status
        ExecutionTracking.Reset();
        ExecutionTracking.SetRange("Tour No.", TourNo);
        ExecutionTracking.SetRange(Status, ExecutionTracking.Status::"Livré");

        if ExecutionTracking.FindSet() then begin
            repeat
                ProgressCounter += 1;
                Window.Update(2, StrSubstNo('Customer: %1, Item: %2', ExecutionTracking."Customer No.", ExecutionTracking."Item No."));
                Window.Update(3, Round(ProgressCounter / TotalLines * 10000, 1));

                // Find corresponding planning line
                PlanningLine.Reset();
                PlanningLine.SetRange("Logistic Tour No.", TourNo);
                PlanningLine.SetRange("Line No.", ExecutionTracking."Planning Line No.");

                if PlanningLine.FindFirst() then begin
                    if PlanningLine.Type = PlanningLine.Type::Sales then begin
                        // Create delivery document (bon de livraison) for sales orders
                        if CreateDeliveryNote(ExecutionTracking) then
                            DeliveriesCreated += 1;
                    end;
                end;
            until ExecutionTracking.Next() = 0;
        end;

        Window.Close();

        // Show summary message
        if DeliveriesCreated > 0 then
            Message('%1 delivery document(s) created successfully.', DeliveriesCreated)
        else
            Message('No delivery documents were created.');
    end;

    local procedure CreateDeliveryNote(var ExecutionTracking: Record "Tour Execution Tracking"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeliveryHeader: Record "Sales Header";
        DeliveryLine: Record "Sales Line";
        PlanningLine: Record "Planning Lines";
        Customer: Record Customer;
        LineNo: Integer;
        DeliveryNo: Code[20];
    begin
        // Find the original sales order
        // Find source document from planning line
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", ExecutionTracking."Tour No.");
        PlanningLine.SetRange("Line No.", ExecutionTracking."Planning Line No.");

        if not PlanningLine.FindFirst() or (PlanningLine.Type <> PlanningLine.Type::Sales) then
            exit(false);

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", PlanningLine."Source ID");

        if not SalesHeader.FindFirst() then
            exit(false);

        // Create delivery note header (Sales Invoice)
        DeliveryHeader.Init();
        DeliveryHeader."Document Type" := DeliveryHeader."Document Type"::Invoice;
        DeliveryHeader."No." := '';
        DeliveryHeader.Insert(true);
        DeliveryNo := DeliveryHeader."No.";

        // Copy header information from sales order
        DeliveryHeader.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        DeliveryHeader.Validate("Posting Date", WorkDate());
        DeliveryHeader.Validate("Document Date", WorkDate());
        DeliveryHeader.Validate("Due Date", WorkDate());
        DeliveryHeader.Validate("Shipment Date", WorkDate());
        DeliveryHeader.Validate("External Document No.", ExecutionTracking."Tour No.");
        DeliveryHeader.Validate("Logistic Tour No.", ExecutionTracking."Tour No.");
        DeliveryHeader.Validate("Your Reference", SalesHeader."Your Reference");
        DeliveryHeader.Modify(true);

        // Create delivery note line
        LineNo := 10000;
        DeliveryLine.Init();
        DeliveryLine."Document Type" := DeliveryHeader."Document Type";
        DeliveryLine."Document No." := DeliveryNo;
        DeliveryLine."Line No." := LineNo;
        DeliveryLine.Type := DeliveryLine.Type::Item;
        DeliveryLine.Validate("No.", ExecutionTracking."Item No.");
        DeliveryLine.Validate(Quantity, ExecutionTracking."Quantity Delivered");
        DeliveryLine.Validate("Unit of Measure Code", ExecutionTracking."Unit of Measure Code");
        DeliveryLine.Validate("Shipment Date", WorkDate());
        DeliveryLine.Insert(true);

        // Log the creation of delivery note
        LogActivity(
            ExecutionTracking."Tour No.",
            'Bon de livraison créé',
            StrSubstNo('Bon de livraison %1 créé pour client %2, article %3, quantité %4',
                DeliveryNo, ExecutionTracking."Customer No.", ExecutionTracking."Item No.",
                Format(ExecutionTracking."Quantity Delivered")));

        exit(true);
    end;

    local procedure PostSalesDocument(DocumentNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        ErrorText: Text;
    begin
        // Find the sales order
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", DocumentNo);

        if not SalesHeader.FindFirst() then begin
            LogActivity('', 'Posting Error', StrSubstNo('Sales order %1 not found', DocumentNo));
            exit(false);
        end;

        // Check if document is already posted
        if SalesHeader.Ship or SalesHeader.Invoice then begin
            LogActivity('', 'Posting Warning', StrSubstNo('Sales order %1 already partially posted (Ship: %2, Invoice: %3)',
                DocumentNo, Format(SalesHeader.Ship), Format(SalesHeader.Invoice)));
        end;

        // Post the sales order (ship and invoice)
        SalesHeader.Validate("Posting Date", WorkDate());

        // Set posting options - Ship and Invoice
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;

        // Ensure we're using a clean transaction
        Commit();

        // Modify with a clean transaction
        SalesHeader.Modify(true);
        Commit();

        // Clear any previous errors
        ClearLastError();

        // Try to post with error handling
        if not SalesPost.Run(SalesHeader) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during posting';

            LogActivity('', 'Posting Error', StrSubstNo('Failed to post sales order %1: %2', DocumentNo, ErrorText));
            Message('Error posting sales order %1: %2', DocumentNo, ErrorText);
            exit(false);
        end;

        LogActivity('', 'Posting Success', StrSubstNo('Successfully posted sales order %1', DocumentNo));
        Commit();
        exit(true);
    end;

    local procedure PostPurchaseDocument(DocumentNo: Code[20]): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        ErrorText: Text;
    begin
        // Find the purchase order
        PurchHeader.Reset();
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("No.", DocumentNo);

        if not PurchHeader.FindFirst() then begin
            LogActivity('', 'Posting Error', StrSubstNo('Purchase order %1 not found', DocumentNo));
            exit(false);
        end;

        // Check if document is already posted
        if PurchHeader.Receive or PurchHeader.Invoice then begin
            LogActivity('', 'Posting Warning', StrSubstNo('Purchase order %1 already partially posted (Receive: %2, Invoice: %3)',
                DocumentNo, Format(PurchHeader.Receive), Format(PurchHeader.Invoice)));
        end;

        // Post the purchase order (receive and invoice)
        PurchHeader.Validate("Posting Date", WorkDate());

        // Set posting options - Receive and Invoice
        PurchHeader.Receive := true;
        PurchHeader.Invoice := true;

        // Ensure we're using a clean transaction
        Commit();

        // Modify with a clean transaction
        PurchHeader.Modify(true);
        Commit();

        // Clear any previous errors
        ClearLastError();

        // Try to post with error handling
        if not PurchPost.Run(PurchHeader) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during posting';

            LogActivity('', 'Posting Error', StrSubstNo('Failed to post purchase order %1: %2', DocumentNo, ErrorText));
            Message('Error posting purchase order %1: %2', DocumentNo, ErrorText);
            exit(false);
        end;

        LogActivity('', 'Posting Success', StrSubstNo('Successfully posted purchase order %1', DocumentNo));
        Commit();
        exit(true);
    end;

    local procedure PostTransferDocument(DocumentNo: Code[20]): Boolean
    var
        TransferHeader: Record "Transfer Header";
        TransferPost: Codeunit "TransferOrder-Post Shipment";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        ErrorText: Text;
    begin
        // Find the transfer order
        TransferHeader.Reset();
        TransferHeader.SetRange("No.", DocumentNo);

        if not TransferHeader.FindFirst() then begin
            LogActivity('', 'Posting Error', StrSubstNo('Transfer order %1 not found', DocumentNo));
            exit(false);
        end;

        // Check if already shipped
        if TransferHeader."Shipment Date" <> 0D then begin
            LogActivity('', 'Posting Warning', StrSubstNo('Transfer order %1 may already be shipped (Shipment Date: %2)',
                DocumentNo, Format(TransferHeader."Shipment Date")));
        end;

        // Post the transfer order (ship and receive)
        TransferHeader.Validate("Posting Date", WorkDate());

        // Ensure we're using a clean transaction
        Commit();

        TransferHeader.Modify(true);
        Commit();

        // Clear any previous errors
        ClearLastError();

        // First ship, then receive
        if not TransferPost.Run(TransferHeader) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during shipment posting';

            LogActivity('', 'Posting Error', StrSubstNo('Failed to ship transfer order %1: %2', DocumentNo, ErrorText));
            Message('Error shipping transfer order %1: %2', DocumentNo, ErrorText);
            exit(false);
        end;

        // Log successful shipment
        LogActivity('', 'Posting Success', StrSubstNo('Successfully shipped transfer order %1', DocumentNo));
        Commit();

        // Clear any previous errors before receipt
        ClearLastError();

        // Refresh the record after shipping
        if not TransferHeader.Get(DocumentNo) then begin
            LogActivity('', 'Posting Error', StrSubstNo('Transfer order %1 not found after shipment', DocumentNo));
            exit(false);
        end;

        // Now post receipt - in a new transaction
        Commit();
        if not TransferPostReceipt.Run(TransferHeader) then begin
            ErrorText := GetLastErrorText();
            if ErrorText = '' then
                ErrorText := 'Unknown error during receipt posting';

            LogActivity('', 'Posting Error', StrSubstNo('Failed to receive transfer order %1: %2', DocumentNo, ErrorText));
            Message('Error receiving transfer order %1: %2', DocumentNo, ErrorText);
            exit(false);
        end;

        LogActivity('', 'Posting Success', StrSubstNo('Successfully received transfer order %1', DocumentNo));
        Commit();
        exit(true);
    end;

    local procedure LogActivity(TourNo: Code[20]; ActivityType: Text[100]; Description: Text[250])
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
}