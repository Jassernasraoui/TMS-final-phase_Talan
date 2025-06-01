function updateMapPosition(lat, lng) {
    var position = new google.maps.LatLng(lat, lng);
    
    if (!window.marker) {
        window.marker = new google.maps.Marker({
            position: position,
            map: window.ctrlGoogleMap,
            title: 'Position Actuelle'
        });
    } else {
        window.marker.setPosition(position);
    }
    window.ctrlGoogleMap.setCenter(position);
}