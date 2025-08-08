page 73587 "Vehicle Maintenance Card"
{
    PageType = Card;
    SourceTable = "Vehicle Maintenance";
    Caption = 'Vehicle Maintenance Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the maintenance record.';
                    Editable = false;
                }
                field("Vehicle No."; Rec."Vehicle No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vehicle number for this maintenance record.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Resource: Record Resource;
                    begin
                        if Resource.Get(Rec."Vehicle No.") then
                            if Resource.Type <> Resource.Type::Machine then
                                Error('Selected resource is not a vehicle.');

                        if Rec."Odometer Reading" = 0 then
                            if Resource.Get(Rec."Vehicle No.") then
                                Rec.Validate("Odometer Reading", Resource."Current kilometres");
                    end;
                }
                field("Maintenance Type"; Rec."Maintenance Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of maintenance performed.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the maintenance.';
                    ShowMandatory = true;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the maintenance record.';
                    StyleExpr = StatusStyleExpr;
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Resource: Record Resource;
                    begin
                        if Rec.Status = Rec.Status::Completed then
                            if Rec."Completion Date" = 0D then
                                Rec."Completion Date" := WorkDate();

                        if Rec.Status = Rec.Status::"In Progress" then
                            if Rec."Maintenance Date" = 0D then
                                Rec."Maintenance Date" := WorkDate();

                        // Update vehicle status and maintenance dates
                        if Resource.Get(Rec."Vehicle No.") then begin
                            case Rec.Status of
                                Rec.Status::Planned, Rec.Status::Scheduled:
                                    ; // Do nothing
                                Rec.Status::"In Progress":
                                    Resource."Resource Status" := Resource."Resource Status"::InMaintenance;
                                Rec.Status::Completed:
                                    begin
                                        Resource."Resource Status" := Resource."Resource Status"::Available;
                                        Resource."Last Maintenance Date" := WorkDate();

                                        // Set next maintenance date based on maintenance type
                                        if Rec."Next Service Due" <> 0D then
                                            Resource."Next Maintenance Date" := Rec."Next Service Due"
                                        else begin
                                            case Rec."Maintenance Type" of
                                                Rec."Maintenance Type"::"Regular Service":
                                                    Resource."Next Maintenance Date" := CalcDate('<+3M>', WorkDate());
                                                Rec."Maintenance Type"::"Oil Change":
                                                    Resource."Next Maintenance Date" := CalcDate('<+6M>', WorkDate());
                                                Rec."Maintenance Type"::"Tire Replacement",
                                                Rec."Maintenance Type"::"Brake Service",
                                                Rec."Maintenance Type"::"Engine Repair",
                                                Rec."Maintenance Type"::"Transmission Service",
                                                Rec."Maintenance Type"::"Electrical System",
                                                Rec."Maintenance Type"::"Suspension Repair",
                                                Rec."Maintenance Type"::"Cooling System":
                                                    Resource."Next Maintenance Date" := CalcDate('<+1M>', WorkDate());
                                                Rec."Maintenance Type"::Inspection:
                                                    Resource."Next Maintenance Date" := CalcDate('<+12M>', WorkDate());
                                                else
                                                    Resource."Next Maintenance Date" := CalcDate('<+3M>', WorkDate());
                                            end;
                                        end;
                                    end;
                                Rec.Status::Cancelled:
                                    Resource."Resource Status" := Resource."Resource Status"::Available;
                            end;
                            Resource.Modify(true);
                        end;
                    end;
                }
            }
            group(Scheduling)
            {
                Caption = 'Scheduling';
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
                    Editable = Rec.Status = Rec.Status::Completed;
                }
            }
            group(Details)
            {
                Caption = 'Details';
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
                field("Next Service Odometer"; Rec."Next Service Odometer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the odometer reading when the next service is due.';
                }
            }
            group(Notess)
            {
                Caption = 'Notes';
                field(NotesField; Rec.Notes)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies additional notes about the maintenance.';
                    MultiLine = true;
                }
            }
        }
        area(FactBoxes)
        {
            part("Vehicle Details"; "Resource Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Vehicle No.");
            }
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
        area(Processing)
        {
            action("Mark as Completed")
            {
                ApplicationArea = All;
                Caption = 'Mark as Completed';
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Mark this maintenance record as completed.';
                Enabled = Rec.Status <> Rec.Status::Completed;

                trigger OnAction()
                begin
                    Rec.Validate(Status, Rec.Status::Completed);
                    Rec.Validate("Completion Date", WorkDate());
                    Rec.Modify(true);

                    // Refresh the page
                    CurrPage.Update(false);
                end;
            }
            action("Schedule Next Maintenance")
            {
                ApplicationArea = All;
                Caption = 'Schedule Next Maintenance';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new maintenance record based on this one.';
                Enabled = Rec.Status = Rec.Status::Completed;

                trigger OnAction()
                var
                    VehicleMaintenance: Record "Vehicle Maintenance";
                    VehicleMaintenanceCard: Page "Vehicle Maintenance Card";
                    Resource: Record Resource;
                    NextDate: Date;
                    NextOdometer: Decimal;
                    ConfirmMsg: Label 'Do you want to schedule the next maintenance for %1 on %2?';
                begin
                    // Determine next maintenance date
                    if Rec."Next Service Due" <> 0D then
                        NextDate := Rec."Next Service Due"
                    else begin
                        case Rec."Maintenance Type" of
                            Rec."Maintenance Type"::"Regular Service":
                                NextDate := CalcDate('<+3M>', WorkDate());
                            Rec."Maintenance Type"::"Oil Change":
                                NextDate := CalcDate('<+6M>', WorkDate());
                            Rec."Maintenance Type"::"Tire Replacement",
                            Rec."Maintenance Type"::"Brake Service",
                            Rec."Maintenance Type"::"Engine Repair",
                            Rec."Maintenance Type"::"Transmission Service",
                            Rec."Maintenance Type"::"Electrical System",
                            Rec."Maintenance Type"::"Suspension Repair",
                            Rec."Maintenance Type"::"Cooling System":
                                NextDate := CalcDate('<+1M>', WorkDate());
                            Rec."Maintenance Type"::Inspection:
                                NextDate := CalcDate('<+12M>', WorkDate());
                            else
                                NextDate := CalcDate('<+3M>', WorkDate());
                        end;
                    end;

                    // Determine next odometer reading
                    if Rec."Next Service Odometer" > 0 then
                        NextOdometer := Rec."Next Service Odometer"
                    else begin
                        // Get current odometer from vehicle
                        if Resource.Get(Rec."Vehicle No.") then begin
                            case Rec."Maintenance Type" of
                                Rec."Maintenance Type"::"Regular Service":
                                    NextOdometer := Resource."Current kilometres" + 5000;
                                Rec."Maintenance Type"::"Oil Change":
                                    NextOdometer := Resource."Current kilometres" + 10000;
                                Rec."Maintenance Type"::"Tire Replacement",
                                Rec."Maintenance Type"::"Brake Service",
                                Rec."Maintenance Type"::"Engine Repair",
                                Rec."Maintenance Type"::"Transmission Service",
                                Rec."Maintenance Type"::"Electrical System",
                                Rec."Maintenance Type"::"Suspension Repair",
                                Rec."Maintenance Type"::"Cooling System":
                                    NextOdometer := Resource."Current kilometres" + 2000;
                                Rec."Maintenance Type"::Inspection:
                                    NextOdometer := Resource."Current kilometres" + 20000;
                                else
                                    NextOdometer := Resource."Current kilometres" + 5000;
                            end;
                        end else
                            NextOdometer := Rec."Odometer Reading" + 5000;
                    end;

                    // Get vehicle name
                    if Resource.Get(Rec."Vehicle No.") then begin
                        if not Confirm(ConfirmMsg, true, Resource.Name, NextDate) then
                            exit;
                    end;

                    VehicleMaintenance.Init();
                    VehicleMaintenance.Validate("Vehicle No.", Rec."Vehicle No.");
                    VehicleMaintenance.Validate("Maintenance Type", Rec."Maintenance Type");
                    VehicleMaintenance.Validate(Description, Rec.Description);
                    VehicleMaintenance.Validate(Status, VehicleMaintenance.Status::Planned);
                    VehicleMaintenance.Validate("Scheduled Date", NextDate);
                    VehicleMaintenance.Validate("Odometer Reading", NextOdometer);
                    VehicleMaintenance.Insert(true);

                    Commit();
                    Clear(VehicleMaintenanceCard);
                    VehicleMaintenanceCard.SetRecord(VehicleMaintenance);
                    VehicleMaintenanceCard.Run();
                end;
            }
            action("Update Vehicle Status")
            {
                ApplicationArea = All;
                Caption = 'Update Vehicle Status';
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Update the vehicle status based on this maintenance record.';

                trigger OnAction()
                var
                    Resource: Record Resource;
                    StatusOptions: Text;
                    StatusChoice: Integer;
                    ConfirmMsg: Label 'Do you want to update the vehicle status?';
                begin
                    if not Confirm(ConfirmMsg, true) then
                        exit;

                    if Resource.Get(Rec."Vehicle No.") then begin
                        StatusOptions := 'Available,InMaintenance,Reserved,Inactive';
                        StatusChoice := StrMenu(StatusOptions, 1, 'Select vehicle status:');

                        case StatusChoice of
                            0: // Cancel
                                exit;
                            1: // Available
                                Resource."Resource Status" := Resource."Resource Status"::Available;
                            2: // InMaintenance
                                Resource."Resource Status" := Resource."Resource Status"::InMaintenance;
                            3: // Reserved
                                Resource."Resource Status" := Resource."Resource Status"::OnLeave;
                            4: // Inactive
                                Resource."Resource Status" := Resource."Resource Status"::Unavailable;
                        end;

                        Resource.Modify(true);
                        Message('Vehicle status updated successfully.');
                    end;
                end;
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