page 73517 "Trip Setup"
{
    ApplicationArea = All;
    Caption = 'Trip Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Trip Setup";
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

            }
            group("Number Series")
            {
                Caption = 'Number Series';
                field(Tournee; Rec."Logistic Tour Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifice the Planned Tour Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                    Style = Strong;
                }
                field(Loading; Rec."Loading Sheet No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifique the Loading Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                    Style = Strong;
                }
                field(Charing; Rec."Vehicle Charging No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Spécifique the Itinerary Numbers that will be assigned for each saving';
                    TableRelation = "No. Series";
                    Style = Strong;

                }
            }

            group("Logistics Cutoff")
            {
                Caption = 'Logistics Cutoff';


                field("Logistics Cutoff Time"; Rec."Logistics Cutoff Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cutoff time for logistics operations. Documents before this time will be included in the filter.';
                    ShowMandatory = true;
                    Importance = Promoted;
                    StyleExpr = 'Favorable';
                    AssistEdit = true;
                    Caption = 'Logistics Cutoff Time (click ... to select)';

                    trigger OnAssistEdit()
                    var
                        TimeSelection: Time;
                        SelectionMade: Boolean;
                        Hour: Integer;
                        Minute: Integer;
                        CurrentTime: Time;
                        TimeOptions: Text;
                        TimeList: List of [Time];
                        SelectedOption: Integer;
                    begin
                        // Create time options at 15-minute intervals
                        for Hour := 0 to 23 do begin
                            for Minute := 0 to 45 do begin
                                if Minute mod 15 = 0 then begin
                                    CurrentTime := 010000T + (Hour * 3600000) + (Minute * 60000);
                                    TimeList.Add(CurrentTime);
                                    if TimeOptions <> '' then
                                        TimeOptions += ',';
                                    TimeOptions += Format(CurrentTime);
                                end;
                            end;
                        end;

                        // Add current time option
                        TimeOptions += ',Current Time';

                        // Show selection dialog
                        SelectedOption := Dialog.StrMenu(TimeOptions, 0, 'Select Time');

                        if SelectedOption > 0 then begin
                            if SelectedOption <= TimeList.Count then
                                TimeSelection := TimeList.Get(SelectedOption)
                            else
                                TimeSelection := DT2Time(CurrentDateTime());

                            Rec."Logistics Cutoff Time" := TimeSelection;
                            Rec.Modify();
                            CurrPage.Update(true);
                        end;
                    end;
                }
            }

            group("Default Locations")
            {
                Caption = 'Default Locations';

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code for the trip.';
                    Importance = Promoted;
                    ShowMandatory = true;
                }

                field("Default Start Location"; Rec."Default Start Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default start location for new tours.';
                    Importance = Standard;

                    trigger OnValidate()
                    begin
                        if Rec."Default Start Location" = '' then
                            Rec."Default Start Location" := Rec."Location Code";
                    end;
                }

                field("Default End Location"; Rec."Default End Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default end location for new tours.';
                    Importance = Standard;

                    trigger OnValidate()
                    begin
                        if Rec."Default End Location" = '' then
                            Rec."Default End Location" := Rec."Location Code";
                    end;
                }
            }

            group(VehicleasLocation)
            {
                Caption = 'List of Vehicles that are used as Locations';

                part(VehicleLocations; "Tal Vehicule Resource list")
                {
                    ApplicationArea = All;
                    SubPageLink = Type = CONST(Machine), "Used as Location" = CONST(true);
                }
            }
        }
    }

    actions
    {
        // area(Processing)
        // {
        //     action(ActionName)
        //     {

        //         trigger OnAction()
        //         begin

        //         end;
        //     }
        // }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Insert();
        end;
    end;
}