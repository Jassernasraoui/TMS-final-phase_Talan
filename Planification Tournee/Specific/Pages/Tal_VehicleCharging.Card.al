page 73512 "Vehicle Charging Card"
{
    PageType = Card;
    SourceTable = "Vehicle Charging Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("General")
            {
                field("No."; rec."Vehicle Charging No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                }
                field("Loading Sheet No."; Rec."Loading Sheet No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Style = StandardAccent;

                    Editable = false;

                    trigger OnValidate()
                    begin
                        Rec.GetLoadingInfo();
                        CurrPage.Update(true);
                    end;
                }
                field("Charging Date"; rec."Charging Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    Editable = not IsReleased;
                }
                field("Tour No."; rec."Tour No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = StandardAccent;
                }
                field("Truck No."; rec."Truck No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Loading Location"; rec."Loading Location")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false; // Hide this field as it is not needed in the card view
                }
            }

            group("Timing")
            {
                field("Start Time"; rec."Start Time")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Editable = IsReleased and (rec.Status = rec.Status::InProgress);
                }
                field("End Time"; rec."End Time")
                {
                    ApplicationArea = All;
                    Editable = IsReleased and (rec.Status = rec.Status::InProgress);
                }
                field("Completion Date"; rec."Completion Date") { ApplicationArea = All; Editable = false; }
            }

            group("Load Info")
            {
                field("Actual Weight (kg)"; rec."Actual Weight (kg)")
                {
                    ApplicationArea = All;
                    Editable = IsReleased and (rec.Status = rec.Status::InProgress);
                }
                field("Actual Volume (m³)"; rec."Actual Volume (m³)")
                {
                    ApplicationArea = All;
                    Editable = IsReleased and (rec.Status = rec.Status::InProgress);
                }
                field("Notes"; rec."Notes")
                {
                    ApplicationArea = All;
                    Editable = IsReleased and (rec.Status = rec.Status::InProgress);
                }
            }

            group("Vehicle Status")
            {
                field("Status"; rec."Status") { ApplicationArea = All; Editable = false; StyleExpr = StatusStyleExpr; }
                field("Completed By"; rec."Completed By") { ApplicationArea = All; Editable = false; }
            }

            part("ChargingLinesPart"; "Vehicle Charging Line List")
            {
                SubPageLink = "Charging No." = FIELD("Vehicle Charging No.");
                ApplicationArea = All;
                Editable = IsReleased and (rec.Status = rec.Status::InProgress);
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
                // Caption = '"Generate Lines From Loading Sheet"';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = ReleaseEnabled;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to release this charging document? You must generate lines first.';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    // Check if Loading Sheet No. exists
                    if rec."Loading Sheet No." = '' then begin
                        Error('Loading Sheet No. must be specified before releasing.');
                        exit;
                    end;

                    // Generate lines automatically
                    GenerateChargingLines();

                    // Set status to InProgress (it should already be this, but ensure it)
                    rec."Status" := rec."Status"::InProgress;
                    rec."Released" := true;
                    rec.Modify(true);

                    // Update page variables
                    IsReleased := true;
                    SetStatusStyle();
                    SetActionEnabledStates();

                    Message('The charging document has been released and is now ready for recording loading details.');
                end;
            }

            action("Start Charging")
            {
                ApplicationArea = All;
                Caption = 'Start Charging';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = StartChargingEnabled;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to start the charging process?';
                    TransferShipmentHdr: Record "Transfer Shipment Header";
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" <> rec."Status"::InProgress then begin
                        Error('Charging must be released before it can be started.');
                        //  Check that the Transfer Shipment has been posted
                        TransferShipmentHdr.Reset();
                        TransferShipmentHdr.SetRange("Transfer Order No.", rec."Transfer Order No.");
                        if not TransferShipmentHdr.FindFirst() then
                            Error('The transfer order has not been posted yet. Please post the shipment before starting the charging.');
                        exit;
                    end;

                    rec."Start Time" := Time;
                    rec.Modify(true);
                    SetStatusStyle();
                    Message('Charging process has been started.');
                end;
            }

            action("Complete Charging")
            {
                ApplicationArea = All;
                Caption = 'Complete Charging';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = CompleteChargingEnabled;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to complete the charging process?';
                    TransferShipmentHdr: Record "Transfer Shipment Header";
                    TransferReceiptHdr: Record "Transfer Receipt Header";
                    ChargingLine: Record "Vehicle Charging Line";
                    transfeline: Record "Transfer line";
                    HasOnlyPurchaseLines: Boolean;
                    HasNonPurchaseLines: Boolean;
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" <> rec."Status"::InProgress then
                        Error('Charging must be in progress to complete it.');

                    // Vérifier si la feuille contient uniquement des lignes d'achat
                    HasOnlyPurchaseLines := true;
                    HasNonPurchaseLines := false;

                    ChargingLine.Reset();
                    ChargingLine.SetRange("Charging No.", rec."Vehicle Charging No.");
                    if ChargingLine.FindSet() then
                        repeat
                            if ChargingLine."Document Type" <> ChargingLine."Document Type"::Purchase then begin
                                HasOnlyPurchaseLines := false;
                                HasNonPurchaseLines := true;
                            end;
                        until (ChargingLine.Next() = 0) or HasNonPurchaseLines;

                    // Si la feuille contient des lignes non-achat, vérifier que l'ordre de transfert a été posté
                    if HasNonPurchaseLines then begin
                        //  Check that the Transfer Shipment has been posted
                        TransferShipmentHdr.Reset();
                        TransferShipmentHdr.SetRange("Transfer Order No.", rec."Transfer Order No.");
                        if not TransferShipmentHdr.FindFirst() then
                            Error('The transfer order has not been posted yet. Please post the shipment before completing the charging.');
                        TransferReceiptHdr.Reset();
                        TransferReceiptHdr.SetRange("Transfer Order No.", rec."Transfer Order No.");
                        if not TransferReceiptHdr.FindFirst() then
                            Error('The transfer order has not been posted yet. Please post the receipt before completing the charging.');
                    end;

                    // Business validations
                    rec.CheckRequiredFieldsAndLines();

                    rec."Status" := rec."Status"::Completed;
                    rec."End Time" := Time;
                    rec."Completed By" := UserId;
                    rec."Completion Date" := CurrentDateTime;
                    rec.Modify(true);
                    SetStatusStyle();

                    if HasOnlyPurchaseLines then
                        Message('Charging process has been completed for purchase orders.')
                    else
                        Message('Charging process has been completed.');
                end;
            }
            action("Show Posted Shipment")
            {
                ApplicationArea = All;
                Caption = 'Show Posted Shipment';
                ToolTip = 'Open the posted shipment associated with this transfer order.';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = rec."Transfer Order No." <> '';

                trigger OnAction()
                var
                    TransferShipmentHdr: Record "Transfer Shipment Header";
                    TransferShipmentCard: Page "Posted Transfer Shipment";
                begin
                    TransferShipmentHdr.Reset();
                    TransferShipmentHdr.SetRange("Transfer Order No.", rec."Transfer Order No.");

                    if not TransferShipmentHdr.FindFirst() then
                        Error('No posted shipment found for Transfer Order No. %1.', rec."Transfer Order No.");

                    Page.RunModal(Page::"Posted Transfer Shipment", TransferShipmentHdr);

                end;
            }
            action("Show Posted Receipt")
            {
                ApplicationArea = All;
                Caption = 'Show Posted Receipt';
                ToolTip = 'Open the posted receipt associated with this transfer order.';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = rec."Transfer Order No." <> '';

                trigger OnAction()
                var
                    TransferReceiptHdr: Record "Transfer Receipt Header";
                begin
                    TransferReceiptHdr.Reset();
                    TransferReceiptHdr.SetRange("Transfer Order No.", rec."Transfer Order No.");

                    if not TransferReceiptHdr.FindFirst() then
                        Error('No posted receipt found for Transfer Order No. %1.', rec."Transfer Order No.");

                    Page.RunModal(Page::"Posted Transfer Receipt", TransferReceiptHdr);
                end;
            }




            action("Reopen")
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = ReopenEnabled;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to reopen this completed charging sheet?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    rec."Status" := rec."Status"::InProgress;
                    rec."Completed By" := '';
                    rec."Completion Date" := 0DT;
                    rec.Modify(true);

                    SetStatusStyle();

                    Message('The charging document has been reopened for editing.');
                end;
            }

            action("Cancel Charging")
            {
                ApplicationArea = All;
                Caption = 'Cancel Charging';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = CancelEnabled;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to cancel the charging process?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    rec."Status" := rec."Status"::Cancelled;
                    rec.Modify(true);
                    SetStatusStyle();
                    Message('Charging process has been cancelled.');
                end;
            }

            // action("Generate Lines From Loading Sheet")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Generate Lines From Loading Sheet';
            //     Image = CreateLinesFromJob;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     Enabled = not IsReleased;

            //     trigger OnAction()
            //     begin
            //         if rec."Loading Sheet No." = '' then begin
            //             Error('Please select a loading sheet first.');
            //             exit;
            //         end;

            //         GenerateChargingLines();
            //     end;
            // }

            action("View Loading Sheet")
            {
                ApplicationArea = All;
                Caption = 'View Loading Sheet';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    VLoadingHeader: Record "Vehicle Loading Header";
                    VLoadingCard: Page "Vehicle Loading Card";
                begin
                    if rec."Loading Sheet No." = '' then begin
                        Message('No loading sheet is associated with this charging sheet.');
                        exit;
                    end;

                    if VLoadingHeader.Get(rec."Loading Sheet No.") then begin
                        VLoadingCard.SetRecord(VLoadingHeader);
                        VLoadingCard.Run();
                    end else
                        Message('Loading sheet %1 was not found.', rec."Loading Sheet No.");
                end;
            }

            action("Go to Execution")
            {
                ApplicationArea = All;
                Caption = 'Go to Execution';
                Image = Next;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = (Rec.Status = Rec.Status::Completed);

                trigger OnAction()
                var
                    TourExecutionMgt: Codeunit "Tour Execution Management";
                begin
                    if Rec.Status <> Rec.Status::Completed then begin
                        Message('The charging document must be completed before proceeding to execution.');
                        exit;
                    end;

                    // Initialize tour execution
                    TourExecutionMgt.InitializeTourExecution(Rec."Tour No.");
                end;
            }
            action("view Transfer Order to the Vehicle ")
            {
                ApplicationArea = All;
                Caption = 'View Transfer Order';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = rec."Transfer Order No." <> '';


                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                    TransferCard: Page "Transfer Order";
                begin
                    if not TransferHeader.Get(rec."Transfer Order No.") then begin
                        Error('Transfer order %1 not found.', rec."Transfer Order No.");
                        exit;
                    end;

                    Page.RunModal(Page::"Transfer order", TransferHeader);
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        // Use Released field from the record
        IsReleased := Rec."Released";
        SetStatusStyle();
        SetActionEnabledStates();
    end;

    trigger OnOpenPage()
    begin
        // Use Released field from the record
        IsReleased := Rec."Released";
        SetStatusStyle();
        SetActionEnabledStates();
    end;

    procedure SetRecord(var ChargingRec: Record "Vehicle Charging Header")
    begin
        Rec := ChargingRec;
        IsReleased := true; // Vehicle Charging starts in InProgress state
    end;

    procedure GenerateChargingLines()
    var
        StopLine: Record "vehicle Stop Line";
        ChargingLine: Record "Vehicle Charging Line";
        LineNo: Integer;
    begin
        // Clear existing charging lines for this charging sheet
        ChargingLine.Reset();
        ChargingLine.SetRange("Charging No.", Rec."Vehicle Charging No.");
        if ChargingLine.FindSet() then
            ChargingLine.DeleteAll();

        // Get stop lines from the loading sheet
        StopLine.Reset();
        StopLine.SetRange("Fiche No.", Rec."Loading Sheet No.");
        StopLine.SetCurrentKey("Stop No.");

        LineNo := 0;
        if StopLine.FindSet() then begin
            repeat
                LineNo += 1;
                ChargingLine.Init();
                ChargingLine."Charging No." := Rec."Vehicle Charging No.";
                ChargingLine."Line No." := LineNo;
                ChargingLine."Stop No." := StopLine."Stop No.";
                ChargingLine."Customer No." := StopLine."Customer No.";
                ChargingLine."Delivery Address" := StopLine."Delivery Address";
                ChargingLine."prepapred Quantity" := StopLine."Quantity to prepare"; // Use the correct field for planned quantity
                ChargingLine."Actual Quantity" := 0; // Initialize to 0, will be filled during charging
                ChargingLine."Quantity Difference" := StopLine."Quantity to prepare"; // Initially, difference is negative (not loaded)
                ChargingLine."Loading Status" := ChargingLine."Loading Status"::Pending;
                ChargingLine."Remarks" := StopLine.Remarks;

                // Add the item information
                ChargingLine."Item No." := StopLine.item;
                ChargingLine."Description" := StopLine.Description;
                ChargingLine."Unit of Measure Code" := StopLine."unit of measure code";
                ChargingLine."Document Type" := StopLine.type;

                // Initialize Purchased Quantity to 0 for Purchase document type
                if StopLine.type = StopLine.type::Purchase then
                    ChargingLine."prepapred Quantity" := StopLine."Quantity to deliver";

                ChargingLine.Insert(true);
            until StopLine.Next() = 0;
            Message('Generated %1 charging lines from the loading sheet.', LineNo);
        end else
            Message('No stop lines found in the loading sheet.');
    end;

    procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::InProgress:
                if Rec."Start Time" = 0T then
                    StatusStyleExpr := 'Ambiguous'
                else
                    StatusStyleExpr := 'StrongAccent';
            Rec.Status::Completed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;

    local procedure SetActionEnabledStates()
    begin
        StartChargingEnabled := IsReleased and (Rec.Status = Rec.Status::InProgress) and (Rec."Start Time" = 0T);
        CompleteChargingEnabled := IsReleased and (Rec.Status = Rec.Status::InProgress) and (Rec."Start Time" <> 0T);
        ReleaseEnabled := not IsReleased and (Rec."Loading Sheet No." <> '');
        ReopenEnabled := (Rec.Status = Rec.Status::Completed);
        CancelEnabled := (Rec.Status = Rec.Status::InProgress);
    end;

    var
        IsReleased: Boolean;
        StatusStyleExpr: Text;
        StartChargingEnabled: Boolean;
        CompleteChargingEnabled: Boolean;
        ReleaseEnabled: Boolean;
        ReopenEnabled: Boolean;
        CancelEnabled: Boolean;
}