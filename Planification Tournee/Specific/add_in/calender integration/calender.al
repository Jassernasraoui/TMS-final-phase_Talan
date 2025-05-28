controladdin SimpleCalendarAddIn
{
    // Fichiers JavaScript à charger
    Scripts = 'Planification Tournee/Specific/Scripts/calender.js';
    
    // Fichiers CSS à charger
    StyleSheets = 'Planification Tournee/Specific/Scripts/calender.css';
    
    // Script d'initialisation (s'exécute au démarrage du contrôle)
    StartupScript = 'Planification Tournee/Specific/Scripts/calender.js';
    
    // Dimensions par défaut
    RequestedHeight = 400;
    RequestedWidth = 800;
    
    // Permet au contrôle de s'étendre
    VerticalStretch = true;
    HorizontalStretch = true;
    
    // Événements exposés vers AL
    event OnDateChanged(selectedDate: Text);
    event OnControlReady();
}