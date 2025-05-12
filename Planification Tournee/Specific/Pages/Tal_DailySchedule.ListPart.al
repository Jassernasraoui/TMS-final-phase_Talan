page 50150 "Daily Schedule ListPart"
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
}