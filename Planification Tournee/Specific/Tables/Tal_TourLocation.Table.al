// table 50140 "Tour Location"
// {
//     DataClassification = CustomerContent;

//     fields
//     {
//         field(1; "No."; Code[20])
//         {
//             Caption = 'No.';
//         }
//         field(2; "Name"; Text[100])
//         {
//             Caption = 'Nom';
//         }
//         field(3; "Address"; Text[100])
//         {
//             Caption = 'Adresse';
//         }
//         field(4; "City"; Text[50])
//         {
//             Caption = 'Ville';
//         }
//         field(5; "Postal Code"; Code[20])
//         {
//             Caption = 'Code postal';
//         }
//         field(6; "Country/Region Code"; Code[10])
//         {
//             Caption = 'Code pays/région';
//             TableRelation = "Country/Region";
//         }
//         field(7; "Phone No."; Text[30])
//         {
//             Caption = 'N° téléphone';
//         }
//         field(8; "Latitude"; Decimal)
//         {
//             Caption = 'Latitude';
//             DecimalPlaces = 8 : 8;
//         }
//         field(9; "Longitude"; Decimal)
//         {
//             Caption = 'Longitude';
//             DecimalPlaces = 8 : 8;
//         }
//         field(10; "Description"; Text[250])
//         {
//             Caption = 'Description';
//         }
//     }

//     keys
//     {
//         key(PK; "No.")
//         {
//             Clustered = true;
//         }
//     }
// }