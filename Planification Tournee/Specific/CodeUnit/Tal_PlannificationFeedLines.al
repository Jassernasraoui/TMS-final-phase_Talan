codeunit 50101 "Planning Line Fetcher"
{
    procedure FetchSalesLines(DocumentNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        PlanningLine: Record "Planning Line";
        NextLineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter(Quantity, '>0');

        if SalesLine.FindSet() then begin
            PlanningLine.SetRange("Logistic Tour No.", DocumentNo);
            if PlanningLine.FindLast() then
                NextLineNo := PlanningLine."Line No." + 10000
            else
                NextLineNo := 10000;

            repeat
                PlanningLine.Init();
                PlanningLine.Validate("Logistic Tour No.", DocumentNo);
                PlanningLine.Validate("Line No.", NextLineNo);
                PlanningLine.Validate("Source Type", PlanningLine."Source Type"::Sales);
                PlanningLine.Validate("Source ID", SalesLine."Document No.");
                PlanningLine.Validate("Item No.", SalesLine."No.");
                PlanningLine.Validate(Description, SalesLine.Description);
                PlanningLine.Validate("Description 2", SalesLine."Description 2");
                PlanningLine.Validate(Quantity, SalesLine.Quantity);
                PlanningLine.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
                PlanningLine.Validate("Gen. Prod. Posting Group", SalesLine."Gen. Prod. Posting Group");
                PlanningLine.Validate("Inventory Posting Group", SalesLine."Posting Group");
                PlanningLine.Validate("Item Category Code", SalesLine."Item Category Code");
                PlanningLine.Validate("Planned Date", WorkDate());
                PlanningLine.Validate(Status, PlanningLine.Status::Open);
                PlanningLine."Created At" := CurrentDateTime;
                PlanningLine."Created By" := UserId;
                PlanningLine.Insert(true);

                NextLineNo += 10000;
            until SalesLine.Next() = 0;
        end;
    end;

    procedure FetchPurchaseLines(DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        PlanningLine: Record "Planning Line";
        NextLineNo: Integer;
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetFilter(Quantity, '>0');

        if PurchaseLine.FindSet() then begin
            PlanningLine.SetRange("Logistic Tour No.", DocumentNo);
            if PlanningLine.FindLast() then
                NextLineNo := PlanningLine."Line No." + 10000
            else
                NextLineNo := 10000;

            repeat
                PlanningLine.Init();
                PlanningLine.Validate("Logistic Tour No.", DocumentNo);
                PlanningLine.Validate("Line No.", NextLineNo);
                PlanningLine.Validate("Source Type", PlanningLine."Source Type"::Purchase);
                PlanningLine.Validate("Source ID", PurchaseLine."Document No.");
                PlanningLine.Validate("Item No.", PurchaseLine."No.");
                PlanningLine.Validate(Description, PurchaseLine.Description);
                PlanningLine.Validate("Description 2", PurchaseLine."Description 2");
                PlanningLine.Validate(Quantity, PurchaseLine.Quantity);
                PlanningLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
                PlanningLine.Validate("Gen. Prod. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
                PlanningLine.Validate("Inventory Posting Group", PurchaseLine."Posting Group");
                PlanningLine.Validate("Item Category Code", PurchaseLine."Item Category Code");
                PlanningLine.Validate("Planned Date", WorkDate());
                PlanningLine.Validate(Status, PlanningLine.Status::Open);
                PlanningLine."Created At" := CurrentDateTime;
                PlanningLine."Created By" := UserId;
                PlanningLine.Insert(true);

                NextLineNo += 10000;
            until PurchaseLine.Next() = 0;
        end;
    end;

    procedure FetchTransferLines(DocumentNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
        PlanningLine: Record "Planning Line";
        NextLineNo: Integer;
    begin
        TransferLine.SetFilter(Quantity, '>0');

        if TransferLine.FindSet() then begin
            PlanningLine.SetRange("Logistic Tour No.", DocumentNo);
            if PlanningLine.FindLast() then
                NextLineNo := PlanningLine."Line No." + 10000
            else
                NextLineNo := 10000;

            repeat
                PlanningLine.Init();
                PlanningLine.Validate("Logistic Tour No.", DocumentNo);
                PlanningLine.Validate("Line No.", NextLineNo);
                PlanningLine.Validate("Source Type", PlanningLine."Source Type"::Transfer);
                PlanningLine.Validate("Source ID", TransferLine."Document No.");
                PlanningLine.Validate("Item No.", TransferLine."Item No.");
                PlanningLine.Validate(Description, TransferLine.Description);
                PlanningLine.Validate(Quantity, TransferLine.Quantity);
                PlanningLine.Validate("Unit of Measure Code", TransferLine."Unit of Measure Code");
                PlanningLine.Validate("Planned Date", WorkDate());
                PlanningLine.Validate(Status, PlanningLine.Status::Open);
                PlanningLine."Created At" := CurrentDateTime;
                PlanningLine."Created By" := UserId;
                PlanningLine.Insert(true);

                NextLineNo += 10000;
            until TransferLine.Next() = 0;
        end;
    end;
}
