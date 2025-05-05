// var map;
// var markers = {};

// function InitializeMap() {
//     var mapOptions = {
//         center: new google.maps.LatLng(48.856614, 2.3522219), // Paris par défaut
//         zoom: 7,
//         mapTypeId: google.maps.MapTypeId.ROADMAP
//     };
    
//     map = new google.maps.Map(document.getElementById('controlAddIn'), mapOptions);
// }

// function AddMarker(id, latitude, longitude, title, description) {
//     if (!map) return;
    
//     var position = new google.maps.LatLng(latitude, longitude);
    
//     var marker = new google.maps.Marker({
//         position: position,
//         map: map,
//         title: title
//     });
    
//     var infoWindow = new google.maps.InfoWindow({
//         content: description
//     });
    
//     google.maps.event.addListener(marker, 'click', function() {
//         infoWindow.open(map, marker);
//         Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MarkerClicked', [id]);
//     });
    
//     markers[id] = marker;
// }

// function ClearMarkers() {
//     if (!map) return;
    
//     for (var id in markers) {
//         markers[id].setMap(null);
//     }
//     markers = {};
// }

// function SetCenter(latitude, longitude) {
//     if (!map) return;
    
//     var position = new google.maps.LatLng(latitude, longitude);
//     map.setCenter(position);
// }