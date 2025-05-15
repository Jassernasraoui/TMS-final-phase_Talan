codeunit 77201 "Planning Diagnostics"
{
    // This codeunit is used for diagnostics and debugging of the tour planning system

    procedure TestDocumentAddition(var TourHeader: Record "Planification Header")
    var
        SalesHeader: Record "Sales Header";
        DocBuffer: Record "Planning Document Buffer" temporary;
        PlanningLineMgt: Codeunit "Planning Lines Management";
        PlanningLine: Record "Planning Lines";
        Count1: Integer;
        Count2: Integer;
    begin
        // Count existing planning lines
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        Count1 := PlanningLine.Count;

        // Find a sales order to add
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if not SalesHeader.FindFirst() then begin
            Message('No sales orders found for testing');
            exit;
        end;

        // Create test buffer record
        DocBuffer.Init();
        DocBuffer."Line No." := 1;
        DocBuffer."Document Type" := DocBuffer."Document Type"::"Sales Order";
        DocBuffer."Document No." := SalesHeader."No.";
        DocBuffer."Account Type" := DocBuffer."Account Type"::Customer;
        DocBuffer."Account No." := SalesHeader."Sell-to Customer No.";
        DocBuffer."Account Name" := SalesHeader."Sell-to Customer Name";
        DocBuffer."Location Code" := SalesHeader."Location Code";
        DocBuffer."Document Date" := SalesHeader."Document Date";
        DocBuffer."Delivery Date" := SalesHeader."Shipment Date";
        DocBuffer.Priority := DocBuffer.Priority::Normal;
        DocBuffer.Selected := true;

        // Explicitly set the Tour No. in the buffer
        DocBuffer."Tour No." := TourHeader."Logistic Tour No.";

        DocBuffer.Insert();

        // Try to add document
        Message('Attempting to add sales order %1 to tour %2...',
            SalesHeader."No.", TourHeader."Logistic Tour No.");

        // Call the codeunit
        PlanningLineMgt.AddDocumentToTour(TourHeader, DocBuffer);

        // Count planning lines again
        PlanningLine.Reset();
        PlanningLine.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        Count2 := PlanningLine.Count;

        // Report results
        if Count2 > Count1 then
            Message('Success! %1 planning lines added.', Count2 - Count1)
        else
            Message('Failed! No new planning lines were added.');
    end;

    procedure LogPlanningLineIssues(TourNo: Code[20]; ItemNo: Code[20]; Source: Text[100])
    var
        LogEntry: Record "Planning Log Entry" temporary;
        LogEntryNo: Integer;
    begin
        LogEntry.Init();
        LogEntryNo := 1;
        LogEntry."Entry No." := LogEntryNo;
        LogEntry."Timestamps" := CurrentDateTime;
        LogEntry."Tour No." := TourNo;
        LogEntry."Item No." := ItemNo;
        LogEntry."Source" := Source;
        LogEntry."User ID" := UserId;
        LogEntry.Insert();

        // In a real implementation, this would insert into a persistent table
        // For now, just display the message
        Message('Log: %1 - Tour: %2 - Item: %3 - Source: %4',
            Format(LogEntry.Timestamps), LogEntry."Tour No.",
            LogEntry."Item No.", LogEntry."Source");
    end;

    procedure ValidateSourceDocument(DocumentType: Option "Sales Order","Purchase Order","Transfer Order"; DocumentNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
    begin
        case DocumentType of
            DocumentType::"Sales Order":
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", DocumentNo);
                    exit(SalesHeader.FindFirst());
                end;
            DocumentType::"Purchase Order":
                begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("No.", DocumentNo);
                    exit(PurchHeader.FindFirst());
                end;
            DocumentType::"Transfer Order":
                begin
                    TransferHeader.SetRange("No.", DocumentNo);
                    exit(TransferHeader.FindFirst());
                end;
        end;
    end;
}