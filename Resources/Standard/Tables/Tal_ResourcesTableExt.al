tableextension 77000 " Ressources Table" extends Resource
{
    fields
    {
        field(77001; "Email"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(77002; "Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(77003; "GPS Tracking Enabled "; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(77004; "License No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(77005; "License Type"; Enum "Driver License Type")
        {
            DataClassification = ToBeClassified;
        }

        field(77006; "License Expiration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(77007; "Additional Certifications"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(77008; "Identity Card No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(77009; "Birth Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(77010; " License plate No."; Code[20])
        {
            // Caption = 'License plate No.';
            DataClassification = CustomerContent;
        }
        field(77011; "Machine Model"; Text[50])
        {
            // Caption = 'Specifies the Machine Model';
            DataClassification = CustomerContent;
        }
        field(77012; " Vehicule Security No."; code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(77013; "vehicle Type"; enum "Tal Vehicle Type")
        {
            // Caption = 'Specifies the Vehicule Type ';
            DataClassification = CustomerContent;

        }

        field(77014; "Max Capacity Charge"; Decimal)
        {
            // Caption = ' Specifies the Max Capacity Charge in KG';
            DataClassification = CustomerContent;
        }
        field(77015; "Current kilometres"; Decimal)
        {
            // Caption = 'Specifies the total distance traveled by the vehicle';
            DataClassification = ToBeClassified;
        }

        field(77016; "Last Maintenance Date"; Date)
        {
            // Caption = 'Specifies the date of the last maintenance performed on the vehicle';
            DataClassification = CustomerContent;
        }
        field(77017; "Next Maintenance Date"; Date)
        {
            // Caption = 'Specifies the planned date for the next vehicle maintenance.';
            DataClassification = CustomerContent;
        }
        field(77018; "vehicle Height"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Height in Meters';
        }

        field(77019; "vehicle Width"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Width in meters';
        }

        field(77020; "vehicle Length"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Length in meters';
        }
        field(77021; "Vehicule Volume"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77022; "Resource Status"; Enum "Resource Status")
        {
            DataClassification = ToBeClassified;
        }
        field(77023; "Insurance Expiration Date "; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77024; vignette; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77025; IsTractor; Boolean)
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


        field(77026; "Tractor No."; Code[20])
        {
            Caption = 'Tractor Number';
        }

        field(77027; IsTrailer; Boolean)
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


        field(77028; "Trailer No."; Code[20])
        {
            Caption = 'Trailer Number';
        }

        field(77029; IsTanker; Boolean)
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


        field(77030; "Tanker No."; Code[20])
        {
            Caption = 'Tanker Number';
        }

    }

    var
        myInt: Integer;
}