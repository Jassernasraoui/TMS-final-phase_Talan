// codeunit 50100 "Planning Line Loader"
// {
//     procedure LoadLines(TourNo: Code[20]; TourDate: Date)
//     begin
//         if TourDate = 0D then
//             Error('La date de tournée doit être spécifiée avant de charger les lignes.');

//         LoadSalesLines(TourNo, TourDate);
//         LoadPurchaseLines(TourNo, TourDate);
//         LoadTransferLines(TourNo, TourDate);

//         UpdateHeaderStatistics(TourNo);
//     end;

//     procedure LoadSalesLines(TourNo: Code[20]; TourDate: Date)
//     var
//         SalesLine: Record "Sales Line";
//         PlanningLine: Record "Planning Line";
//         NextLineNo: Integer;
//     begin
//         // Filtrer les lignes de vente avec date d'expédition égale à la date de tournée
//         SalesLine.SetRange("Shipment Date", TourDate);
//         SalesLine.SetFilter("Document Type", '%1|%2', SalesLine."Document Type"::Order, SalesLine."Document Type"::"Return Order");
//         SalesLine.SetFilter(Type, '%1', SalesLine.Type::Item);
//         SalesLine.SetFilter("Outstanding Quantity", '>0');

//         if not SalesLine.FindSet() then
//             exit;  // Pas d'erreur, simplement sortir si aucune ligne trouvée

//         // Trouver le prochain numéro de ligne
//         PlanningLine.SetRange("Logistic Tour No.", TourNo);
//         if PlanningLine.FindLast() then
//             NextLineNo := PlanningLine."Line No." + 10000
//         else
//             NextLineNo := 10000;

//         repeat
//             // Vérifier si cette ligne existe déjà
//             PlanningLine.Reset();
//             PlanningLine.SetRange("Logistic Tour No.", TourNo);
//             PlanningLine.SetRange("Source Type", PlanningLine."Source Type"::Sales);
//             PlanningLine.SetRange("Source ID", SalesLine."Document No.");
//             PlanningLine.SetRange("Item No.", SalesLine."No.");

//             if not PlanningLine.FindFirst() then begin
//                 // Créer une nouvelle ligne de planification pour chaque ligne de vente
//                 PlanningLine.Init();
//                 PlanningLine."Logistic Tour No." := TourNo;
//                 PlanningLine."Line No." := NextLineNo;
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Sales;
//                 PlanningLine."Source ID" := SalesLine."Document No.";
//                 PlanningLine."Item No." := SalesLine."No.";
//                 PlanningLine."Variant Code" := SalesLine."Variant Code";
//                 PlanningLine.Description := SalesLine.Description;
//                 PlanningLine."Description 2" := SalesLine."Description 2";
//                 PlanningLine.Quantity := SalesLine."Outstanding Quantity";
//                 PlanningLine."Quantity (Base)" := SalesLine."Outstanding Qty. (Base)";
//                 PlanningLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
//                 PlanningLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
//                 PlanningLine."Unit Volume" := SalesLine."Unit Volume";
//                 PlanningLine."Gross Weight" := SalesLine."Gross Weight";
//                 PlanningLine."Net Weight" := SalesLine."Net Weight";
//                 PlanningLine.Status := PlanningLine.Status::Open;
//                 PlanningLine."Gen. Prod. Posting Group" := SalesLine."Gen. Prod. Posting Group";
//                 PlanningLine."Inventory Posting Group" := SalesLine."Posting Group";
//                 PlanningLine."Item Category Code" := SalesLine."Item Category Code";
//                 PlanningLine."Dimension Set ID" := SalesLine."Dimension Set ID";
//                 PlanningLine."Planned Date" := TourDate;
//                 PlanningLine."Expected Shipment Date" := SalesLine."Shipment Date";
//                 PlanningLine."Created At" := CurrentDateTime;
//                 PlanningLine."Created By" := UserId;
//                 PlanningLine."Modified At" := CurrentDateTime;
//                 PlanningLine."Modified By" := UserId;
//                 PlanningLine."System ID" := System.CreateGuid();

//                 if PlanningLine.Insert() then
//                     NextLineNo += 10000;
//             end;
//         until SalesLine.Next() = 0;
//     end;

//     procedure LoadPurchaseLines(TourNo: Code[20]; TourDate: Date)
//     var
//         PurchaseLine: Record "Purchase Line";
//         PlanningLine: Record "Planning Line";
//         NextLineNo: Integer;
//     begin
//         // Filtrer les lignes d'achat avec date de réception prévue égale à la date de tournée
//         PurchaseLine.SetRange("Expected Receipt Date", TourDate);
//         PurchaseLine.SetFilter("Document Type", '%1|%2', PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::"Return Order");
//         PurchaseLine.SetFilter(Type, '%1', PurchaseLine.Type::Item);
//         PurchaseLine.SetFilter("Outstanding Quantity", '>0');

