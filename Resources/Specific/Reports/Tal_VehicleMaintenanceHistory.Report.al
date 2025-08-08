report 73555 "Vehicle Maintenance History"
{
    ApplicationArea = All;
    Caption = 'Vehicle Maintenance History';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Resources/Specific/Reports/VehicleMaintenanceHistory.rdl';

    dataset
    {
        dataitem(Resource; Resource)
        {
            DataItemTableView = where(Type = const(Machine));
            RequestFilterFields = "No.", "vehicle Type";
            column(No_; "No.")
            {
            }
            column(Name; Name)
            {
            }
            column(License_plate_No_; " License plate No.")
            {
            }
            column(vehicle_Type; "vehicle Type")
            {
            }
            column(Current_kilometres; "Current kilometres")
            {
            }
            column(Last_Maintenance_Date; "Last Maintenance Date")
            {
            }
            column(Next_Maintenance_Date; "Next Maintenance Date")
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(DateFilter; DateFilter)
            {
            }

            dataitem("Vehicle Maintenance"; "Vehicle Maintenance")
            {
                DataItemLink = "Vehicle No." = field("No.");
                DataItemTableView = sorting("Vehicle No.", "Maintenance Date");
                RequestFilterFields = "Maintenance Type", Status, "Maintenance Date";

                column(Entry_No_; "Entry No.")
                {
                }
                column(Maintenance_Type; "Maintenance Type")
                {
                }
                column(Description; Description)
                {
                }
                column(Maintenance_Date; "Maintenance Date")
                {
                }
                column(Scheduled_Date; "Scheduled Date")
                {
                }
                column(Completion_Date; "Completion Date")
                {
                }
                column(Status; Status)
                {
                }
                column(Service_Provider; "Service Provider")
                {
                }
                column(Cost_Amount; "Cost Amount")
                {
                }
                column(Odometer_Reading; "Odometer Reading")
                {
                }
                column(Next_Service_Due; "Next Service Due")
                {
                }
                column(Notes; Notes)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not IncludeCancelled then
                        "Vehicle Maintenance".SetFilter(Status, '<>%1', "Vehicle Maintenance".Status::Cancelled);
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowNotes; ShowNotes)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Notes';
                        ToolTip = 'Specifies if maintenance notes should be included in the report.';
                    }
                    field(IncludeCancelled; IncludeCancelled)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Cancelled';
                        ToolTip = 'Specifies if cancelled maintenance records should be included in the report.';
                    }
                }
            }
        }
    }

    var
        ShowNotes: Boolean;
        IncludeCancelled: Boolean;
        DateFilter: Text;
        ReportTitleLbl: Label 'Vehicle Maintenance History';

    trigger OnInitReport()
    begin
        ShowNotes := true;
        IncludeCancelled := false;
        DateFilter := 'All Dates';
    end;
}