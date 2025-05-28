table 77050 "Tour Execution Tracking"
{
    DataClassification = CustomerContent;
    Caption = 'Suivi d''Exécution de Tournée';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'N° Ligne';
            DataClassification = CustomerContent;
        }
        field(2; "Tour No."; Code[20])
        {
            Caption = 'N° Tournée';
            DataClassification = CustomerContent;
            TableRelation = "Planification Header"."Logistic Tour No.";
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'N° Client';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name;
            end;
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Nom du Client';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Planning Line No."; Integer)
        {
            Caption = 'N° Ligne de Planification';
            DataClassification = CustomerContent;
            TableRelation = "Planning Lines"."Line No." where("Logistic Tour No." = field("Tour No."));
        }
        field(6; Status; Option)
        {
            Caption = 'Statut';
            OptionMembers = "En Attente","En Cours","Livré","Échoué","Reporté";
            OptionCaption = 'En Attente,En Cours,Livré,Échoué,Reporté';
            DataClassification = CustomerContent;
        }
        field(7; "Date Livraison"; Date)
        {
            Caption = 'Date de Livraison';
            DataClassification = CustomerContent;
        }
        field(8; "Heure Livraison"; Time)
        {
            Caption = 'Heure de Livraison';
            DataClassification = CustomerContent;
        }
        field(9; "Notes Livraison"; Text[250])
        {
            Caption = 'Notes de Livraison';
            DataClassification = CustomerContent;
        }
        field(10; "Signature Client"; Blob)
        {
            Caption = 'Signature Client';
            DataClassification = CustomerContent;
        }
        field(11; "GPS Coordonnées"; Text[50])
        {
            Caption = 'Coordonnées GPS';
            DataClassification = CustomerContent;
        }
        field(12; "Tournée Terminée"; Boolean)
        {
            Caption = 'Tournée Terminée';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Modified By"; Code[50])
        {
            Caption = 'Modifié Par';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(14; "Modified Date"; DateTime)
        {
            Caption = 'Date de Modification';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Line No.", "Tour No.")
        {
            Clustered = true;
        }
        key(Key2; "Tour No.", "Customer No.")
        {
        }
        key(Key3; "Tour No.", Status)
        {
        }
    }

    trigger OnInsert()
    begin
        "Modified By" := UserId;
        "Modified Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified By" := UserId;
        "Modified Date" := CurrentDateTime;
    end;
}