codeunit 73615 "Planning Item Tracking Mgt"
{
    procedure OpenItemTrackingLines(PlanningLine: Record "Planning Lines")
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
        Item: Record Item;
    begin
        // First, check if the item has a tracking code
        if not HasItemTrackingCode(PlanningLine."Item No.") then
            Error('Item %1 does not have item tracking code assigned.', PlanningLine."Item No.");

        // Create a tracking specification for the planning line
        CreateTrackingSpecification(PlanningLine);
    end;

    procedure HasItemTrackingCode(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item."Item Tracking Code" <> '');
        exit(false);
    end;

    local procedure CreateTrackingSpecification(PlanningLine: Record "Planning Lines")
    var
        TrackingSpecification: Record "Tracking Specification" temporary;
        ReservEntry: Record "Reservation Entry";
        ItemTrackingForm: Page "Item Tracking Lines";
        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];
        SourceBatchName: Code[10];
        SourceProdOrderLine: Integer;
        SourceRefNo: Integer;
    begin
        SourceType := Database::"Planning Lines";
        SourceSubtype := 0;
        SourceID := PlanningLine."Logistic Tour No.";
        SourceBatchName := '';
        SourceProdOrderLine := 0;
        SourceRefNo := PlanningLine."Line No.";

        // Initialize tracking specification
        TrackingSpecification.Init();
        TrackingSpecification."Source Type" := SourceType;
        TrackingSpecification."Source Subtype" := SourceSubtype;
        TrackingSpecification."Source ID" := SourceID;
        TrackingSpecification."Source Batch Name" := SourceBatchName;
        TrackingSpecification."Source Prod. Order Line" := SourceProdOrderLine;
        TrackingSpecification."Source Ref. No." := SourceRefNo;
        TrackingSpecification."Item No." := PlanningLine."Item No.";
        TrackingSpecification.Description := PlanningLine.Description;
        TrackingSpecification."Location Code" := PlanningLine."Location Code";
        TrackingSpecification."Quantity (Base)" := PlanningLine.Quantity;
        TrackingSpecification."Qty. to Handle" := PlanningLine.Quantity;
        TrackingSpecification."Qty. to Handle (Base)" := PlanningLine.Quantity;
        TrackingSpecification."Qty. to Invoice" := PlanningLine.Quantity;
        TrackingSpecification."Qty. to Invoice (Base)" := PlanningLine.Quantity;
        TrackingSpecification."Quantity Handled (Base)" := 0;
        TrackingSpecification."Quantity Invoiced (Base)" := 0;

        // Set page variables and run the page
        Clear(ItemTrackingForm);
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, PlanningLine."Expected Shipment Date");
        ItemTrackingForm.SetInbound(true);
        ItemTrackingForm.RunModal();
    end;
}