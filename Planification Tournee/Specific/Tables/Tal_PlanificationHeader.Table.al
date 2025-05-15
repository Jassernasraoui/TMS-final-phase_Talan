table 77100 "Planification Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(7701; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(7706; "Logistic Tour No."; Code[20])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TourNo: Record "Planification Header";
                SetupRec: Record "Sales & Receivables Setup";
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

        field(7702; "Date de Tournée"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tour Date';
        }

        field(77022; "Start Date"; Date)
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

        field(77023; "End Date"; Date)
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

        field(77024; "Working Hours Start"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Working Hours Start';
        }

        field(77025; "Working Hours End"; Time)
        {
            DataClassification = ToBeClassified;
            Caption = 'Working Hours End';
        }

        field(77026; "Max Visits Per Day"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Max Visits Per Day';
            MinValue = 0;
        }

        field(77027; "Non-Working Days"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Non-Working Days';
            Description = 'Stored as comma-separated dates';
        }

        field(77003; "Driver No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chauffeur';
            TableRelation = Resource."No." where("Type" = const(Person));
        }

        field(77004; "Véhicule No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Véhicule';
            TableRelation = Resource."No." where("Type" = const(Machine));
            
        }

        field(77005; "Statut"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Plannified,"On Mission",Stopped;
            OptionCaption = 'Planifiée,En cours,Terminée';
            trigger OnLookup()
            var
                Style: Enum "Style";
            begin
                case "Statut" of
                    "Statut"::Plannified:
                        Style := Style::Green;
                    "Statut"::"On Mission":
                        Style := Style::Yellow;
                    "Statut"::Stopped:
                        Style := Style::Red;
                end;
            end;
        }

        field(77007; "Commentaire"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(77008; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(77009; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(77010; "No. of Planning Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Planning Lines" where("Logistic Tour No." = field("Logistic Tour No.")));
            Caption = 'Number of Planning Lines';
            Editable = false;
        }

        field(77011; "Total Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Planning Lines".Quantity where("Logistic Tour No." = field("Logistic Tour No.")));
            Caption = 'Total Quantity';
            Editable = false;
        }

        field(77012; "Estimated Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Total Weight (kg)';
            Editable = false;
        }

        field(77013; "Estimated Distance"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Distance (km)';
            Editable = false;
        }

        field(77014; "Estimated Duration"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Estimated Duration (hrs)';
            Editable = false;
        }

        field(77015; "Load Utilization"; Decimal)
        {
            DataClassification = ToBeClassified;

            Caption = 'Load Utilization (%)';
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(77016; "Created By"; code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = User."User Name";

        }
        field(77017; "Delivery Area"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(77018; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(77019; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "location"."code";
        }
        field(77020; "Shipping Agent Code"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent"."Code";
        }
        field(77021; "Warehouse Employees"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Employee"."User ID";
        }

        field(77028; "Start Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Start Location';
            TableRelation = Location.Code;
        }

        field(77029; "End Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'End Location';
            TableRelation = Location.Code;
        }
        field(77030; "Conveyor Attendant"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Conveyor Attendant';
            TableRelation = Resource."No." WHERE("Type" = CONST(Person), "Resource Group No." = CONST('Conveyor Attendant'));
        }


    }
    keys
    {
        key(PK; "Logistic Tour No.") { Clustered = true; }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
        SetupRec: Record "Sales & Receivables Setup";
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
    end;
}