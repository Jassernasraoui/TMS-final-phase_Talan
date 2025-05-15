page 77016 TripScedulingCuePage
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
                    DrillDownPageId = "Tour Planification List";
                }
                field(OnMissionTripCue; Rec.TripScedulingOnMission)
                {
                    Caption = 'On Mission';
                    DrillDownPageId = "Tour Planification List";
                }
                field(StoppedTripCue; Rec.TripScedulingStopped)
                {
                    Caption = 'Stopped';
                    DrillDownPageId = "Tour Planification List";
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