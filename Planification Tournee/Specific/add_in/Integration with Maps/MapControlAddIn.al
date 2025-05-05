// // Déclaration corrigée du contrôle add-in
// controladdin MapControl
// {
//     // Erreur AL0327: Les fichiers doivent être inclus dans le package
//     // Au lieu de référencer les fichiers locaux, vous devez les inclure dans le package
//     Scripts = 'https://maps.googleapis.com/maps/api/js?key=VOTRE_CLE_API_GOOGLE_MAPS',
//               '/MapControl.js';
//     StyleSheets = '/MapControl.css';

//     // Erreur sur InitializeControl() - il doit s'agir du nom du script, pas de l'appel de fonction
//     StartupScript = 'C:\Users\Jass\Documents\AL\V0\Planification Tournee\Specific\add_in\StartupScript';

//     VerticalStretch = true;
//     HorizontalStretch = true;
//     VerticalShrink = true;
//     HorizontalShrink = true;
//     MinimumHeight = 400;
//     MinimumWidth = 600;
//     MaximumHeight = 800;
//     MaximumWidth = 1200;

//     // Déclarer les événements
//     event ControlAddInReady();
//     event MarkerClicked(LocationId: Text);

//     // Erreur AL0416: Les méthodes ne peuvent pas avoir de valeur de retour
//     procedure InitializeMap();
//     procedure AddMarker(Id: Text; Latitude: Decimal; Longitude: Decimal; Title: Text; Description: Text);
//     procedure ClearMarkers();
//     procedure SetCenter(Latitude: Decimal; Longitude: Decimal);
// }