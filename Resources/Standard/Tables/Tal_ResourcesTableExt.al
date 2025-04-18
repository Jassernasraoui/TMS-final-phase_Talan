tableextension 50115 " Ressources Table" extends Resource
{
    fields
    {
        field(50003; "Email"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(50004; "Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(50011; "GPS Tracking Enabled "; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(50005; "License No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "License Type"; Enum "Driver License Type")
        {
            DataClassification = ToBeClassified;
        }

        field(50007; "License Expiration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50008; "Additional Certifications"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50009; "Identity Card No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50010; "Birth Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50100; " License plate No."; Code[20])
        {
            // Caption = 'License plate No.';
            DataClassification = CustomerContent;
        }
        field(50101; "Machine Model"; Text[50])
        {
            // Caption = 'Specifies the Machine Model';
            DataClassification = CustomerContent;
        }
        field(50111; " Vehicule Security No."; code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "vehicle Type"; enum "vehicle Type")
        {
            // Caption = 'Specifies the Vehicule Type ';
            DataClassification = CustomerContent;

        }

        field(50103; "Max Capacity Charge"; Code[100])
        {
            // Caption = ' Specifies the Max Capacity Charge in KG';
            DataClassification = CustomerContent;
        }
        field(50104; "Current kilometres"; code[100])
        {
            // Caption = 'Specifies the total distance traveled by the vehicle';
            DataClassification = ToBeClassified;
        }

        field(50105; "Last Maintenance Date"; Date)
        {
            // Caption = 'Specifies the date of the last maintenance performed on the vehicle';
            DataClassification = CustomerContent;
        }
        field(50106; "Next Maintenance Date"; Date)
        {
            // Caption = 'Specifies the planned date for the next vehicle maintenance.';
            DataClassification = CustomerContent;
        }
        field(50107; "vehicle Height"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Height in Meters';
        }

        field(50108; "vehicle Width"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Width in meters';
        }

        field(50109; "vehicle Length"; Decimal)
        {
            DataClassification = CustomerContent;
            // Caption = 'Specifies the Vehicle Length in meters';
        }
        field(50110; "Vehicule Volume"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50112; "Resource Status"; Enum "Resource Status")
        {
            DataClassification = ToBeClassified;
        }
        field(50120; IsTractor; Boolean)
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


        field(50121; "Tractor No."; Code[20])
        {
            Caption = 'Tractor Number';
        }

        field(50122; IsTrailer; Boolean)
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


        field(50123; "Trailer No."; Code[20])
        {
            Caption = 'Trailer Number';
        }

        field(50124; IsTanker; Boolean)
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


        field(50125; "Tanker No."; Code[20])
        {
            Caption = 'Tanker Number';
        }

    }

    var
        myInt: Integer;
}