//         if not PurchaseLine.FindSet() then
//             exit;  // Pas d'erreur, simplement sortir si aucune ligne trouvée

//         // Trouver le prochain numéro de ligne
//         PlanningLine.SetRange("Logistic Tour No.", TourNo);
//         if PlanningLine.FindLast() then
//             NextLineNo := PlanningLine."Line No." + 10000
//         else
//             NextLineNo := 10000;

//         repeat
//             // Vérifier si cette ligne existe déjà
//             PlanningLine.Reset();
//             PlanningLine.SetRange("Logistic Tour No.", TourNo);
//             PlanningLine.SetRange("Source Type", PlanningLine."Source Type"::Purchase);
//             PlanningLine.SetRange("Source ID", PurchaseLine."Document No.");
//             PlanningLine.SetRange("Item No.", PurchaseLine."No.");

//             if not PlanningLine.FindFirst() then begin
//                 // Créer une nouvelle ligne de planification pour chaque ligne d'achat
//                 PlanningLine.Init();
//                 PlanningLine."Logistic Tour No." := TourNo;
//                 PlanningLine."Line No." := NextLineNo;
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Purchase;
//                 PlanningLine."Source ID" := PurchaseLine."Document No.";
//                 PlanningLine."Item No." := PurchaseLine."No.";
//                 PlanningLine."Variant Code" := PurchaseLine."Variant Code";
//                 PlanningLine.Description := PurchaseLine.Description;
//                 PlanningLine."Description 2" := PurchaseLine."Description 2";
//                 PlanningLine.Quantity := PurchaseLine."Outstanding Quantity";
//                 PlanningLine."Quantity (Base)" := PurchaseLine."Outstanding Qty. (Base)";
//                 PlanningLine."Qty. per Unit of Measure" := PurchaseLine."Qty. per Unit of Measure";
//                 PlanningLine."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
//                 PlanningLine."Unit Volume" := GetItemUnitVolume(PurchaseLine."No.");
//                 PlanningLine."Gross Weight" := PurchaseLine."Gross Weight";
//                 PlanningLine."Net Weight" := PurchaseLine."Net Weight";
//                 PlanningLine.Status := PlanningLine.Status::Open;
//                 PlanningLine."Gen. Prod. Posting Group" := PurchaseLine."Gen. Prod. Posting Group";
//                 PlanningLine."Inventory Posting Group" := GetItemInventoryPostingGroup(PurchaseLine."No.");
//                 PlanningLine."Item Category Code" := GetItemCategoryCode(PurchaseLine."No.");
//                 PlanningLine."Dimension Set ID" := PurchaseLine."Dimension Set ID";
//                 PlanningLine."Planned Date" := TourDate;
//                 PlanningLine."Expected Receipt Date" := PurchaseLine."Expected Receipt Date";
//                 PlanningLine."Created At" := CurrentDateTime;
//                 PlanningLine."Created By" := UserId;
//                 PlanningLine."Modified At" := CurrentDateTime;
//                 PlanningLine."Modified By" := UserId;
//                 PlanningLine."System ID" := System.CreateGuid();

//                 if PlanningLine.Insert() then
//                     NextLineNo += 10000;
//             end;
//         until PurchaseLine.Next() = 0;
//     end;

//     procedure LoadTransferLines(TourNo: Code[20]; TourDate: Date)
//     var
//         TransferLine: Record "Transfer Line";
//         PlanningLine: Record "Planning Line";
//         NextLineNo: Integer;
//     begin
//         // Filtrer les lignes de transfert avec date d'expédition égale à la date de tournée
//         TransferLine.SetRange("Shipment Date", TourDate);
//         TransferLine.SetFilter("Outstanding Quantity", '>0');

//         if not TransferLine.FindSet() then
//             exit;  // Pas d'erreur, simplement sortir si aucune ligne trouvée

//         // Trouver le prochain numéro de ligne
//         PlanningLine.SetRange("Logistic Tour No.", TourNo);
//         if PlanningLine.FindLast() then
//             NextLineNo := PlanningLine."Line No." + 10000
//         else
//             NextLineNo := 10000;

//         repeat
//             // Vérifier si cette ligne existe déjà
//             PlanningLine.Reset();
//             PlanningLine.SetRange("Logistic Tour No.", TourNo);
//             PlanningLine.SetRange("Source Type", PlanningLine."Source Type"::Transfer);
//             PlanningLine.SetRange("Source ID", TransferLine."Document No.");
//             PlanningLine.SetRange("Item No.", TransferLine."Item No.");

