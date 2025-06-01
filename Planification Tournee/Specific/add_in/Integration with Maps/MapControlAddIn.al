controladdin GoogleMapCtrl
{
    Scripts =
        'https://maps.googleapis.com/maps/api/js?key=API_KEY&callback=initMap',
        'Planification Tournee/Specific/add_in/Integration with Maps/script1.js';
    StartupScript = 'Planification Tournee/Specific/add_in/Integration with Maps/startup1.js';

    RequestedHeight = 700;
    RequestedWidth = 800;
    MinimumHeight = 700;
    MinimumWidth = 800;
    MaximumHeight = 700;
    MaximumWidth = 800;
    VerticalShrink = true;
    HorizontalShrink = true;
    VerticalStretch = true;
    HorizontalStretch = true;

    event ControlReady();
    procedure updateMapPosition(lat: Decimal; lng: Decimal);
}
