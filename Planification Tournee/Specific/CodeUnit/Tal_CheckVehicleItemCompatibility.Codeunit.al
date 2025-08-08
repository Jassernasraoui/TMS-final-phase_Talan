codeunit 73653 "Vehicle Item Compat. Check"
{
    procedure CheckVehicleItemCompatibilityForTour(var TourHeader: Record "Planification Header")
    var
        PlanningLines: Record "Planning Lines";
        VehicleItemCompatibility: Codeunit "Vehicle Item Compatibility";
        Item: Record Item;
        IncompatibleItems: Text;
        ErrorText: Text;
        ItemCount: Integer;
        IsCompatible: Boolean;
    begin
        if TourHeader."Véhicule No." = '' then
            exit;

        // Check all planning lines for this tour
        PlanningLines.Reset();
        PlanningLines.SetRange("Logistic Tour No.", TourHeader."Logistic Tour No.");
        PlanningLines.SetFilter("Item No.", '<>%1', '');

        if PlanningLines.FindSet() then begin
            repeat
                IsCompatible := VehicleItemCompatibility.GetCompatibilityErrorMessage(TourHeader."Véhicule No.", PlanningLines."Item No.", ErrorText);
                if not IsCompatible then begin
                    if Item.Get(PlanningLines."Item No.") then begin
                        if IncompatibleItems <> '' then
                            IncompatibleItems += ', ';
                        IncompatibleItems += Item."No." + ' (' + Item.Description + ')';
                        ItemCount += 1;
                    end;
                end;
            until PlanningLines.Next() = 0;
        end;

        if IncompatibleItems <> '' then begin
            if ItemCount = 1 then
                if not Confirm(StrSubstNo('Warning: The selected vehicle is not compatible with the following item:\n%1\n\nDo you want to continue anyway?', IncompatibleItems), false) then
                    Error('Vehicle assignment cancelled due to compatibility issues.')
                else
                    Message('Vehicle assigned despite compatibility issues. Please review the items or change the vehicle.')
            else
                if not Confirm(StrSubstNo('Warning: The selected vehicle is not compatible with %1 items:\n%2\n\nDo you want to continue anyway?', ItemCount, IncompatibleItems), false) then
                    Error('Vehicle assignment cancelled due to compatibility issues.')
                else
                    Message('Vehicle assigned despite compatibility issues. Please review the items or change the vehicle.');
        end;
    end;
}