//             if not PlanningLine.FindFirst() then begin
//                 // Créer une nouvelle ligne de planification pour chaque ligne de transfert
//                 PlanningLine.Init();
//                 PlanningLine."Logistic Tour No." := TourNo;
//                 PlanningLine."Line No." := NextLineNo;
//                 PlanningLine."Source Type" := PlanningLine."Source Type"::Transfer;
//                 PlanningLine."Source ID" := TransferLine."Document No.";
//                 PlanningLine."Item No." := TransferLine."Item No.";
//                 PlanningLine."Variant Code" := TransferLine."Variant Code";
//                 PlanningLine.Description := TransferLine.Description;
//                 PlanningLine.Quantity := TransferLine."Outstanding Quantity";
//                 PlanningLine."Quantity (Base)" := TransferLine."Outstanding Qty. (Base)";
//                 PlanningLine."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
//                 PlanningLine."Unit of Measure Code" := TransferLine."Unit of Measure Code";
//                 PlanningLine."Unit Volume" := GetItemUnitVolume(TransferLine."Item No.");
//                 PlanningLine."Gross Weight" := GetItemGrossWeight(TransferLine."Item No.");
//                 PlanningLine."Net Weight" := GetItemNetWeight(TransferLine."Item No.");
//                 PlanningLine.Status := PlanningLine.Status::Open;
//                 PlanningLine."Item Category Code" := GetItemCategoryCode(TransferLine."Item No.");
//                 PlanningLine."Gen. Prod. Posting Group" := GetItemGenProdPostingGroup(TransferLine."Item No.");
//                 PlanningLine."Inventory Posting Group" := GetItemInventoryPostingGroup(TransferLine."Item No.");
//                 PlanningLine."Planned Date" := TourDate;
//                 PlanningLine."Expected Shipment Date" := TransferLine."Shipment Date";
//                 PlanningLine."Created At" := CurrentDateTime;
//                 PlanningLine."Created By" := UserId;
//                 PlanningLine."Modified At" := CurrentDateTime;
//                 PlanningLine."Modified By" := UserId;
//                 PlanningLine."System ID" := System.CreateGuid();

//                 if PlanningLine.Insert() then
//                     NextLineNo += 10000;
//             end;
//         until TransferLine.Next() = 0;
//     end;

//     local procedure UpdateHeaderStatistics(TourNo: Code[20])
//     var
//         PlanningLine: Record "Planning Line";
//         PlanHeader: Record "Planification Header";
//         TotalWeight: Decimal;
//         TotalQuantity: Decimal;
//         LineCount: Integer;
//     begin
//         if not PlanHeader.Get(TourNo) then
//             exit;

//         PlanningLine.Reset();
//         PlanningLine.SetRange("Logistic Tour No.", TourNo);
//         LineCount := PlanningLine.Count;

//         if LineCount = 0 then begin
//             PlanHeader."No. of Planning Lines" := 0;
//             PlanHeader."Total Quantity" := 0;
//             PlanHeader."Estimated Total Weight" := 0;
//             PlanHeader.Modify();
//             exit;
//         end;

//         // Calculer les totaux
//         PlanningLine.FindSet();
//         repeat
//             TotalQuantity += PlanningLine.Quantity;
//             TotalWeight += PlanningLine."Gross Weight" * PlanningLine.Quantity;
//         until PlanningLine.Next() = 0;

//         // Mettre à jour l'en-tête
//         PlanHeader."No. of Planning Lines" := LineCount;
//         PlanHeader."Total Quantity" := TotalQuantity;
//         PlanHeader."Estimated Total Weight" := TotalWeight;
//         PlanHeader.Modify();
//     end;

//     local procedure GetItemUnitVolume(ItemNo: Code[20]): Decimal
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Unit Volume");
//         exit(0);
//     end;

//     local procedure GetItemGrossWeight(ItemNo: Code[20]): Decimal
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Gross Weight");
//         exit(0);
//     end;

//     local procedure GetItemNetWeight(ItemNo: Code[20]): Decimal
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Net Weight");
//         exit(0);
//     end;

//     local procedure GetItemCategoryCode(ItemNo: Code[20]): Code[20]
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Item Category Code");
//         exit('');
//     end;

//     local procedure GetItemGenProdPostingGroup(ItemNo: Code[20]): Code[20]
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Gen. Prod. Posting Group");
//         exit('');
//     end;

//     local procedure GetItemInventoryPostingGroup(ItemNo: Code[20]): Code[20]
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then
//             exit(Item."Inventory Posting Group");
//         exit('');
//     end;
// }