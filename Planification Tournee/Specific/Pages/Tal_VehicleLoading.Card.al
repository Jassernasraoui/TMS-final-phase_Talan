page 50130 "Vehicle Loading Card"
{
    PageType = Card;
    SourceTable = "vehicle Loading Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("General")
            {
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Loading Date"; rec."Loading Date")
                {
                    ApplicationArea = All;

                }
                field("Tour No."; rec."Tour No.")
                {
                    ApplicationArea = All;

                }
                field("Truck No."; rec."Truck No.")
                {
                    ApplicationArea = All;

                }
                field("Driver No."; rec."Driver No.")
                {
                    ApplicationArea = All;

                }
                field("Loading Location"; rec."Loading Location")
                {
                    ApplicationArea = All;

                }
            }

            group("Timing")
            {
                field("Departure Time"; rec."Departure Time") { }
                field("Arrival Time"; rec."Arrival Time") { }
                field("Validation Date"; rec."Validation Date") { }
            }

            group("Load Info")
            {
                field("Total Weight (kg)"; rec."Total Weight (kg)") { }
                field("Total Volume (m³)"; rec."Total Volume (m³)") { }
                field("Number of Deliveries"; rec."Number of Deliveries") { }
                field("Goods Type"; rec."Goods Type") { }
            }

            group("Itinerary")
            {
                field("Itinerary No."; rec."Itinerary No.") { }
                field("Total Distance (km)"; rec."Total Distance (km)") { }
                field("Estimated Duration"; rec."Estimated Duration") { }
                field("Itinerary Type"; rec."Itinerary Type") { }
                field("Planned Route"; rec."Planned Route") { }
            }

            group("Statuts")
            {
                field("Status"; rec."Status") { }
                field("Validated By"; rec."Validated By") { }
            }

            part("StopsPart"; "vehicle Stop List")
            {
                SubPageLink = "Fiche No." = FIELD("No.");
                ApplicationArea = All;
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

            action("Validate Loading")
            {
                ApplicationArea = All;
                Caption = 'Validate Loading';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ConfirmMsg: Label 'Are you sure you want to validate this loading sheet?';
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    if rec."Status" = rec."Status"::Validated then begin
                        Message('This loading sheet is already validated.');
                        exit;
                    end;

                    rec."Status" := rec."Status"::Loading;
                    rec."Validated By" := UserId;
                    rec."Validation Date" := CurrentDateTime;
                    rec.Modify(true);
                    Message('Loading sheet has been validated and is now in Loading status.');
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
        }
    }

    procedure SetRecord(var LoadingRec: Record "Vehicle Loading Header")
    begin
        Rec := LoadingRec;
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
}
