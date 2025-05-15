page 77013 "Planning Optimization"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Planning Lines";
    SourceTableTemporary = true;
    Caption = 'Planning Optimization Suggestions';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(TourInfo)
            {
                Caption = 'Tour Information';
                field(TourNo; TourNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Tour No.';
                    Editable = false;
                    ToolTip = 'Specifies the tour number';
                    Style = StrongAccent;
                }
                field(SuggestCount; Format(SuggestionCount) + ' suggestions')
                {
                    ApplicationArea = All;
                    Caption = 'Suggestions';
                    Editable = false;
                    ToolTip = 'Indicates the number of optimization suggestions';
                    Style = Attention;
                }
            }

            repeater(SuggestionLines)
            {
                Caption = 'Suggested Changes';

                field(ApplyChange; Rec."Selected")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to apply this suggestion';
                    Caption = 'Apply';
                }

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the line number in the planning';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the item number';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the item description';
                }

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the customer number';
                }

                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the vendor number';
                }

                field("Current Day"; OriginalAssignedDay[Rec."Line No."])
                {
                    ApplicationArea = All;
                    Caption = 'Current Day';
                    Editable = false;
                    ToolTip = 'Specifies the current assigned day';
                    Style = Unfavorable;
                }

                field("Assigned Day"; Rec."Assigned Day")
                {
                    ApplicationArea = All;
                    Caption = 'Suggested Day';
                    Editable = false;
                    ToolTip = 'Specifies the suggested day';
                    Style = Favorable;
                }

                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Caption = 'Optimization Reason';
                    Editable = false;
                    ToolTip = 'Specifies the reason for the suggested optimization';
                }

                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the priority of the planning line';
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the location code';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectAll)
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Selects all suggestions for application';

                trigger OnAction()
                begin
                    SetSelectionForAll(true);
                end;
            }

            action(UnselectAll)
            {
                ApplicationArea = All;
                Caption = 'Unselect All';
                Image = CancelLine;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Unselects all suggestions';

                trigger OnAction()
                begin
                    SetSelectionForAll(false);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SelectedCount: Integer;
    begin
        if CloseAction = Action::OK then begin
            // Count selected suggestions
            SelectedCount := CountSelectedSuggestions();

            if SelectedCount = 0 then begin
                if not Confirm('Aucune suggestion n''est sélectionnée. Voulez-vous fermer sans appliquer de changements?', true) then
                    exit(false);
            end
            else begin
                if not Confirm('Appliquer %1 changements sélectionnés aux lignes de planification?', true, SelectedCount) then
                    exit(false);
            end;
        end;

        exit(true);
    end;

    var
        TourNumber: Code[20];
        SuggestionCount: Integer;
        OriginalAssignedDay: array[1000000] of Date;

    procedure SetSuggestions(var TempSuggestions: Record "Planning Lines" temporary; TourNo: Code[20]): Boolean
    begin
        TourNumber := TourNo;
        SuggestionCount := 0;

        // Copy suggestions to this page's temporary table
        if TempSuggestions.FindSet() then
            repeat
                Rec.Init();
                Rec.TransferFields(TempSuggestions);

                // Set Selected field to true by default
                Rec."Selected" := true;

                // Store original day in array for display
                OriginalAssignedDay[TempSuggestions."Line No."] := GetOriginalDay(TourNo, TempSuggestions."Line No.");

                if Rec.Insert() then
                    SuggestionCount += 1;
            until TempSuggestions.Next() = 0;

        exit(SuggestionCount > 0);
    end;

    local procedure GetOriginalDay(TourNo: Code[20]; LineNo: Integer): Date
    var
        PlanningLine: Record "Planning Lines";
    begin
        if PlanningLine.Get(TourNo, LineNo) then
            exit(PlanningLine."Assigned Day");

        exit(0D);
    end;

    local procedure SetSelectionForAll(Select: Boolean)
    begin
        if Rec.FindSet() then
            repeat
                Rec."Selected" := Select;
                Rec.Modify();
            until Rec.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure CountSelectedSuggestions(): Integer
    var
        Count: Integer;
    begin
        Count := 0;

        if Rec.FindSet() then
            repeat
                if Rec."Selected" then
                    Count += 1;
            until Rec.Next() = 0;

        exit(Count);
    end;

    procedure GetSelectedSuggestions(var TempSelectedLines: Record "Planning Lines" temporary)
    begin
        // Get the records where Selected = true
        if Rec.FindSet() then
            repeat
                if Rec."Selected" then begin
                    TempSelectedLines.Init();
                    TempSelectedLines.TransferFields(Rec);
                    TempSelectedLines.Insert();
                end;
            until Rec.Next() = 0;
    end;
}