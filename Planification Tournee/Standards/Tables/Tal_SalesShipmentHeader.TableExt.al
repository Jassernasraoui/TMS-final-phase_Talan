tableextension 77003 "Tal Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(77001; "Logistic Tour No."; Code[20])
        {
            Caption = 'Logistic Tour No.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(77002; "Date de Tournée"; Date)
        {
            Caption = 'Date de Tournée';
            DataClassification = CustomerContent;
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
            Caption = 'Statut';
            OptionMembers = Initial,Planifiée,EnCours,Terminée;
            OptionCaption = 'Initial,Planned,In Progress,Completed';
            DataClassification = CustomerContent;
        }

        field(77006; "Commentaire"; Text[250])
        {
            Caption = 'Commentaire';
            DataClassification = CustomerContent;
        }
    }
}
