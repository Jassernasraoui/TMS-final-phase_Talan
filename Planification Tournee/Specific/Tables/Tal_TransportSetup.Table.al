// table 50104 "Transport Setup"
// {
//     DataClassification = CustomerContent;
//     Caption = 'Paramètres Transport';

//     fields
//     {
//         field(1; "Code"; Code[10])
//         {
//             Caption = 'Code';
//             DataClassification = CustomerContent;
//         }
//         field(2; "Série Fiches Chargement"; Code[20])
//         {
//             Caption = 'Série Fiches Chargement';
//             TableRelation = "No. Series";
//             DataClassification = CustomerContent;
//         }
//         field(3; "Série Itinéraires"; Code[20])
//         {
//             Caption = 'Série Itinéraires';
//             TableRelation = "No. Series";
//             DataClassification = CustomerContent;
//         }
//     }

//     keys
//     {
//         key(PK; "Code")
//         {
//             Clustered = true;
//         }
//     }
// }