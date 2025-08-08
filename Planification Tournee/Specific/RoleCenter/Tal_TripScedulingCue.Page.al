page 73516 TripScedulingCuePage
{
    PageType = CardPart;
    SourceTable = TripScedulingCueTable;
    Caption = 'Sales Invoices Cues';
    ApplicationArea = all;
    layout
    {
        area(content)
        {
            cuegroup(TripCueContainer)
            {
                Caption = 'Trip Sceduling';
                // CuegroupLayout=Wide;
                field(PlannifiedTripCue; Rec.TripScedulingPlannified)
                {
                    Caption = 'Plannified';
                    DrillDownPageId = "Tour Planning List";
                }
                field(OnMissionTripCue; Rec.TripScedulingOnMission)
                {
                    Caption = 'Loading';
                    DrillDownPageId = "Tour Planning List";
                }
                field(StoppedTripCue; Rec.TripScedulingStopped)
                {
                    Caption = 'Stopped';
                    DrillDownPageId = "Tour Planning List";
                }
                field(TripScedulingCompleted; Rec.TripScedulingCompleted)
                {
                    Caption = 'Completed';
                    DrillDownPageId = "Tour Planning List";
                }

            }
            cuegroup(TripExecutionCueContainer)
            {
                Caption = 'Trip Execution';
                // CuegroupLayout=Wide;
                field(InProgressTripCue; Rec.TripExecutionInProgress)
                {
                    Caption = 'In Progress';
                    DrillDownPageId = "Tour Execution Tracking List";
                }
                field(CompletedTripCue; Rec.TripExecutionCompleted)
                {
                    Caption = 'Completed';
                    DrillDownPageId = "Tour Execution Tracking List";
                }
                field(DelayedTripCue; Rec.TripExecutionDelayed)
                {
                    Caption = 'Delayed';
                    DrillDownPageId = "Tour Execution Tracking List";
                }
                field(CancelledTripCue; Rec.TripExecutionCancelled)
                {
                    Caption = 'Cancelled';
                    DrillDownPageId = "Tour Execution Tracking List";
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}