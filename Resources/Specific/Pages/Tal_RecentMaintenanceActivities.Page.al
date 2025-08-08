page 73560 "Recent Maintenance Activities"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Vehicle Maintenance";
    Caption = 'Recent Maintenance Activities';
    Editable = false;

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
                    Visible = false;
                }
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the vehicle.';
                }
                field(VehicleName; VehicleName)
                {
                    ApplicationArea = All;
                    Caption = 'Vehicle Name';
                    ToolTip = 'Specifies the name of the vehicle.';
                }
                field("Maintenance Type"; Rec."Maintenance Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of maintenance.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the maintenance.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the maintenance.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Maintenance Date"; Rec."Maintenance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the maintenance was recorded.';
                }
                field("Completion Date"; Rec."Completion Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the maintenance was completed.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost amount of the maintenance.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("View Maintenance Card")
            {
                ApplicationArea = All;
                Caption = 'View Maintenance Card';
                Image = Card;
                ToolTip = 'View the maintenance card.';
                RunObject = page "Vehicle Maintenance Card";
                RunPageLink = "Entry No." = field("Entry No.");
            }
            action("View Vehicle Card")
            {
                ApplicationArea = All;
                Caption = 'View Vehicle Card';
                Image = Card;
                ToolTip = 'View the vehicle card.';
                RunObject = page " Tal Vehicule resources card ";
                RunPageLink = "No." = field("Vehicle No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    trigger OnAfterGetRecord()
    var
        Resource: Record Resource;
    begin
        // Get vehicle name
        VehicleName := '';
        if Resource.Get(Rec."Vehicle No.") then
            VehicleName := Resource.Name;

        // Set status style
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
                StatusStyleExpr := 'Subordinate';
        end;
    end;

    var
        VehicleName: Text[100];
        StatusStyleExpr: Text;
        VehicleFilter: Code[20];

    procedure SetVehicleFilter(VehicleNo: Code[20])
    begin
        VehicleFilter := VehicleNo;
        ApplyFilters();
    end;

    local procedure ApplyFilters()
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Maintenance Date");
        Rec.SetAscending("Maintenance Date", false); // Most recent first
        Rec.SetFilter("Maintenance Date", '>=%1', CalcDate('<-30D>', WorkDate())); // Last 30 days
        Rec.SetRange(Status, Rec.Status::Completed);

        if VehicleFilter <> '' then
            Rec.SetRange("Vehicle No.", VehicleFilter);

        CurrPage.Update(false);
    end;
}