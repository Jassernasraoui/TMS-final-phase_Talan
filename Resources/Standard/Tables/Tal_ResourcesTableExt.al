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
            Caption = 'License plate No.';
            DataClassification = CustomerContent;
        }
        field(50101; "Machine Model"; Text[50])
        {
            Caption = 'Specifies the Machine Model';
            DataClassification = CustomerContent;
        }
        field(50102; "Vehicule Type"; enum "Vehicule Type")
        {
            Caption = 'Specifies the Vehicule Type ';
            DataClassification = CustomerContent;

        }

        field(50103; "Max Capacity Charge"; Code[100])
        {
            Caption = ' Specifies the Max Capacity Charge in KG';
            DataClassification = CustomerContent;
        }
        field(50104; "Current kilometres"; code[100])
        {
            Caption = 'Specifies the total distance traveled by the vehicle';
            DataClassification = ToBeClassified;
        }

        field(50105; "Last Maintenance Date"; Date)
        {
            Caption = 'Specifies the date of the last maintenance performed on the vehicle';
            DataClassification = CustomerContent;
        }
        field(50106; "Next Maintenance Date"; Date)
        {
            Caption = 'Specifies the planned date for the next vehicle maintenance.';
            DataClassification = CustomerContent;
        }
        field(50107; "Vehicle Height"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Specifies the Vehicle Height in Meters';
        }

        field(50108; "Vehicle Width"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Specifies the Vehicle Width in meters';
        }

        field(50109; "Vehicle Length"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Specifies the Vehicle Length in meters';
        }
    }

    var
        myInt: Integer;
}