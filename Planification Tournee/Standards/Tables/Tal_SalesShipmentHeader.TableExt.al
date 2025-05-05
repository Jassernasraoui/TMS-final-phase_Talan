tableextension 50119 "Tal Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(50100; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(50101; "Date de Tournée"; Date)
        {
            Caption = 'Date de Tournée';
            DataClassification = CustomerContent;
        }

        field(700; "Driver No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Chauffeur';
            TableRelation = Resource."No." where("Type" = const(Person));
        }

        field(744; "Véhicule No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Véhicule';
            TableRelation = Resource."No." where("Type" = const(Machine));
        }

        field(50104; "Statut"; Option)
        {
            Caption = 'Statut';
            OptionMembers = Initial,Planifiée,EnCours,Terminée;
            OptionCaption = 'Initial,Planned,In Progress,Completed';
            DataClassification = CustomerContent;
        }

        field(50105; "Commentaire"; Text[250])
        {
            Caption = 'Commentaire';
            DataClassification = CustomerContent;
        }
    }
}
