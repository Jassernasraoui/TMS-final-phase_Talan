page 77009 "Vehicle Loading Card"
{
    PageType = Card;
    SourceTable = "vehicle Loading Header";
    ApplicationArea = All;
    Caption = 'Vehicle Loading Preparation';

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
                    Editable = not IsReleased;
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
                    Editable = not IsReleased;
                }
                field("Truck No."; rec."Truck No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = not IsReleased;
                }
                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = not IsReleased;
                }
                field("Loading Location"; rec."Loading Location")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = not IsReleased;
                }
            }

            group("Timing")
            {
                field("Departure Time"; rec."Departure Time") { ApplicationArea = All; Editable = not IsReleased; }
                field("Arrival Time"; rec."Arrival Time") { ApplicationArea = All; Editable = not IsReleased; }
                field("Validation Date"; rec."Validation Date") { ApplicationArea = All; Editable = false; }
            }

            group("Load Info")
            {
                field("Total Weight (kg)"; rec."Total Weight (kg)") { ApplicationArea = All; Editable = false; }
                field("Total Volume (m³)"; rec."Total Volume (m³)") { ApplicationArea = All; Editable = not IsReleased; }
                field("Number of Deliveries"; rec."Number of Deliveries") { ApplicationArea = All; Editable = false; }
                field("Goods Type"; rec."Goods Type") { ApplicationArea = All; Editable = not IsReleased; }
            }

            group("Itinerary")
            {
                field("Itinerary No."; rec."Itinerary No.") { ApplicationArea = All; Editable = not IsReleased; }
                field("Total Distance (km)"; rec."Total Distance (km)") { ApplicationArea = All; Editable = not IsReleased; }
                field("Estimated Duration"; rec."Estimated Duration") { ApplicationArea = All; Editable = not IsReleased; }
                field("Itinerary Type"; rec."Itinerary Type") { ApplicationArea = All; Editable = not IsReleased; }
                field("Planned Route"; rec."Planned Route") { ApplicationArea = All; Editable = not IsReleased; }
            }

            group("Loading Status")
            {
                field("Status"; rec."Status") { ApplicationArea = All; Editable = false; StyleExpr = StatusStyleExpr; }
                field("Validated By"; rec."Validated By") { ApplicationArea = All; Editable = false; }
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
                end;
            }

            action("Release")
            {
                ApplicationArea = All;
                Caption = 'Release';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = (rec.Status = rec.Status::Planned) and not IsReleased;

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
                    ConfirmMsg: Label 'Are you sure you want to validate this loading preparation sheet?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" = rec."Status"::Validated then begin
                        Message('This loading preparation sheet is already validated.');
                        exit;
                    end;

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
                    ConfirmMsg: Label 'Do you want to create a vehicle charging sheet based on this loading preparation?';
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

                    // Open the new vehicle charging card
                    Message('Vehicle charging sheet %1 has been created.', VehicleChargingHeader."Vehicle Charging No.");

                    Commit();

                    VehicleChargingCard.SetRecord(VehicleChargingHeader);
                    VehicleChargingCard.Run();
                    SetStatusInProgressIfChargingStarted(VehicleChargingHeader."Tour No.");

                end;
            }

            action("Start Transport")
            {
                ApplicationArea = All;
                Caption = 'Start Transport';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if rec."Status" <> rec."Status"::Loading then begin
                        Error('Loading sheet must be in Loading status to start transport.');
                        exit;
                    end;

                    rec."Status" := rec."Status"::InProgress;
                    rec."Departure Time" := Time;
                    rec.Modify(true);
                    SetStatusStyle();
                    Message('Transport has been started.');
                end;
            }

            action("Complete Transport")
            {
                ApplicationArea = All;
                Caption = 'Complete Transport';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if rec."Status" <> rec."Status"::InProgress then begin
                        Error('Transport must be in progress to complete it.');
                        exit;
                    end;

                    rec."Status" := rec."Status"::Completed;
                    rec."Arrival Time" := Time;
                    rec.Modify(true);
                    SetStatusStyle();
                    Message('Transport has been completed.');
                end;
            }

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
        TotalWeight: Decimal;
        TotalDeliveries: Integer;
    begin
        TotalWeight := 0;
        TotalDeliveries := 0;

        StopLine.Reset();
        StopLine.SetRange("Fiche No.", Rec."No.");
        if StopLine.FindSet() then
            repeat
                TotalWeight += StopLine."Quantity to Deliver";
                TotalDeliveries += 1;
            until StopLine.Next() = 0;

        Rec."Total Weight (kg)" := TotalWeight;
        Rec."Number of Deliveries" := TotalDeliveries;
        Rec.Modify(true);

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

    var
        IsReleased: Boolean;
        StatusStyleExpr: Text;
}
