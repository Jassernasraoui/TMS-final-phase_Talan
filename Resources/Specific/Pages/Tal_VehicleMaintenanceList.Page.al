page 73653 "Vehicle Maintenance List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Vehicle Maintenance";
    CardPageId = "Vehicle Maintenance Card";
    Editable = false;
    Caption = 'Vehicle Maintenance List';
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the maintenance record.';
                }
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vehicle number for this maintenance record.';
                }
                field("Maintenance Type"; Rec."Maintenance Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of maintenance performed.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the maintenance.';
                }
                field("Maintenance Date"; Rec."Maintenance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the maintenance was performed.';
                }
                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the maintenance is scheduled.';
                }
                field("Completion Date"; Rec."Completion Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the maintenance was completed.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the maintenance record.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Service Provider"; Rec."Service Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service provider who performed the maintenance.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost of the maintenance.';
                }
                field("Odometer Reading"; Rec."Odometer Reading")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the odometer reading at the time of maintenance.';
                }
                field("Next Service Due"; Rec."Next Service Due")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the next service is due.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action("New Maintenance")
            {
                ApplicationArea = All;
                Caption = 'New Maintenance';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create a new maintenance record.';
                RunObject = page "Vehicle Maintenance Card";
                RunPageMode = Create;
            }
        }
        area(Navigation)
        {
            action("Vehicle Card")
            {
                ApplicationArea = All;
                Caption = 'Vehicle Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the vehicle card.';
                RunObject = page " Tal Vehicule resources card ";
                RunPageLink = "No." = field("Vehicle No.");
            }
        }
    }
    
    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;
    
    var
        StatusStyleExpr: Text;
        
    local procedure SetStatusStyle()
    begin
        StatusStyleExpr := '';
        case Rec.Status of
            Rec.Status::Planned:
                StatusStyleExpr := 'Standard';
            Rec.Status::Scheduled:
                StatusStyleExpr := 'Attention';
            Rec.Status::"In Progress":
                StatusStyleExpr := 'Ambiguous';
            Rec.Status::Completed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;
}