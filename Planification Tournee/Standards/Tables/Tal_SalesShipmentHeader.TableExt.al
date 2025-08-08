// tableextension 73503 "Tal Sales Shipment Header" extends "Sales Shipment Header"
// {
//     fields
//     {
//         field(73501; "Logistic Tour No."; Code[20])
//         {
//             Caption = 'Logistic Tour No.';
//             DataClassification = CustomerContent;
//             TableRelation = "No. Series";
//         }

//         field(73502; "Date de Tournée"; Date)
//         {
//             Caption = 'Date de Tournée';
//             DataClassification = CustomerContent;
//         }

//         field(73503; "Driver No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             Caption = 'Chauffeur';
//             TableRelation = Resource."No." where("Type" = const(Person));
//         }

//         field(73504; "Véhicule No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             Caption = 'Véhicule';
//             TableRelation = Resource."No." where("Type" = const(Machine));
//         }

//         field(73505; "Statut"; Option)
//         {
//             Caption = 'Statut';
//             OptionMembers = Initial,Planifiée,EnCours,Terminée;
//             OptionCaption = 'Initial,Planned,In Progress,Completed';
//             DataClassification = CustomerContent;
//         }

//         field(73506; "Commentaire"; Text[250])
//         {
//             Caption = 'Commentaire';
//             DataClassification = CustomerContent;
//         }
//     }
// }
