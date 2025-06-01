controladdin PlanningCalendarAddIn
{
    // Fichiers de ressources externes
    Scripts = 'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js',
             'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/locales/fr.js',
             'script/calender.js';
    StyleSheets = 'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css',
                 'style/calender.css';
    StartupScript = 'script/calender.js';

    // Dimensions
    RequestedHeight = 600;
    RequestedWidth = 1000;
    MinimumHeight = 400;
    MinimumWidth = 800;

    // Propriétés d'étirement
    VerticalStretch = true;
    HorizontalStretch = true;

    // Événements exposés vers AL
    event OnDateChanged(selectedDate: Text);
    event OnControlReady();

    // Méthodes appelables depuis AL
    procedure UpdateCalendarEvents(eventsJSON: Text);
}