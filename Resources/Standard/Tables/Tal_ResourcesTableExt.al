tableextension 73596 " Ressources Table" extends Resource
{

    fields
    {
        field(73000; "Email"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(73001; "Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(73002; "GPS Tracking Enabled "; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(73003; "License No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(73004; "License Type"; Enum "Driver License Type")
        {
            DataClassification = ToBeClassified;
        }

        field(73005; "License Expiration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(73006; "Additional Certifications"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(73007; "Identity Card No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(73008; "Birth Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(73009; " License plate No."; Code[20])
        {
            // Caption = 'License plate No.';
            DataClassification = CustomerContent;
        }
        field(73010; "Machine Model"; Text[50])
        {
            // Caption = 'Specifies the Machine Model';
            DataClassification = CustomerContent;
        }
        field(73011; " Vehicule Security No."; code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(73012; "vehicle Type"; enum "Tal Vehicle Type")
        {
            // Caption = 'Specifies the Vehicule Type ';
            DataClassification = CustomerContent;

        }

        field(73013; "Max Capacity Charge"; Decimal)
        {
            // Caption = ' Specifies the Max Capacity Charge in KG';
            DataClassification = CustomerContent;
        }
        field(73014; "Current kilometres"; Decimal)
        {
            // Caption = 'Specifies the total distance traveled by the vehicle';
            DataClassification = ToBeClassified;
        }

        field(73015; "Last Maintenance Date"; Date)
        {
            // Caption = 'Specifies the date of the last maintenance performed on the vehicle';
            DataClassification = CustomerContent;
        }
        field(73016; "Next Maintenance Date"; Date)
        {
            // Caption = 'Specifies the planned date for the next vehicle maintenance.';
            DataClassification = CustomerContent;
        }
        field(73017; "vehicle Height"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Height in Meters';
        }

        field(73018; "vehicle Width"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Width in meters';
        }

        field(73019; "vehicle Length"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Length in meters';
        }
        field(73020; "Vehicle Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(73021; "Resource Status"; Enum "Resource Status")
        {
            DataClassification = ToBeClassified;
        }
        field(73022; "Insurance Expiration Date "; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(73023; vignette; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(73024; IsTractor; Boolean)
        {
            Caption = 'Tractor';

            trigger OnValidate()
            var
                Err: Label 'You must enter the Tractor Number when Tractor is selected.';
            begin
                if IsTractor then begin
                    if "Tractor No." = '' then
                        Error(Err);
                end else begin
                    "Tractor No." := '';
                end;
            end;
        }


        field(73025; "Tractor No."; Code[20])
        {
            Caption = 'Tractor Number';
        }

        field(73026; IsTrailer; Boolean)
        {
            Caption = 'Trailer';

            trigger OnValidate()
            var
                Err: Label 'You must enter the Trailer Number when Trailer is selected.';
            begin
                if IsTrailer then begin
                    if "Trailer No." = '' then
                        Error(Err);
                end else begin
                    "Trailer No." := '';
                end;
            end;
        }


        field(73027; "Trailer No."; Code[20])
        {
            Caption = 'Trailer Number';
        }

        field(73028; IsTanker; Boolean)
        {
            Caption = 'Tanker';

            trigger OnValidate()
            var
                Err: Label 'You must enter the Tanker Number when Tanker is selected.';
            begin
                if IsTanker then begin
                    if "Tanker No." = '' then
                        Error(Err);
                end else begin
                    "Tanker No." := '';
                end;
            end;
        }


        field(73029; "Tanker No."; Code[20])
        {
            Caption = 'Tanker Number';
        }
        field(73030; "used as location"; Boolean)
        {
            Caption = 'Used as Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the resource is a location or not.';
            trigger OnValidate()
            var
                LocationRec: Record Location;
            begin
                if "used as location" then begin
                    // Check if location already exists with this Vehicle Code
                    if not LocationRec.Get("No.") then begin
                        LocationRec.Init();
                        LocationRec."Code" := "No."; // Use Vehicle Code as Location Code
                        LocationRec."Name" := "Name"; // Use Vehicle Name as Location Name
                        LocationRec.Insert();

                        Message('Location %1 created for vehicle.', LocationRec."Code");
                    end else
                        Message('Location %1 already exists.', LocationRec."Code");
                end else begin
                    // Delete location if it exists
                    if LocationRec.Get("no.") then begin
                        if Confirm('Do you want to delete the location %1?', false, LocationRec."Code") then begin
                            LocationRec.Delete();
                            Message('Location %1 deleted.', LocationRec."Code");
                        end;
                    end;
                end;
            end;
        }
        // field(77032; "Tours achieved"; Integer)
        // {
        //     FieldClass = FlowField;
        //     Caption = 'Tours Achieved';
        //     ToolTip = 'Specifies the number of tours achieved by the vehicle.';
        //     // CalcFormula = Count("Tour Execution Tracking" where(Status = const("Livré"), "Driver no" = field("No.")));
        // }

    }

    var
        myInt: Integer;

}