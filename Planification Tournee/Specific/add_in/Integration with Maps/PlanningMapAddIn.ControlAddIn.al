controladdin PlanningMapAddIn
{
    // Propriétés générales
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumHeight = 400;
    MinimumWidth = 600;

    // Scripts
    StartupScript = 'script\planning-map-startup.js';
    Scripts = 'script/planning-map.js', 'https://www.bing.com/api/maps/mapcontrol?callback=GetMap';

    // Feuilles de style
    StyleSheets = 'style/planning-map.css';

    // Procédures appelées depuis AL vers le control add-in
    procedure UpdateLocations(locationsJSON: Text);
    procedure CalculateOptimalRoute(startLocationId: Text; algorithm: Text);
    procedure ClearRoute();
    procedure HighlightLocation(locationId: Text);
    procedure SetBingMapsKey(apiKey: Text);
    procedure SetMapParameters(mapParamsJSON: Text);

    // Événements exposés à AL
    event OnControlReady();
    event OnLocationSelected(locationId: Text; locationInfo: Text);
    event OnRouteCalculated(routeInfo: Text; totalDistance: Decimal; totalTime: Decimal);
}