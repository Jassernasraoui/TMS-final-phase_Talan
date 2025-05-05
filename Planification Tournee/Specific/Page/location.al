// // Correction de la page extension pour utiliser l'Add-in
// pageextension 50130 "Tour Planning Map Extension" extends "Planification Document" // Nom réel de votre page
// {
//     layout
//     {
//         // Trouvez un groupe existant dans votre page où ajouter la carte
//         addlast(Content) // Vous pouvez remplacer 'Content' par le nom d'un groupe existant
//         {
//             group(MapGroup)
//             {
//                 Caption = 'Carte';

//                 usercontrol(MapControl; MapControl)
//                 {
//                     ApplicationArea = All;

//                     trigger ControlAddInReady()
//                     begin
//                         CurrPage.MapControl.InitializeMap();
//                         LoadLocationMarkers();
//                     end;

//                     trigger MarkerClicked(LocationId: Text)
//                     var
//                         LocationRec: Record "Tour Location"; // Remplacez par le nom réel de votre table
//                     begin
//                         if Evaluate(LocationRec."No.", LocationId) then
//                             if LocationRec.Get(LocationRec."No.") then
//                                 Message('Emplacement sélectionné: %1', LocationRec.Name);
//                     end;
//                 }
//             }
//         }
//     }

//     actions
//     {
//         // Au lieu d'utiliser 'addafter' avec une action qui n'existe pas,
//         // utilisez 'addlast' avec une section d'action existante
//         addlast(Processing) // Sections courantes: Processing, Navigation, Reporting
//         {
//             action(RefreshMap)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Rafraîchir la carte';
//                 Image = Refresh;

//                 trigger OnAction()
//                 begin
//                     LoadLocationMarkers();
//                 end;
//             }
//         }
//     }

//     // Le reste de votre code reste identique
//     procedure LoadLocationMarkers()
//     var
//         LocationRec: Record "Tour Location"; // Remplacez par le nom réel de votre table
//         CenterLatitude: Decimal;
//         CenterLongitude: Decimal;
//         LocationCount: Integer;
//     begin
//         // Effacer tous les marqueurs existants
//         CurrPage.MapControl.ClearMarkers();

//         // Variables pour calculer le centre de la carte
//         CenterLatitude := 0;
//         CenterLongitude := 0;
//         LocationCount := 0;

//         // Parcourir tous les emplacements et les ajouter à la carte
//         if LocationRec.FindSet() then
//             repeat
//                 // Vérifier que les coordonnées sont valides
//                 if (LocationRec.Latitude <> 0) and (LocationRec.Longitude <> 0) then
//                 begin
//                     // Ajouter un marqueur pour cet emplacement
//                     CurrPage.MapControl.AddMarker(
//                         Format(LocationRec."No."),
//                         LocationRec.Latitude,
//                         LocationRec.Longitude,
//                         LocationRec.Name,
//                         GetLocationDescription(LocationRec)
//                     );

//                     // Mettre à jour les coordonnées du centre
//                     CenterLatitude += LocationRec.Latitude;
//                     CenterLongitude += LocationRec.Longitude;
//                     LocationCount += 1;
//                 end;
//             until LocationRec.Next() = 0;

//         // Définir le centre de la carte comme la moyenne des coordonnées
//         if LocationCount > 0 then
//             CurrPage.MapControl.SetCenter(CenterLatitude / LocationCount, CenterLongitude / LocationCount);
//     end;

//     procedure GetLocationDescription(LocationRec: Record "Tour Location"): Text
//     var
//         Description: Text;
//     begin
//         Description := '<div class="info-window">';
//         Description += '<h3>' + LocationRec.Name + '</h3>';

//         if LocationRec.Address <> '' then
//             Description += '<p>' + LocationRec.Address;

//         if LocationRec."Postal Code" <> '' then
//             Description += '<br>' + LocationRec."Postal Code";

//         if LocationRec.City <> '' then
//             Description += ' ' + LocationRec.City + '</p>';

//         if LocationRec.Description <> '' then
//             Description += '<p>' + LocationRec.Description + '</p>';

//         Description += '</div>';

//         exit(Description);
//     end;
// }