page 77005 "Tour Planning List"
{
    PageType = List;
    SourceTable = "Planification Header";
    ApplicationArea = All;
    Caption = 'Tour Planning List';
    CardPageId = "Planification Document"; // Links to the provided card page
    UsageCategory = Lists;
    Editable = false; // List page is typically read-only
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';

                field("Logistic Tour No."; Rec."Logistic Tour No.")
                {
                    ApplicationArea = All;
                    Caption = 'Tour No.';
                    ToolTip = 'Specifies the unique identifier for this tour.';
                }
                field("Statut"; Rec.Statut)
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays the current status of the tour.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date';
                    ToolTip = 'Specifies the date when the document was created.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date of the planning interval.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date of the planning interval.';
                }
                field("Driver No."; Rec."Driver No.")
                {
                    ApplicationArea = All;
                    Caption = 'Driver/Technician';
                    ToolTip = 'Specifies the driver or technician assigned to this tour.';
                }
                field("Véhicule No."; Rec."Véhicule No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vehicle';
                    ToolTip = 'Specifies the vehicle assigned to this tour.';
                }
                field("Delivery Area"; Rec."Delivery Area")
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Area';
                    ToolTip = 'Specifies the geographic area for deliveries.';
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    ToolTip = 'Specifies the total quantity of all planning lines.';
                }
                field("Estimated Total Weight"; Rec."Estimated Total Weight")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Total Weight (kg)';
                    ToolTip = 'Shows the estimated total weight for all items in this tour.';
                }
                field("Estimated Distance"; Rec."Estimated Distance")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Distance (km)';
                    ToolTip = 'Shows the estimated total distance for this tour.';
                }
                field("Estimated Duration"; Rec."Estimated Duration")
                {
                    ApplicationArea = All;
                    Caption = 'Estimated Duration (hrs)';
                    ToolTip = 'Shows the estimated total duration for this tour.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    ToolTip = 'Specifies the user that created this tour.';
                }
            }
        }
        area(factboxes)
        {
            part("Tour Statistics"; "Tour Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Tour Statistics';
                ToolTip = 'Displays statistics related to the tour.';
                SubPageLink = "Logistic Tour No." = field("Logistic Tour No.");
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ObsoleteTag = '25.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'The "Document Attachment FactBox" has been replaced by "Doc. Attachment List Factbox", which supports multiple files upload.';
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Planification Header"), "No." = field("No.");
            }
            systempart(Control1900383207; Notes)
            {
                ApplicationArea = Notes;
            }
            systempart(Control1905767507; Links)
            {
                ApplicationArea = RecordLinks;
            }

        }
    }

    actions
    {
        area(Navigation)
        {
            action("Open Card")
            {
                ApplicationArea = All;
                Caption = 'Open Tour Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the detailed tour planning card for this record.';

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Planification Document", Rec);
                end;
            }
            action("Vehicle Loading Management")
            {
                ApplicationArea = All;
                Caption = 'Vehicle Loading Management';
                Image = ProductionPlan;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Vehicle Loading Management";
                ToolTip = 'View and manage both loading preparation and vehicle charging operations.';
            }
            action("Transfer Routes")
            {
                ApplicationArea = Location;
                Caption = 'Transfer Routes';
                Image = Setup;
                RunObject = Page "Transfer Routes";
                ToolTip = 'View the list of transfer routes that are set up to transfer items from one location to another.';
            }
            action(ViewDashboard)
            {
                ApplicationArea = All;
                Caption = '🗺️ Vue Dashboard';
                ToolTip = 'Ouvrir le dashboard avec carte et calendrier';
                Image = Map;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PlanningDashboard: Page "Tal Planning Dashboard";
                    PlanningLine: Record "Planning Lines";
                begin
                    // Filtrer les lignes de planning pour cette tournée
                    PlanningLine.Reset();
                    PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");

                    if PlanningLine.FindFirst() then begin
                        // Ouvrir le dashboard en passant la ligne de planning
                        PlanningDashboard.SetRecord(PlanningLine);
                        PlanningDashboard.Run();
                    end else begin
                        Message('Aucune ligne de planning trouvée pour cette tournée.');
                    end;
                end;
            }
        }
        area(Processing)
        {
            group("Planning Tools")
            {
                Caption = 'Planning Tools';
                Image = Planning;

                action("Auto-Assign Days")
                {
                    ApplicationArea = All;
                    Caption = 'Auto-Assign Days';
                    Image = Calendar;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Intelligently assigns planning lines to available tour days based on due dates, priorities, and location groupings.';

                    trigger OnAction()
                    var
                        PlanningLineMgt: Codeunit "Planning Lines Management";
                    begin
                        if Confirm('Run automatic day assignment for tour %1?', true, Rec."Logistic Tour No.") then begin
                            PlanningLineMgt.AutoAssignDays(Rec);
                            Message('Planning lines have been assigned to days.');
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action("Optimize Routes")
                {
                    ApplicationArea = All;
                    Caption = 'Optimize Routes';
                    Image = Route;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Optimizes daily routes to minimize travel time.';

                    trigger OnAction()
                    var
                        PlanningLineMgt: Codeunit "Planning Lines Management";
                    begin
                        if Confirm('Optimize routes for tour %1?', true, Rec."Logistic Tour No.") then begin
                            PlanningLineMgt.OptimizeRoutes(Rec);
                            Message('Routes have been optimized.');
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group("Diagnostics")
            {
                Caption = 'Diagnostics';
                Image = TestDatabase;

                action("Check Planning Completeness")
                {
                    ApplicationArea = All;
                    Caption = 'Check Planning Completeness';
                    Image = CheckList;
                    ToolTip = 'Checks if all lines have assigned days and proper planning.';

                    trigger OnAction()
                    var
                        PlanningLine: Record "Planning Lines";
                        NoAssignedDay: Integer;
                        NoActivity: Integer;
                        NoGrouped: Integer;
                        TotalLines: Integer;
                    begin
                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");
                        TotalLines := PlanningLine.Count;

                        if TotalLines = 0 then begin
                            Message('No planning lines found for tour %1.', Rec."Logistic Tour No.");
                            exit;
                        end;

                        PlanningLine.SetRange("Assigned Day", 0D);
                        NoAssignedDay := PlanningLine.Count;
                        PlanningLine.Reset();
                        PlanningLine.SetRange("Logistic Tour No.", Rec."Logistic Tour No.");

                        if PlanningLine.FindSet() then
                            repeat
                                if (PlanningLine."Activity Type" = 0) and (PlanningLine.Type <> PlanningLine.Type::Sales) then
                                    NoActivity += 1;
                            until PlanningLine.Next() = 0;

                        PlanningLine.SetRange("Group Type", PlanningLine."Group Type"::None);
                        NoGrouped := PlanningLine.Count;

                        Message('Planning completeness check for tour %1:\n' +
                                '%2 total planning lines\n' +
                                '%3 lines missing assigned day\n' +
                                '%4 lines with missing activity type\n' +
                                '%5 lines not grouped',
                                Rec."Logistic Tour No.", TotalLines, NoAssignedDay, NoActivity, NoGrouped);
                    end;
                }
            }
        }
    }

    var
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    trigger OnOpenPage()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Statut of
            Rec.Statut::Plannified:
                StatusStyleExpr := 'Favorable';
            Rec.Statut::Loading:
                StatusStyleExpr := 'Attention';
            Rec.Statut::Stopped:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;
}