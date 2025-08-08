table 73620 "Planification Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(73501; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(73506; "Logistic Tour No."; Code[20])
        {
            DataClassification = CustomerContent;


            trigger OnValidate()
            var
                TourNo: Record "Planification Header";
                SetupRec: Record "Trip Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "Logistic Tour No." < xRec."Logistic Tour No." then
                    if not TourNo.Get(Rec."Logistic Tour No.") then begin
                        SetupRec.Get();
                        NoSeries.TestManual(SetupRec."Logistic Tour Nos.", "Logistic Tour No.");
                        "No. Series" := '';
                    end;
            end;
        }

        field(73502; "Date de Tournée"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour Date';
        }

        field(73522; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                if "End Date" <> 0D then
                    if "Start Date" > "End Date" then
                        Error('Start Date cannot be after End Date');

                if "Date de Tournée" = 0D then
                    "Date de Tournée" := "Start Date";
            end;
        }

        field(73523; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'End Date';

            trigger OnValidate()
            begin
                if "Start Date" <> 0D then
                    if "End Date" < "Start Date" then
                        Error('End Date cannot be before Start Date');
            end;
        }

        field(73524; "Working Hours Start"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Working Hours Start';
        }

        field(73525; "Working Hours End"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Working Hours End';
        }

        field(73526; "Max Visits Per Tour"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Max Visits Per Day';
            MinValue = 0;
        }

        field(73527; "Non-Working Days"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Non-Working Days';
            Description = 'Stored as comma-separated dates';
        }

        field(73503; "Driver No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chauffeur';
            TableRelation = Resource."No." where("Type" = const(Person));

            trigger OnValidate()
            var
                Resource: Record Resource;
                PlanificationHeader: Record "Planification Header";
                ResourceAlreadyAssigned: Boolean;
                ConflictTourNo: Code[20];
            begin
                // If the resource is being changed, free the previous one
                if ("Driver No." <> xRec."Driver No.") and (xRec."Driver No." <> '') then
                    FreeResource(xRec."Driver No.");

                // Skip validation if empty
                if "Driver No." = '' then
                    exit;

                // Check if resource exists and is available
                if Resource.Get("Driver No.") then begin
                    // Check if this resource is already assigned to another tour with the same start date
                    PlanificationHeader.Reset();
                    PlanificationHeader.SetFilter("Logistic Tour No.", '<>%1', "Logistic Tour No.");
                    PlanificationHeader.SetFilter("Driver No.", '%1', "Driver No.");

                    // Only check tours that have overlapping dates
                    if "Start Date" <> 0D then begin
                        PlanificationHeader.SetFilter("Start Date", '<=%1', "Start Date");
                        PlanificationHeader.SetFilter("End Date", '>=%1', "Start Date");
                    end;

                    ResourceAlreadyAssigned := false;
                    if PlanificationHeader.FindSet() then begin
                        repeat
                            ResourceAlreadyAssigned := true;
                            ConflictTourNo := PlanificationHeader."Logistic Tour No.";
                        until PlanificationHeader.Next() = 0;
                    end;

                    if ResourceAlreadyAssigned then
                        if not Confirm('The driver %1 is already assigned to tour %2 during this period.\Do you want to continue anyway?', false, "Driver No.", ConflictTourNo) then
                            Error('Driver assignment cancelled.');

                    // Update resource status to Assigned
                    Resource."Resource Status" := "Resource Status"::Assigned;
                    Resource.Modify(true);
                end;
            end;
        }

        field(73504; "Véhicule No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Véhicule';
            TableRelation = Resource."No." where("Type" = const(Machine));

            trigger OnValidate()
            var
                Resource: Record Resource;
                PlanificationHeader: Record "Planification Header";
                ResourceAlreadyAssigned: Boolean;
                ConflictTourNo: Code[20];
            begin
                // If the resource is being changed, free the previous one
                if ("Véhicule No." <> xRec."Véhicule No.") and (xRec."Véhicule No." <> '') then
                    FreeResource(xRec."Véhicule No.");

                // Skip validation if empty
                if "Véhicule No." = '' then
                    exit;

                // Check if resource exists and is available
                if Resource.Get("Véhicule No.") then begin
                    // Check if this resource is already assigned to another tour with the same start date
                    PlanificationHeader.Reset();
                    PlanificationHeader.SetFilter("Logistic Tour No.", '<>%1', "Logistic Tour No.");
                    PlanificationHeader.SetFilter("Véhicule No.", '%1', "Véhicule No.");

                    // Only check tours that have overlapping dates
                    if "Start Date" <> 0D then begin
                        PlanificationHeader.SetFilter("Start Date", '<=%1', "Start Date");
                        PlanificationHeader.SetFilter("End Date", '>=%1', "Start Date");
                    end;

                    ResourceAlreadyAssigned := false;
                    if PlanificationHeader.FindSet() then begin
                        repeat
                            ResourceAlreadyAssigned := true;
                            ConflictTourNo := PlanificationHeader."Logistic Tour No.";
                        until PlanificationHeader.Next() = 0;
                    end;

                    if ResourceAlreadyAssigned then
                        if not Confirm('The vehicle %1 is already assigned to tour %2 during this period.\Do you want to continue anyway?', false, "Véhicule No.", ConflictTourNo) then
                            Error('Vehicle assignment cancelled.');

                    // Check compatibility with all items already assigned to this tour
                    CheckVehicleItemCompatibility();

                    // Update resource status to Assigned to Mission
                    Resource."Resource Status" := "Resource Status"::Assigned;
                    Resource.Modify(true);
                end;
            end;
        }

        field(73505; "Statut"; Option) { DataClassification = ToBeClassified; OptionMembers = Draft,Plannified,Loading,Inprogress,Completed,Stopped; OptionCaption = 'Draft,Plannified,Loading,In Progress,completed,Stopped'; trigger OnLookup() var Style: Enum "Style"; begin case "Statut" of "Statut"::Plannified: Style := Style::Green; "Statut"::Loading: Style := Style::Yellow; "Statut"::Stopped: Style := Style::Red; "Statut"::Inprogress: Style := Style::Green; end; end; }

        field(73507; "Commentaire"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(73508; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(73509; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(73510; "No. of Planning Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planning Lines" where("Logistic Tour No." = field("Logistic Tour No.")));
            Caption = 'Number of Planning Lines';
            Editable = false;
        }

        field(73511; "Total Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Planning Lines".Quantity where("Logistic Tour No." = field("Logistic Tour No.")));
            Caption = 'Total Quantity';
            Editable = false;
        }

        field(73512; "Estimated Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Total Weight (kg)';
            Editable = false;
        }

        field(73513; "Estimated Distance"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Distance (km)';
            Editable = false;
        }

        field(73514; "Estimated Duration"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Duration (hrs)';
            Editable = false;
        }

        field(73515; "Load Utilization"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Load Utilization (%)';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(73516; "Created By"; code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = User."User Name";

        }
        field(73517; "Delivery Area"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(73518; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(73519; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "location"."code";
        }
        field(73520; "Shipping Agent Code"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent"."Code";
        }
        field(73521; "Warehouse Employees"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Employee"."User ID";

        }

        field(73528; "Start Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Start Location';
            TableRelation = "Trip Setup"."Location Code";
        }

        field(73529; "End Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'End Location';
            TableRelation = Location.Code;
        }
        field(77030; "Conveyor Attendant"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Conveyor Attendant';
            TableRelation = Resource."No." where("Resource Group No." = const('CONV'), "Resource Status" = const(Available));

            trigger OnValidate()
            var
                Resource: Record Resource;
                PlanificationHeader: Record "Planification Header";
                ResourceAlreadyAssigned: Boolean;
                ConflictTourNo: Code[20];
            begin
                // If the resource is being changed, free the previous one
                if ("Conveyor Attendant" <> xRec."Conveyor Attendant") and (xRec."Conveyor Attendant" <> '') then
                    FreeResource(xRec."Conveyor Attendant");

                // Skip validation if empty
                if "Conveyor Attendant" = '' then
                    exit;

                // Check if resource exists and is available
                if Resource.Get("Conveyor Attendant") then begin
                    // Check if this resource is already assigned to another tour with the same start date
                    PlanificationHeader.Reset();
                    PlanificationHeader.SetFilter("Logistic Tour No.", '<>%1', "Logistic Tour No.");
                    PlanificationHeader.SetFilter("Conveyor Attendant", '%1', "Conveyor Attendant");

                    // Only check tours that have overlapping dates
                    if "Start Date" <> 0D then begin
                        PlanificationHeader.SetFilter("Start Date", '<=%1', "Start Date");
                        PlanificationHeader.SetFilter("End Date", '>=%1', "Start Date");
                    end;

                    ResourceAlreadyAssigned := false;
                    if PlanificationHeader.FindSet() then begin
                        repeat
                            ResourceAlreadyAssigned := true;
                            ConflictTourNo := PlanificationHeader."Logistic Tour No.";
                        until PlanificationHeader.Next() = 0;
                    end;

                    if ResourceAlreadyAssigned then
                        Error('The conveyor attendant %1 is already assigned to tour %2 during this period.', "Conveyor Attendant", ConflictTourNo);

                    // Update resource status to Assigned
                    Resource."Resource Status" := "Resource Status"::Assigned;
                    Resource.Modify(true);
                end;
            end;
        }
        field(77031; "Number of Deliveries"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Number of Deliveries';
            Editable = false;
            ToolTip = 'Total number of deliveries planned for this tour.';
        }
        field(77032; "Planned Start Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Planned Start Time';
            ToolTip = 'Specifies the planned start time for the tour.';
        }
        field(77033; "Planned End Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Planned End Time';
            ToolTip = 'Specifies the planned end time for the tour.';
        }
        field(77034; "Actual Start Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Actual Start Time';
            ToolTip = 'Specifies the actual start time of the tour.';
        }
        field(77035; "Actual End Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Actual End Time';
            ToolTip = 'Specifies the actual end time of the tour.';
        }
        field(77036; "Total Distance"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Total Distance';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the total distance covered during the tour in kilometers.';
        }
        field(77037; "Fuel Consumption"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Fuel Consumption';
            DecimalPlaces = 2 : 2;
            ToolTip = 'Specifies the total fuel consumed during the tour in liters.';
        }
        field(77038; "Incidents Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Incidents Count';
            ToolTip = 'Specifies the number of incidents that occurred during the tour.';
        }
        field(77039; "Documents Posted"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Documents Posted';
            Editable = false;
        }
        field(77040; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
            Editable = false;
        }

    }
    keys
    {
        key(PK; "Logistic Tour No.") { Clustered = true; }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
        SetupRec: Record "Trip Setup";
    begin
        if "Logistic Tour No." = '' then begin
            SetupRec.Get();
            SetupRec.TestField("Logistic Tour Nos.");
            "No. Series" := SetupRec."Logistic Tour Nos.";
            if NoSeries.AreRelated(SetupRec."Logistic Tour Nos.", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Logistic Tour No." := NoSeries.GetNextNo("No. Series", Today, true);
        end;

        "Document Date" := Today;
        "Created By" := UserId;

        begin
            // Set initial status to Scheduling
            Rec.Statut := Rec.Statut::Draft;
        end;

    end;

    trigger OnDelete()
    var
        Resource: Record Resource;
    begin
        // Free up resources when a tour is deleted
        if "Driver No." <> '' then begin
            if Resource.Get("Driver No.") then begin
                Resource."Resource Status" := "Resource Status"::Available;
                Resource.Modify(true);
            end;
        end;

        if "Véhicule No." <> '' then begin
            if Resource.Get("Véhicule No.") then begin
                Resource."Resource Status" := "Resource Status"::Available;
                Resource.Modify(true);
            end;
        end;

        if "Conveyor Attendant" <> '' then begin
            if Resource.Get("Conveyor Attendant") then begin
                Resource."Resource Status" := "Resource Status"::Available;
                Resource.Modify(true);
            end;
        end;
    end;

    // Helper procedure to free a resource when it's being replaced
    local procedure FreeResource(ResourceNo: Code[20])
    var
        Resource: Record Resource;
    begin
        if ResourceNo = '' then
            exit;

        if Resource.Get(ResourceNo) then begin
            Resource."Resource Status" := Resource."Resource Status"::Available;
            Resource.Modify(true);
        end;
    end;

    local procedure CheckVehicleItemCompatibility()
    var
        PlanningLines: Record "Planning Lines";
        VehicleItemCompatibility: Codeunit "Vehicle Item Compatibility";
        Item: Record Item;
        IncompatibleItems: Text;
        ErrorText: Text;
        ItemCount: Integer;
        IsCompatible: Boolean;
    begin
        if "Véhicule No." = '' then
            exit;

        // Check all planning lines for this tour
        PlanningLines.Reset();
        PlanningLines.SetRange("Logistic Tour No.", "Logistic Tour No.");
        PlanningLines.SetFilter("Item No.", '<>%1', '');

        if PlanningLines.FindSet() then begin
            repeat
                IsCompatible := VehicleItemCompatibility.GetCompatibilityErrorMessage("Véhicule No.", PlanningLines."Item No.", ErrorText);
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
                if not Confirm(StrSubstNo('Warning: The selected vehicle is not compatible based on special handling requirements with the following item:\ %1\Do you want to continue anyway?', IncompatibleItems), false) then
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

    procedure AssistEdit(OldRec: Record "Planification Header"): Boolean
    var
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        Setup: Record "Trip Setup";
        NewNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // (Hook pour les events personnalisés si besoin)
        // OnBeforeAssistEdit(Rec, OldRec, IsHandled, Result);
        if IsHandled then
            exit;

        if Setup.Get() then begin
            Setup.TestField("Logistic Tour Nos."); // vérifie que la série est bien renseignée
            if NoSeriesMgt.SelectSeries(Setup."Logistic Tour Nos.", Rec."No. Series", Rec."No. Series") then begin
                Rec."No. Series" := Setup."Logistic Tour Nos.";
                NewNo := NoSeriesMgt.GetNextNo(Rec."No. Series", WorkDate(), true);
                Rec."Logistic Tour No." := NewNo;
                exit(true);
            end;
        end;

        exit(false);
    end;


}