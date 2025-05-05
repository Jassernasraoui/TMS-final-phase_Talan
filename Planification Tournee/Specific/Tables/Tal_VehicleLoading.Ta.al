// table 50130 "Vehicle Loading"
// {
//     DataClassification = ToBeClassified;

//     fields
//     {
//         field(1; "Tour No."; Code[20])
//         {
//             Caption = 'Logistic Tour No.';
//             DataClassification = CustomerContent;
//             TableRelation = "Planification Header"."Logistic Tour No.";
//             NotBlank = true;
//         }

//         field(2; "Loading Date"; Date)
//         {
//             Caption = 'Loading Date';
//             DataClassification = ToBeClassified;
//         }

//         field(3; "Vehicle No."; Code[20])
//         {
//             Caption = 'Vehicle Number';
//             DataClassification = CustomerContent;
//         }

//         field(4; "Driver Name"; Text[100])
//         {
//             Caption = 'Driver Name';
//             DataClassification = ToBeClassified;
//         }

//         field(5; "Loading Location"; Text[100])
//         {
//             Caption = 'Loading Location';
//             DataClassification = ToBeClassified;
//         }

//         field(6; "Destination"; Text[100])
//         {
//             Caption = 'Destination';
//             DataClassification = ToBeClassified;
//         }

//         field(7; "Cargo Description"; Text[100])
//         {
//             Caption = 'Cargo Description';
//             DataClassification = ToBeClassified;
//         }

//         field(8; "Weight (kg)"; Decimal)
//         {
//             Caption = 'Weight (kg)';
//             DataClassification = ToBeClassified;
//         }

//         field(9; "Hazardous Material"; Boolean)
//         {
//             Caption = 'Hazardous Material';
//             DataClassification = ToBeClassified;
//         }
//     }

//     keys
//     {
//         key(PK; "Tour No.") { Clustered = true; }
//     }
// }
