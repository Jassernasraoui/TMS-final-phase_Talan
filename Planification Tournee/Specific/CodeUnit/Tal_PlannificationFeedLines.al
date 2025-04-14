// codeunit 50107 "Planning Line Feeder"
// {
//     Subtype = Normal;

//     trigger OnRun()
//     begin
//         FeedFromSalesLines();
//         FeedFromPurchaseLines();
//         FeedFromTransferLines();
//     end;

//     local procedure FeedFromSalesLines()
//     var
//         SalesLine: Record "Sales Line";
//         PlanningLine: Record "Planning Line";
//     begin
//         SalesLine.Reset();
//         if SalesLine.FindSet() then
//             repeat
//                 Clear(PlanningLine);
//                 PlanningLine.Init();
//                 PlanningLine."Document No." := SalesLine."Document No.";
//                 PlanningLine."Line No." := SalesLine."Line No.";
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Sales;
//                 PlanningLine."Item No." := SalesLine."No.";
//                 PlanningLine.Description := SalesLine.Description;
//                 PlanningLine.Quantity := SalesLine.Quantity;
//                 PlanningLine."Quantity (Base)" := SalesLine."Quantity (Base)";
//                 PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
//                 PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
//                 PlanningLine."Planned Date" := SalesLine."Shipment Date";
//                 PlanningLine.Insert();
//             until SalesLine.Next() = 0;
//     end;

//     local procedure FeedFromPurchaseLines()
//     var
//         PurchaseLine: Record "Purchase Line";
//         PlanningLine: Record "Planning Line";
//     begin
//         PurchaseLine.Reset();
//         if PurchaseLine.FindSet() then
//             repeat
//                 Clear(PlanningLine);
//                 PlanningLine.Init();
//                 PlanningLine."Document No." := PurchaseLine."Document No.";
//                 PlanningLine."Line No." := PurchaseLine."Line No.";
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Purchase;
//                 PlanningLine."Item No." := PurchaseLine."No.";
//                 PlanningLine.Description := PurchaseLine.Description;
//                 PlanningLine.Quantity := PurchaseLine.Quantity;
//                 PlanningLine."Quantity (Base)" := PurchaseLine."Quantity (Base)";
//                 PlanningLine."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
//                 PlanningLine."Qty. per Unit of Measure" := PurchaseLine."Qty. per Unit of Measure";
//                 PlanningLine."Planned Date" := PurchaseLine."Expected Receipt Date";
//                 PlanningLine.Insert();
//             until PurchaseLine.Next() = 0;
//     end;

//     local procedure FeedFromTransferLines()
//     var
//         TransferLine: Record "Transfer Line";
//         PlanningLine: Record "Planning Line";
//     begin
//         TransferLine.Reset();
//         if TransferLine.FindSet() then
//             repeat
//                 Clear(PlanningLine);
//                 PlanningLine.Init();
//                 PlanningLine."Document No." := TransferLine."Document No.";
//                 PlanningLine."Line No." := TransferLine."Line No.";
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Transfer;
//                 PlanningLine."Item No." := TransferLine."Item No.";
//                 PlanningLine.Description := TransferLine.Description;
//                 PlanningLine.Quantity := TransferLine.Quantity;
//                 PlanningLine."Quantity (Base)" := TransferLine."Quantity (Base)";
//                 PlanningLine."Unit of Measure Code" := TransferLine."Unit of Measure Code";
//                 PlanningLine."Qty. per Unit of Measure" := 1; // ou une autre valeur selon ta logique
//                 PlanningLine."Planned Date" := TransferLine."Shipment Date";
//                 PlanningLine.Insert();
//             until TransferLine.Next() = 0;
//     end;
// }
