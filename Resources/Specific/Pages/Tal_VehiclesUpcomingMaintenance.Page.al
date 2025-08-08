page 73588 "Vehicles Upcoming Maintenance"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = Resource;
    SourceTableView = where(Type = const(Machine));
    Caption = 'Vehicles With Upcoming Maintenance';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the vehicle.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the vehicle.';
                }
                field("License plate No."; Rec." License plate No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the license plate number of the vehicle.';
                }
                field("Last Maintenance Date"; Rec."Last Maintenance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the vehicle was last maintained.';
                }
                field("Next Maintenance Date"; Rec."Next Maintenance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the vehicle is due for maintenance.';
                    StyleExpr = 'Attention';
                }
                field(DaysUntilMaintenance; DaysUntilMaintenance)
                {
                    ApplicationArea = All;
                    Caption = 'Days Until Maintenance';
                    ToolTip = 'Specifies the number of days until the next scheduled maintenance.';
                    StyleExpr = 'Attention';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Schedule Maintenance")
            {
                ApplicationArea = All;
                Caption = 'Schedule Maintenance';
                Image = NewDocument;
                ToolTip = 'Schedule maintenance for this vehicle.';

                trigger OnAction()
                var
                    VehicleMaintenance: Record "Vehicle Maintenance";
                    VehicleMaintenanceCard: Page "Vehicle Maintenance Card";
                begin
                    VehicleMaintenance.Init();
                    VehicleMaintenance.Validate("Vehicle No.", Rec."No.");
                    VehicleMaintenance.Validate("Maintenance Type", VehicleMaintenance."Maintenance Type"::"Regular Service");
                    VehicleMaintenance.Validate(Description, 'Scheduled Maintenance');
                    VehicleMaintenance.Validate(Status, VehicleMaintenance.Status::Planned);
                    VehicleMaintenance.Validate("Scheduled Date", Rec."Next Maintenance Date");
                    VehicleMaintenance.Insert(true);

                    Commit();
                    Clear(VehicleMaintenanceCard);
                    VehicleMaintenanceCard.SetRecord(VehicleMaintenance);
                    VehicleMaintenanceCard.Run();
                end;
            }
            action("View Vehicle Card")
            {
                ApplicationArea = All;
                Caption = 'View Vehicle Card';
                Image = Card;
                ToolTip = 'View the vehicle card.';
                RunObject = page " Tal Vehicule resources card ";
                RunPageLink = "No." = field("No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        ApplyFilters();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Next Maintenance Date" <> 0D then
            DaysUntilMaintenance := Rec."Next Maintenance Date" - WorkDate()
        else
            DaysUntilMaintenance := 0;
    end;

    var
        DaysUntilMaintenance: Integer;
        VehicleFilter: Code[20];

    procedure SetVehicleFilter(VehicleNo: Code[20])
    begin
        VehicleFilter := VehicleNo;
        ApplyFilters();
    end;

    local procedure ApplyFilters()
    begin
        Rec.Reset();
        Rec.SetRange(Type, Rec.Type::Machine);
        Rec.SetFilter("Next Maintenance Date", '%1..%2', WorkDate(), CalcDate('<+7D>', WorkDate()));

        if VehicleFilter <> '' then
            Rec.SetRange("No.", VehicleFilter);

        CurrPage.Update(false);
    end;
}