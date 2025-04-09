// table 50130 "Tour Planning Header "
// {
//     fields
//     {
//         field(50002; "Véhicule No."; Code[20])
//         {
//             DataClassification = CustomerContent;
//             TableRelation = "Resource"." License plate No.";
//         }

//         field(50001; "Chauffeur ID"; Code[20])
//         {
//             DataClassification = CustomerContent;
//             TableRelation = "resource"."No.";
//         }

//         field(50000; "Date"; Date)
//         {
//             DataClassification = CustomerContent;
//         }

//         field(50003; "Statut"; Option)
//         {
//             OptionMembers = "Brouillon","Validé","Terminé";
//             DataClassification = CustomerContent;
//         }

//         // 🏗 Champs supplémentaires à ajouter plus tard
//         // field(50004; "Autre Champ 1"; Type) { ... }
//         // field(50005; "Autre Champ 2"; Type) { ... }
//     }
// }
