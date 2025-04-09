// table 50140 "Expédition"
// {
//     DataClassification = CustomerContent;

//     fields
//     {
//         field(1; "No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             NotBlank = true;
//         }

//         field(2; "Date de Tournée"; Date)
//         {
//             DataClassification = CustomerContent;
//         }

//         field(3; "Driver No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             Caption = 'Chauffeur';
//             TableRelation = Resource."No." where("Type" = const(Person));
//         }

//         field(4; "Véhicule No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             Caption = 'Véhicule';
//             TableRelation = Resource."No." where("Type" = const(Machine));
//         }

//         field(5; "Statut"; Option)
//         {
//             DataClassification = CustomerContent;
//             OptionMembers = Brouillon,Planifiée,EnCours,Terminée;
//         }

//         field(6; "Commentaire"; Text[100])
//         {
//             DataClassification = CustomerContent;
//         }

//     }

//     keys
//     {
//         key(PK; "No.") { Clustered = true; }
//     }
// }
