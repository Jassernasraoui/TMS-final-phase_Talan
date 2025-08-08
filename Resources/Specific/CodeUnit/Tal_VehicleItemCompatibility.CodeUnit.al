codeunit 73559 "Vehicle Item Compatibility"
{
    procedure IsVehicleCompatibleWithItem(VehicleNo: Code[20]; ItemNo: Code[20]): Boolean
    var
        Resource: Record Resource;
        Item: Record Item;
        IsCompatible: Boolean;
        ErrorText: Text;
    begin
        if not Resource.Get(VehicleNo) then
            exit(false);

        if not Item.Get(ItemNo) then
            exit(false);

        IsCompatible := CheckVehicleItemCompatibility(Resource, Item, ErrorText);
        exit(IsCompatible);
    end;

    procedure CheckVehicleItemCompatibility(Resource: Record Resource; Item: Record Item; var ErrorText: Text): Boolean
    begin
        // Check vehicle class compatibility
        if not IsVehicleClassCompatible(Resource."vehicle Type", Item."Vehicle Class Code") then begin
            ErrorText := StrSubstNo('Vehicle class : %1 n\ is not compatible with the Item required class : %2',
                                Resource."vehicle Type", Item."Vehicle Class Code");
            exit(false);
        end;

        // Check special handling requirements
        if not IsSpecialHandlingCompatible(Resource, Item, ErrorText) then
            exit(false);

        // If we reach here, the vehicle is compatible with the item
        exit(true);
    end;

    local procedure IsVehicleClassCompatible(VehicleType: Enum "Tal Vehicle Type"; RequiredType: Enum "Tal Vehicle Type"): Boolean
    begin
        // If no specific requirement, any vehicle is compatible
        if RequiredType = RequiredType::"Light Utility Vehicles" then
            exit(true);

        // Check if vehicle type matches or exceeds required type
        case RequiredType of
            RequiredType::"Light Utility Vehicles":
                exit(true); // Any vehicle can handle light utility items
            RequiredType::"Medium Weight Vehicles":
                exit((VehicleType = VehicleType::"Medium Weight Vehicles") or
                     (VehicleType = VehicleType::"Heavy Vehicles") or
                     (VehicleType = VehicleType::Trucks));
            RequiredType::"Heavy Vehicles":
                exit((VehicleType = VehicleType::"Heavy Vehicles") or
                     (VehicleType = VehicleType::Trucks));
            RequiredType::Trucks:
                exit(VehicleType = VehicleType::Trucks);
            RequiredType::"Towed Cars":
                exit(VehicleType = VehicleType::"Towed Cars");
            RequiredType::"Buses and Coaches":
                exit(VehicleType = VehicleType::"Buses and Coaches");
            RequiredType::"Agricultural and Forestry Vehicles":
                exit(VehicleType = VehicleType::"Agricultural and Forestry Vehicles");
            else
                exit(VehicleType = RequiredType);
        end;
    end;

    local procedure IsSpecialHandlingCompatible(Resource: Record Resource; Item: Record Item; var ErrorText: Text): Boolean
    begin
        // If no special handling required, any vehicle is compatible
        if Item."Special Handling" = Item."Special Handling"::None then
            exit(true);

        // Check primary and secondary capabilities
        if not IsCapabilityCompatible(Resource."Primary Capability", Resource."Secondary Capability", Item."Special Handling") then begin
            ErrorText := StrSubstNo('Vehicle does not have the capability to handle %1 items', Item."Special Handling");
            exit(false);
        end;

        // Check temperature requirements
        if (Item."Special Handling" = Item."Special Handling"::"Temperature Controlled") or
           (Item."Special Handling" = Item."Special Handling"::Perishable) then begin
            if (Item."Temperature Requirements" <> 0) and
               ((Resource."Temperature Range Min" > Item."Temperature Requirements") or
                (Resource."Temperature Range Max" < Item."Temperature Requirements")) then begin
                ErrorText := StrSubstNo('Vehicle temperature range (%1°C to %2°C) does not meet item requirement (%3°C)',
                                    Resource."Temperature Range Min", Resource."Temperature Range Max", Item."Temperature Requirements");
                exit(false);
            end;
        end;

        // Check hazmat certification
        if (Item."Special Handling" = Item."Special Handling"::"Hazardous Materials") or
           (Item."Special Handling" = Item."Special Handling"::Explosive) or
           (Item."Special Handling" = Item."Special Handling"::Corrosive) then begin
            if not Resource."Hazmat Certification" then begin
                ErrorText := 'Vehicle does not have hazardous materials certification';
                exit(false);
            end;
        end;

        // If we reach here, the special handling requirements are compatible
        exit(true);
    end;

    local procedure IsCapabilityCompatible(PrimaryCapability: Enum "Vehicle Capabilities"; SecondaryCapability: Enum "Vehicle Capabilities"; SpecialHandling: Enum "Item Special Handling"): Boolean
    var
        RequiredCapability: Enum "Vehicle Capabilities";
    begin
        // Map special handling to required capability
        case SpecialHandling of
            SpecialHandling::None:
                RequiredCapability := RequiredCapability::Standard;
            SpecialHandling::"Temperature Controlled":
                RequiredCapability := RequiredCapability::Refrigerated;
            SpecialHandling::"Hazardous Materials":
                RequiredCapability := RequiredCapability::"Hazmat Certified";
            SpecialHandling::Fragile:
                RequiredCapability := RequiredCapability::"Shock Absorbing";
            SpecialHandling::Oversized:
                RequiredCapability := RequiredCapability::"Oversized Load";
            SpecialHandling::Perishable:
                RequiredCapability := RequiredCapability::"Climate Controlled";
            SpecialHandling::Liquid:
                RequiredCapability := RequiredCapability::Tanker;
            SpecialHandling::"Live Animals":
                RequiredCapability := RequiredCapability::"Animal Transport";
            SpecialHandling::"Medical Supplies":
                RequiredCapability := RequiredCapability::"Medical Transport";
            SpecialHandling::Explosive:
                RequiredCapability := RequiredCapability::"Explosive Certified";
            SpecialHandling::Corrosive:
                RequiredCapability := RequiredCapability::"Chemical Transport";
            else
                RequiredCapability := RequiredCapability::Standard;
        end;

        // Check if either primary or secondary capability matches the required capability
        exit((PrimaryCapability = RequiredCapability) or (SecondaryCapability = RequiredCapability) or
             (PrimaryCapability = PrimaryCapability::Standard) or (SecondaryCapability = SecondaryCapability::Standard));
    end;

    procedure GetCompatibilityErrorMessage(VehicleNo: Code[20]; ItemNo: Code[20]; var ErrorText: Text): Boolean
    var
        Resource: Record Resource;
        Item: Record Item;
        IsCompatible: Boolean;
    begin
        ErrorText := '';

        if not Resource.Get(VehicleNo) then begin
            ErrorText := StrSubstNo('Vehicle %1 not found', VehicleNo);
            exit(false);
        end;

        if not Item.Get(ItemNo) then begin
            ErrorText := StrSubstNo('Item %1 not found', ItemNo);
            exit(false);
        end;

        IsCompatible := CheckVehicleItemCompatibility(Resource, Item, ErrorText);
        exit(IsCompatible);
    end;
}