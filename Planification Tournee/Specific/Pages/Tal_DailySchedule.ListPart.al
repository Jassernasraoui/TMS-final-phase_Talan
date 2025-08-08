page 73614 "Daily Schedule ListPart"
{
    PageType = ListPart;
    SourceTable = "Planning Lines";
    Caption = 'Daily Schedule';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(FilterOptions)
            {
                Caption = 'View Options';

                field(DayFilterField; DayFilter)
                {
                    ApplicationArea = All;
                    Caption = 'View Day';
                    ToolTip = 'Specifies which day to view in the schedule.';

                    trigger OnValidate()
                    begin
                        ApplyDayFilter();
                    end;
                }
                field(ShowMap; ShowMapLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                    StyleExpr = true;
                    ToolTip = 'Specifies the customer''s address on your preferred map website.';

                    trigger OnDrillDown()
                    var
                        Address: Text;
                        EncodedAddress: Text;
                        URL: Text;
                    begin
                        CurrPage.Update(true);
                        Address := Rec.GetFullAddress();
                        EncodedAddress := EncodeUrl(Address); // on crée cette fonction juste après
                        URL := 'https://www.google.com/maps/search/?api=1&query=' + 'EncodedAddress';
                        HYPERLINK(URL);
                    end;
                }

            }
            repeater(DailySchedule)
            {
                Caption = 'Schedule Items';

                field("Time Slot Start"; Rec."Time Slot Start")
                {
                    ApplicationArea = All;
                    StyleExpr = TimeSlotStyle;
                }

                field("Time Slot End"; Rec."Time Slot End")
                {
                    ApplicationArea = All;
                    StyleExpr = TimeSlotStyle;
                }

                field("Activity Type"; Rec."Activity Type")
                {
                    ApplicationArea = All;
                    StyleExpr = TimeSlotStyle;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    StyleExpr = TimeSlotStyle;
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }

                field("Estimated Duration"; Rec."Estimated Duration")
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleExpr;
                    Visible = false;
                }

                field("Priority"; Rec."Priority")
                {
                    ApplicationArea = All;
                    StyleExpr = PriorityStyleExpr;
                }
            }
        }
    }

    actions
    {
        area(Prompting)
        {
            action("Calender View")
            {
                ApplicationArea = All;
                Caption = 'Calendar View';
                Image = SparkleFilled;
                ToolTip = 'View the schedule in a calendar format.';

                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Tal Simple Calendar Page", Rec);
                end;
            }
        }
        area(Processing)
        {
            action(PreviousDay)
            {
                ApplicationArea = All;
                Caption = 'Previous Day';
                Image = PreviousRecord;
                ToolTip = 'View the schedule for the previous day.';

                trigger OnAction()
                begin
                    DayFilter := CalcDate('<-1D>', DayFilter);
                    ApplyDayFilter();
                end;
            }

            action(NextDay)
            {
                ApplicationArea = All;
                Caption = 'Next Day';
                Image = NextRecord;
                ToolTip = 'View the schedule for the next day.';

                trigger OnAction()
                begin
                    DayFilter := CalcDate('<+1D>', DayFilter);
                    ApplyDayFilter();
                end;
            }

            action(Today)
            {
                ApplicationArea = All;
                Caption = 'Today';
                Image = Today;
                ToolTip = 'View the schedule for today.';

                trigger OnAction()
                begin
                    DayFilter := Today;
                    ApplyDayFilter();
                end;
            }
        }
    }

    var
        ShowMapLbl: Label 'Show on Map';
        DayFilter: Date;
        TimeSlotStyle: Text;
        StatusStyleExpr: Text;
        PriorityStyleExpr: Text;

    trigger OnOpenPage()
    begin
        if DayFilter = 0D then
            DayFilter := Today;

        ApplyDayFilter();
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyles();
    end;

    local procedure ApplyDayFilter()
    begin
        Rec.SetRange("Assigned Day", DayFilter);
        CurrPage.Update(false);
    end;

    local procedure SetStyles()
    begin
        // Set time slot style based on overlap or conflict
        TimeSlotStyle := 'Standard';

        // Set status style
        case Rec.Status of
            Rec.Status::Open:
                StatusStyleExpr := 'Standard';
            Rec.Status::Released:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Completed:
                StatusStyleExpr := 'Subordinate';
        end;

        // Set priority style
        case Rec.Priority of
            Rec.Priority::Low:
                PriorityStyleExpr := 'Subordinate';
            Rec.Priority::Normal:
                PriorityStyleExpr := 'Standard';
            Rec.Priority::High:
                PriorityStyleExpr := 'Attention';
            Rec.Priority::Critical:
                PriorityStyleExpr := 'Unfavorable';
        end;
    end;

    procedure EncodeUrl(Address: Text): Text
    var
        TempText: Text;
    begin
        TempText := Address;
        TempText := DelChr(TempText, '=', ' '); // Supprime les espaces
        TempText := ReplaceStr(TempText, ' ', '+');
        exit(TempText);
    end;

    procedure ReplaceStr(Source: Text; OldValue: Text; NewValue: Text): Text
    var
        Pos: Integer;
    begin
        while true do begin
            Pos := StrPos(Source, OldValue);
            if Pos = 0 then
                exit(Source);
            Source := CopyStr(Source, 1, Pos - 1) + NewValue + CopyStr(Source, Pos + StrLen(OldValue));
        end;
    end;

}