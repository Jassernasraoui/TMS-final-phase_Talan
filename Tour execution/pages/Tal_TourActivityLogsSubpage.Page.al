page 77056 "Tour Activity Logs Subpage"
{
    PageType = ListPart;
    SourceTable = "Tour Activity Log";
    Caption = 'Journal d''Activités';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(ActivityLogs)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Date-Time"; Rec."Activity Date")
                {
                    ApplicationArea = All;
                }

                field("Activity Description"; Rec."Activity Type")
                {
                    ApplicationArea = All;
                }



                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Activity Date");
        Rec.Ascending(false);
    end;
}