table 50147 "Expédition Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(6; "Logistic Tour No."; Code[20])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TourNo: Record "Expédition Header";
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

        field(2; "Date de Tournée"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Driver No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chauffeur';
            TableRelation = Resource."No." where("Type" = const(Person));
        }

        field(4; "Véhicule No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Véhicule';
            TableRelation = Resource."No." where("Type" = const(Machine));
        }

        field(5; "Statut"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Planifiée,"En cours",Terminée;
            OptionCaption = 'Planifiée,En cours,Terminée';
        }

        field(7; "Commentaire"; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
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
    end;
}