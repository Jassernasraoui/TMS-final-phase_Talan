page 77012 "Vehicle Charging Card"
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
                    Editable = not IsReleased;

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
                Caption = 'Release';
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
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" <> rec."Status"::InProgress then begin
                        Error('Charging must be released before it can be started.');
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
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" <> rec."Status"::InProgress then begin
                        Error('Charging must be in progress to complete it.');
                        exit;
                    end;

                    // Check for required fields and valid lines before completion
                    rec.CheckRequiredFieldsAndLines();

                    rec."Status" := rec."Status"::Completed;
                    rec."End Time" := Time;
                    rec."Completed By" := UserId;
                    rec."Completion Date" := CurrentDateTime;
                    rec.Modify(true);
                    SetStatusStyle();
                    Message('Charging process has been completed.');
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

            action("Generate Lines From Loading Sheet")
            {
                ApplicationArea = All;
                Caption = 'Generate Lines From Loading Sheet';
                Image = CreateLinesFromJob;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = not IsReleased;

                trigger OnAction()
                begin
                    if rec."Loading Sheet No." = '' then begin
                        Error('Please select a loading sheet first.');
                        exit;
                    end;

                    GenerateChargingLines();
                end;
            }

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
                Visible = false;

                trigger OnAction()
                var
                    TourExecutionPage: Page "Tour Execution Page";
                    TourExecutionRec: Record "Tour Execution Tracking";
                begin
                    if rec.Status <> rec.Status::Completed then begin
                        Message('Charging phase must be completed before proceeding to execution.');
                        exit;
                    end;

                    // Optionally, filter the execution record to the current tour
                    TourExecutionRec.SetRange("Tour No.", rec."Tour No.");

                    // Open the execution page for this tour
                    PAGE.Run(PAGE::"Tour Execution Page", TourExecutionRec);
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
                ChargingLine."Planned Quantity" := StopLine."Quantity to Deliver";
                ChargingLine."Actual Quantity" := 0; // Initialize to 0, will be filled during charging
                ChargingLine."Quantity Difference" := -StopLine."Quantity to Deliver"; // Initially, difference is negative (not loaded)
                ChargingLine."Loading Status" := ChargingLine."Loading Status"::Pending;
                ChargingLine."Remarks" := StopLine.Remarks;
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