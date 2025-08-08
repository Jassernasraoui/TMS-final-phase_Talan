tableextension 73597 "Tal Item Table Ext" extends Item
{
    fields
    {
        field(77003; "Vehicle Class Code"; Enum "Tal Vehicle Type")
        {
            Caption = 'Vehicle Class Code';
            DataClassification = ToBeClassified;
        }

        field(77004; "Special Handling"; Enum "Item Special Handling")
        {
            Caption = 'Special Handling';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                UpdateRequiredVehicleType();
            end;
        }

        field(77005; "Temperature Requirements"; Decimal)
        {
            Caption = 'Temperature Requirements (°C)';
            DataClassification = ToBeClassified;
            BlankZero = true;
            DecimalPlaces = 1;
            MinValue = -50;
            MaxValue = 100;
        }

        field(77006; "Handling Instructions"; Text[250])
        {
            Caption = 'Handling Instructions';
            DataClassification = ToBeClassified;
        }
    }

    local procedure UpdateRequiredVehicleType()
    begin
        case "Special Handling" of
            "Special Handling"::None:
                "Vehicle Class Code" := "Vehicle Class Code"::"Light Utility Vehicles";
            "Special Handling"::"Temperature Controlled",
            "Special Handling"::Perishable:
                "Vehicle Class Code" := "Vehicle Class Code"::"Medium Weight Vehicles";
            "Special Handling"::"Hazardous Materials",
            "Special Handling"::Explosive,
            "Special Handling"::Corrosive:
                "Vehicle Class Code" := "Vehicle Class Code"::"Heavy Vehicles";
            "Special Handling"::Fragile:
                "Vehicle Class Code" := "Vehicle Class Code"::"Medium Weight Vehicles";
            "Special Handling"::Oversized:
                "Vehicle Class Code" := "Vehicle Class Code"::Trucks;
            "Special Handling"::Liquid:
                "Vehicle Class Code" := "Vehicle Class Code"::"Heavy Vehicles";
            "Special Handling"::"Live Animals":
                "Vehicle Class Code" := "Vehicle Class Code"::"Medium Weight Vehicles";
            "Special Handling"::"Medical Supplies":
                "Vehicle Class Code" := "Vehicle Class Code"::"Light Utility Vehicles";
        end;
    end;
}