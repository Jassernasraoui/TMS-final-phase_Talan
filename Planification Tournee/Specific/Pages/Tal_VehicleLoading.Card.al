page 73609 "Vehicle Loading Card"
{
    PageType = Card;
    SourceTable = "vehicle Loading Header";
    ApplicationArea = All;
    Caption = 'Vehcile Charging Preparation Card';

    layout
    {
        area(content)
        {
            group("General")
            {
                Caption = 'Preparation Details';
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                }
                field("Loading Date"; rec."Loading Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    Editable = not IsReleased;
                }
                field("Tour No."; rec."Tour No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = false;
                    Style = StandardAccent;
                }
                field("Vehicle No."; rec."Vehicle No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = false;
                    Style = StandardAccent;
                    trigger OnValidate()
                    begin
                        UpdateVehicleInfo();
                    end;
                }
                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = false;
                    Style = StandardAccent;
                }

            }
            group("Loading Status")
            {
                group("Location")
                {

                    field("Warehouse Location"; rec."Warehouse Location")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = false;

                    }
                    field("Loading Location"; rec."Loading Location")
                    {
                        Caption = 'Transfer to location';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = false;
                    }
                }
                group("Validation statuts")
                {

                    field("Status"; rec."Status") { ApplicationArea = All; Editable = false; StyleExpr = StatusStyleExpr; }
                    field("Validated By"; rec."Validated By") { ApplicationArea = All; Editable = false; }
                    field("Validation Date"; rec."Validation Date") { ApplicationArea = All; Editable = false; }

                }
            }

            // group("Timing")
            // {
            //     field("Departure Time"; rec."Departure Time") { ApplicationArea = All; Editable = not IsReleased; }
            //     field("Arrival Time"; rec."Arrival Time") { ApplicationArea = All; Editable = not IsReleased; }
            // }

            group("Load Info")
            {


                group("Delivery Informations")
                {
                    field("Total Quantity"; rec."Total Quantity")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Editable = not IsReleased;
                        Visible = false;
                    }
                    field("Weight"; rec."Total Weight (kg)") { ApplicationArea = All; Editable = false; }
                    field("Total Volume (m³)"; rec."Total Volume (m³)") { ApplicationArea = All; Editable = false; }
                    field("Number of Deliveries"; rec."Number of Deliveries") { ApplicationArea = All; Editable = false; Style = Strong; }
                }
                field("Goods Type"; rec."Goods Type") { ApplicationArea = All; Editable = not IsReleased; Visible = false; }
                group("Vehicle informations")
                {
                    field("vehicle volume"; VehicleVolume)
                    {
                        ApplicationArea = All;
                        Caption = 'Vehicle Volume';
                        Style = StandardAccent;
                        ToolTip = 'Specifies the volume of the vehicle used for loading.';
                        Editable = false;
                    }
                    field("Max Capacity Charge"; VehicleMaxCapacity)
                    {
                        ApplicationArea = All;
                        Caption = 'Max Capacity Charge';
                        Style = StandardAccent;
                        ToolTip = 'Specifies the maximum weight capacity of the vehicle used for loading.';
                        Editable = false;
                    }
                }
            }

            group("Itinerary")
            {
                field("Itinerary No."; rec."Itinerary No.") { ApplicationArea = All; Editable = not IsReleased; Visible = false; }
                field("Total Distance (km)"; rec."Total Distance (km)") { ApplicationArea = All; Editable = not IsReleased; }
                field("Estimated Duration"; rec."Estimated Duration") { ApplicationArea = All; Editable = not IsReleased; }
                field("Itinerary Type"; rec."Itinerary Type") { ApplicationArea = All; Editable = not IsReleased; Visible = false; }
                field("Planned Route"; rec."Planned Route") { ApplicationArea = All; Editable = not IsReleased; ; Visible = false; }
            }



            part("StopsPart"; "vehicle Stop List")
            {
                SubPageLink = "Fiche No." = FIELD("No.");
                ApplicationArea = All;
                Caption = 'Planned Stops';
                Editable = not IsReleased;
            }
        }
    }

    actions
    {
        area(Processing)
        {


            action("Release")
            {
                ApplicationArea = All;
                Caption = 'Release';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = (rec.Status = rec.Status::Planned) and not IsReleased and iscalculated;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to release this preparation document? After release, some fields cannot be modified.';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    // Check required fields before releasing
                    rec.CheckRequiredFields();

                    // Set status to loading (intermediate status before validation)
                    rec.Status := rec.Status::Loading;
                    rec.Modify(true);

                    // Update page variables
                    IsReleased := true;
                    SetStatusStyle();

                    Message('The preparation document has been released and is now ready for validation.');
                end;
            }
            action("Calculate Totals")
            {
                ApplicationArea = All;
                Caption = 'Calculate Totals';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalculateTotals();
                    iscalculated := true;
                end;
            }

            action("Validate Loading Preparation")
            {
                ApplicationArea = All;
                Caption = 'Validate Preparation';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = rec.Status = rec.Status::Loading;

                trigger OnAction()
                var
                    itemLedgEntry: Record "Item Ledger Entry";
                    availableQty: Decimal;
                    inventoryLine: Record "vehicle Stop Line";
                    ConfirmMsg: Label 'Are you sure you want to validate this loading preparation sheet?';
                    TripSetup: Record "Trip Setup";
                    CompanyLocationCode: Code[20];
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    // Check if already validated
                    if rec."Status" = rec."Status"::Validated then begin
                        Message('This loading preparation sheet is already validated.');
                        exit;
                    end;
                    begin
                        // Get company location code from setup
                        if TripSetup.Get() then
                            CompanyLocationCode := TripSetup."Location Code";
                    end;

                    // Validate quantities for all stop lines
                    inventoryLine.SetRange("Fiche No.", rec."No.");
                    if inventoryLine.FindSet() then
                        repeat
                            availableQty := 0;

                            if inventoryLine."item" <> '' then begin
                                itemLedgEntry.Reset();
                                itemLedgEntry.SetRange("Item No.", inventoryLine."item");
                                itemLedgEntry.SetRange("Location Code", TripSetup."Location Code"); // if using locations
                                itemLedgEntry.SetRange(Open, true); // Optional: only open entries
                                itemLedgEntry.CalcSums("Remaining Quantity");
                                availableQty := itemLedgEntry."Remaining Quantity";
                            end;

                            if inventoryLine."Quantity to prepare" > availableQty then
                                Error(
                                    'line %1: Quantity to prepare : %2  cannot exceed available inventory : %3 for item %4 ',
                                    inventoryLine."Stop No.",
                                    inventoryLine."Quantity to prepare",
                                    availableQty,
                                    inventoryLine."item");

                        until inventoryLine.Next() = 0;
                    // Auto-update "Quantity prepared" with "Quantity to prepare"
                    inventoryLine.SetRange("Fiche No.", rec."No.");
                    if inventoryLine.FindSet() then
                        repeat
                            if inventoryLine."Quantity prepared" <> inventoryLine."Quantity to prepare" then begin
                                inventoryLine."Quantity prepared" := inventoryLine."Quantity to prepare";
                                inventoryLine.Modify();
                            end;
                        until inventoryLine.Next() = 0;



                    // Mark sheet as validated
                    rec."Status" := rec."Status"::Validated;
                    rec."Validated By" := UserId;
                    rec."Validation Date" := CurrentDateTime;
                    rec.Modify(true);

                    SetStatusStyle();

                    Message('Loading preparation sheet has been validated and is ready for the charging phase.');
                end;

            }

            action("Reopen")
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = (rec.Status = rec.Status::Loading) and IsReleased;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to reopen this preparation document?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    rec.Status := rec.Status::Planned;
                    rec.Modify(true);

                    IsReleased := false;
                    SetStatusStyle();

                    Message('The preparation document has been reopened for editing.');
                end;
            }

            action("Create Vehicle Charging Sheet")
            {
                ApplicationArea = All;
                Caption = 'Create Vehicle Charging Sheet';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = rec.Status = rec.Status::Validated;

                trigger OnAction()
                var
                    VehicleChargingHeader: Record "Vehicle Charging Header";
                    VehicleChargingCard: Page "Vehicle Charging Card";
                    TransferHeader: Record "Transfer Header";
                    TransferLine: Record "Transfer Line";
                    StopLine: Record "vehicle Stop Line";
                    TripSetup: Record "Trip Setup";
                    ConfirmMsg: Label 'Do you want to create a vehicle charging sheet based on this loading preparation?';
                    LineNo: Integer;
                    TransferOrderNo: Code[20];
                    ExistingTransferHeader: Record "Transfer Header";
                begin
                    if rec."Status" <> rec."Status"::Validated then begin
                        Error('The loading preparation must be validated before creating a charging sheet.');
                        exit;
                    end;

                    if not Confirm(ConfirmMsg) then
                        exit;

                    // Check if a charging sheet already exists for this loading sheet
                    VehicleChargingHeader.Reset();
                    VehicleChargingHeader.SetRange("Loading Sheet No.", Rec."No.");
                    if VehicleChargingHeader.FindFirst() then begin
                        if Confirm('A vehicle charging sheet already exists for this loading preparation. Do you want to view it?') then begin
                            VehicleChargingCard.SetRecord(VehicleChargingHeader);
                            VehicleChargingCard.Run();
                        end;
                        exit;
                    end;

                    // Create new vehicle charging header
                    VehicleChargingHeader.Init();
                    VehicleChargingHeader."Loading Sheet No." := Rec."No.";
                    VehicleChargingHeader."Charging Date" := Rec."Loading Date";
                    VehicleChargingHeader."Status" := VehicleChargingHeader."Status"::InProgress;
                    VehicleChargingHeader.Insert(true);
                    VehicleChargingHeader.GetLoadingInfo();

                    // Check if a transfer order already exists for this tour
                    ExistingTransferHeader.Reset();
                    ExistingTransferHeader.SetRange("Logistic Tour No.", Rec."Tour No.");
                    if ExistingTransferHeader.FindFirst() then begin
                        // Use existing transfer order
                        TransferOrderNo := ExistingTransferHeader."No.";
                        if Confirm('A transfer order %1 already exists for this tour. Do you want to use it?', false, TransferOrderNo) then begin
                            // Link the existing transfer order to the charging header
                            VehicleChargingHeader."Transfer Order No." := TransferOrderNo;
                            VehicleChargingHeader.Modify(true);

                            // Open the new vehicle charging card
                            Message('Vehicle charging sheet %1 has been created with existing transfer order %2.',
                                    VehicleChargingHeader."Vehicle Charging No.", TransferOrderNo);

                            Commit();

                            VehicleChargingCard.SetRecord(VehicleChargingHeader);
                            VehicleChargingCard.Run();
                            SetStatusInProgressIfChargingStarted(VehicleChargingHeader."Tour No.");
                            exit;
                        end;
                    end;

                    // Create Transfer Order
                    TransferHeader.Init();
                    TransferHeader."No." := '';
                    TransferHeader.Insert(true);
                    TransferOrderNo := TransferHeader."No.";

                    // Set Transfer Header fields
                    TransferHeader.Validate("Transfer-from Code", rec."Warehouse Location"); // Replace with actual warehouse/location code
                    TransferHeader.Validate("Transfer-to Code", VehicleChargingHeader."Truck No."); // Create a location for vehicles
                    TransferHeader.Validate("Direct Transfer", true);
                    // TransferHeader.Validate("In-Transit Code", 'INTERNE'); // Create a transit location
                    TransferHeader.Validate("Shipment Date", Rec."Loading Date");
                    TransferHeader.Validate("Receipt Date", Rec."Loading Date");
                    TransferHeader.Validate("Logistic Tour No.", Rec."Tour No.");
                    TransferHeader.Validate("Document DateTime", CurrentDateTime);
                    TransferHeader.Validate("Requested Shipment DateTime", CreateDateTime(Rec."Loading Date", Time));
                    TransferHeader.Modify(true);

                    // Create Transfer Lines from Stop Lines
                    StopLine.Reset();
                    StopLine.SetRange("Fiche No.", Rec."No.");
                    LineNo := 10000;

                    // Check if there are any non-purchase lines that need a transfer order
                    StopLine.SetFilter("Type", '<>%1', StopLine."Type"::Purchase);
                    if not StopLine.IsEmpty() then begin
                        // Create Transfer Lines only for non-purchase lines
                        if StopLine.FindSet() then begin
                            repeat
                                if StopLine."Quantity to Deliver" > 0 then begin
                                    TransferLine.Init();
                                    TransferLine."Document No." := TransferOrderNo;
                                    TransferLine."Line No." := LineNo;
                                    TransferLine.Validate("Item No.", StopLine.item);
                                    TransferLine.Validate("Unit of Measure Code", stopline."unit of measure code");
                                    TransferLine.Validate(Quantity, StopLine."Quantity prepared");
                                    TransferLine.Validate("Logistic Tour No.", Rec."Tour No.");
                                    TransferLine.Validate("Qty. to Ship", StopLine."Quantity prepared");

                                    TransferLine.Insert(true);
                                    LineNo += 10000;
                                end;
                            until StopLine.Next() = 0;

                            // Link the transfer order to the charging header
                            VehicleChargingHeader."Transfer Order No." := TransferOrderNo;
                            VehicleChargingHeader.Modify(true);

                            // Open the new vehicle charging card
                            Message('Vehicle charging sheet %1 has been created with transfer order %2.',
                                    VehicleChargingHeader."Vehicle Charging No.", TransferOrderNo);
                        end;
                    end else begin
                        // No transfer lines needed, only purchase lines exist
                        Message('Vehicle charging sheet %1 has been created without transfer order (only purchase lines).',
                                VehicleChargingHeader."Vehicle Charging No.");
                    end;

                    Commit();

                    VehicleChargingCard.SetRecord(VehicleChargingHeader);
                    VehicleChargingCard.Run();
                    SetStatusInProgressIfChargingStarted(VehicleChargingHeader."Tour No.");
                end;
            }
            action("Vehicle file")
            {
                ApplicationArea = All;
                Caption = 'Vehicle File';
                Image = TransferReceipt;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    VehicleRec: Record Resource;
                    VehicleCard: Page " Tal Vehicule resources card ";
                begin
                    if rec."Vehicle No." = '' then begin
                        Message('No vehicle is associated with this loading sheet.');
                        exit;
                    end;

                    if VehicleRec.Get(rec."Vehicle No.") then begin
                        VehicleCard.SetRecord(VehicleRec);
                        VehicleCard.Run();
                    end else
                        Message('Vehicle %1 was not found.', rec."Vehicle No.");
                end;
            }


            // action("Start Transport")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Start Transport';
            //     Image = Start;
            //     Promoted = true;
            //     PromotedCategory = Process;

            //     trigger OnAction()
            //     begin
            //         if rec."Status" <> rec."Status"::Loading then begin
            //             Error('Loading sheet must be in Loading status to start transport.');
            //             exit;
            //         end;

            //         rec."Status" := rec."Status"::InProgress;
            //         rec."Departure Time" := Time;
            //         rec.Modify(true);
            //         SetStatusStyle();
            //         Message('Transport has been started.');
            //     end;
            // }

            // action("Complete Transport")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Complete Transport';
            //     Image = Close;
            //     Promoted = true;
            //     PromotedCategory = Process;

            //     trigger OnAction()
            //     begin
            //         if rec."Status" <> rec."Status"::InProgress then begin
            //             Error('Transport must be in progress to complete it.');
            //             exit;
            //         end;

            //         rec."Status" := rec."Status"::Completed;
            //         rec."Arrival Time" := Time;
            //         rec.Modify(true);
            //         SetStatusStyle();
            //         Message('Transport has been completed.');
            //     end;
            // }

            action("View Tour")
            {
                ApplicationArea = All;
                Caption = 'View Tour';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TourHeader: Record "Planification Header";
                    TourCard: Page "Planification Document";
                begin
                    if rec."Tour No." = '' then begin
                        Message('No tour is associated with this loading sheet.');
                        exit;
                    end;

                    TourHeader.Reset();
                    TourHeader.SetRange("Logistic Tour No.", rec."Tour No.");
                    if TourHeader.FindFirst() then begin
                        TourCard.SetRecord(TourHeader);
                        TourCard.Run();
                    end else
                        Message('Associated tour %1 was not found.', rec."Tour No.");
                end;
            }

            action(CreateChargingDocument)
            {
                ApplicationArea = All;
                Caption = '🚚 Créer Document Chargement';
                ToolTip = 'Créer un document de chargement basé sur ce document de préparation';
                Image = NewShipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    Message('Cette fonctionnalité sera disponible dans une version future.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsReleased := (Rec.Status <> Rec.Status::Planned);
        SetStatusStyle();
        UpdateVehicleInfo();
    end;

    trigger OnOpenPage()
    begin
        IsReleased := (Rec.Status <> Rec.Status::Planned);
        SetStatusStyle();

    end;

    procedure SetRecord(var LoadingRec: Record "Vehicle Loading Header")
    begin
        Rec := LoadingRec;
        IsReleased := (Rec.Status <> Rec.Status::Planned);
    end;

    procedure SetStatusInProgressIfChargingStarted(TourNo: Code[20])
    var
        PlanHeader: Record "Planification Header";
    begin
        if PlanHeader.Get(TourNo) then begin
            PlanHeader.Statut := PlanHeader.Statut::Inprogress;
            PlanHeader.Modify(true);
        end;
    end;

    procedure CalculateTotals()
    var
        StopLine: Record "vehicle Stop Line";
        TotalQtty: Decimal;
        TotalDeliveries: Integer;
        TotalWeight: Decimal;
        TotalVolume: Decimal;
        VehicleRec: Record Resource;
        SelectedVehicle: Record Resource;
        tourheader: Record "Planification Header";
    begin
        TotalQtty := 0;
        TotalDeliveries := 0;
        TotalWeight := 0;  // Initialize TotalWeight
        TotalVolume := 0;

        StopLine.Reset();
        StopLine.SetRange("Fiche No.", Rec."No.");
        if StopLine.FindSet() then
            repeat
                TotalQtty += StopLine."Quantity to Prepare";
                TotalDeliveries += 1;
                TotalWeight += StopLine."Gross weight" * StopLine."Quantity to Prepare";
                TotalVolume += StopLine."Unit volume" * StopLine."Quantity to Prepare";
            until StopLine.Next() = 0;

        Rec."Total Quantity" := TotalQtty;
        Rec."Number of Deliveries" := TotalDeliveries;
        Rec."Total Weight (kg)" := TotalWeight;
        Rec."Total Volume (m³)" := TotalVolume;
        Rec.Modify(true);

        // Get the vehicle record based on the selected vehicle in the header
        if Rec."Vehicle No." <> '' then begin
            if VehicleRec.Get(Rec."Vehicle No.") then begin
                if (TotalVolume > VehicleRec."vehicle volume") or (TotalWeight > VehicleRec."Max Capacity Charge") then begin
                    if Confirm(
                        'Le volume total (%1 m³) et/ou le poids total (%2 kg) dépassent les capacités du véhicule (volume : %3 m³, charge : %4 kg). Voulez-vous rechercher automatiquement un véhicule adapté ?',
                        false,
                        TotalVolume, TotalWeight, VehicleRec."vehicle volume", VehicleRec."Max Capacity Charge") then begin

                        // Recherche automatique d'un véhicule adapté
                        Clear(SelectedVehicle);
                        SelectedVehicle.Reset();
                        SelectedVehicle.SetFilter("Resource Status", 'available');
                        SelectedVehicle.SetFilter("vehicle volume", '>=%1', TotalVolume);
                        SelectedVehicle.SetFilter("Max Capacity Charge", '>=%1', TotalWeight);

                        if SelectedVehicle.FindFirst() then begin
                            Rec.Validate("Vehicle No.", SelectedVehicle."No.");
                            // Update the vehicle in the associated planification header as well
                            if tourheader.Get(Rec."Tour No.") then begin
                                tourheader.Validate("Véhicule No.", SelectedVehicle."No.");
                                tourheader.Modify(true);
                            end;
                            Rec.Modify(true);
                            Message('✅ Véhicule remplacé automatiquement par : %1 (Volume: %2 m³, Charge: %3 kg)',
                                SelectedVehicle."No.", SelectedVehicle."vehicle volume", SelectedVehicle."Max Capacity Charge");
                        end else
                            Error('🚫 Aucun véhicule disponible ne peut supporter cette charge (volume requis : %1 m³, poids requis : %2 kg).',
                                TotalVolume, TotalWeight);
                    end else
                        Error('Veuillez ajuster le chargement ou choisir un véhicule plus adapté.');
                end;
            end;
        end;

        Message('Totals have been calculated.');
    end;

    procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Planned:
                StatusStyleExpr := 'Standard';
            Rec.Status::Loading:
                StatusStyleExpr := 'Attention';
            Rec.Status::Validated:
                StatusStyleExpr := 'Favorable';
            Rec.Status::InProgress:
                StatusStyleExpr := 'StrongAccent';
            Rec.Status::Completed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Canceled:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;

    local procedure UpdateVehicleInfo()
    var
        VehicleRec: Record Resource;
    begin
        VehicleVolume := 0;
        VehicleMaxCapacity := 0;

        if Rec."Vehicle No." <> '' then begin
            if VehicleRec.Get(Rec."Vehicle No.") then begin
                VehicleVolume := VehicleRec."vehicle volume";
                VehicleMaxCapacity := VehicleRec."Max Capacity Charge";
            end;
        end;
    end;

    // Check m3a bilel (Warehouse management) for creating warehouse documents

    // local procedure CreateWarehouseDocuments(TransferHeader: Record "Transfer Header")
    // var
    //     Location: Record Location;
    //     GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
    //     GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    //     WarehouseRequest: Record "Warehouse Request";
    // begin
    //     // Release the transfer order if it's not already released
    //     // if TransferHeader.Status <> TransferHeader.Status::Released then begin
    //     //     TransferHeader.Status := TransferHeader.Status::Released;
    //     //     TransferHeader.Modify();
    //     // end;

    //     // Check if warehouse receipt is required for the transfer-to location
    //     if Location.Get(TransferHeader."Transfer-to Code") then begin
    //         if Location."Require Receive" then begin
    //             // Clear any existing warehouse requests
    //             WarehouseRequest.SetCurrentKey("Source Document", "Source No.");
    //             WarehouseRequest.SetRange("Source Document", WarehouseRequest."Source Document"::"Inbound Transfer");
    //             WarehouseRequest.SetRange("Source No.", TransferHeader."No.");
    //             WarehouseRequest.DeleteAll();

    //             // Create warehouse receipt
    //             GetSourceDocInbound.CreateFromInbndTransferOrder(TransferHeader);
    //         end;
    //     end;

    //     // Check if warehouse shipment is required for the transfer-from location
    //     if Location.Get(TransferHeader."Transfer-from Code") then begin
    //         if Location."Require Shipment" then begin
    //             // Clear any existing warehouse requests
    //             WarehouseRequest.SetCurrentKey("Source Document", "Source No.");
    //             WarehouseRequest.SetRange("Source Document", WarehouseRequest."Source Document"::"Outbound Transfer");
    //             WarehouseRequest.SetRange("Source No.", TransferHeader."No.");
    //             WarehouseRequest.DeleteAll();

    //             // Create warehouse shipment
    //             GetSourceDocOutbound.CreateFromOutbndTransferOrder(TransferHeader);
    //         end;
    //     end;
    // end;

    var
        IsReleased: Boolean;
        iscalculated: Boolean;
        StatusStyleExpr: Text;
        VehicleVolume: Decimal;
        VehicleMaxCapacity: Decimal;
}

