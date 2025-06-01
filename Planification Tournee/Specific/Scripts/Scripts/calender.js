// calender.js - Script principal pour le calendrier de planning
(function () {
    console.log("🚀 StartupScript: Initialisation du calendrier...");
    
    // Variable globale pour éviter les initialisations multiples
    window.CalendarInitialized = window.CalendarInitialized || false;
    
    // Fonction principale d'initialisation
    function initializeCalendar() {
        // Éviter les initialisations multiples
        if (window.CalendarInitialized) {
            console.log("📅 Calendrier déjà initialisé, arrêt");
            return;
        }
        
        console.log("📅 Création de l'interface calendrier...");
        
        try {
            // Charger FullCalendar et ses dépendances
            loadExternalScripts([
                'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js',
                'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/locales/fr.js'
            ], function() {
                loadExternalStyles([
                    'https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css'
                ], function() {
                    // Une fois les scripts chargés, créer l'interface
                    createCalendarInterface();
                });
            });
            
        } catch (error) {
            console.error("❌ Erreur lors de l'initialisation:", error);
            document.body.innerHTML = `
                <div style="padding: 20px; color: red;">
                    <h3>❌ Erreur d'initialisation</h3>
                    <p>Détails: ${error.message}</p>
                </div>
            `;
        }
    }

    // Charger des scripts externes de façon séquentielle
    function loadExternalScripts(urls, callback, index = 0) {
        if (index >= urls.length) {
            if (callback) callback();
            return;
        }
        
        const script = document.createElement('script');
        script.src = urls[index];
        script.onload = function() {
            loadExternalScripts(urls, callback, index + 1);
        };
        script.onerror = function() {
            console.error("Erreur de chargement du script:", urls[index]);
            loadExternalScripts(urls, callback, index + 1);
        };
        document.head.appendChild(script);
    }

    // Charger des feuilles de style externes
    function loadExternalStyles(urls, callback) {
        let loaded = 0;
        
        for (const url of urls) {
            const link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = url;
            link.onload = function() {
                loaded++;
                if (loaded === urls.length && callback) callback();
            };
            link.onerror = function() {
                console.error("Erreur de chargement du style:", url);
                loaded++;
                if (loaded === urls.length && callback) callback();
            };
            document.head.appendChild(link);
        }
        
        // Si aucun style à charger, exécuter le callback immédiatement
        if (urls.length === 0 && callback) callback();
    }
    
    function createCalendarInterface() {
        // Nettoyer le contenu existant
        document.body.innerHTML = '';
        
        // Créer la structure HTML
        const calendarHTML = `
            <div id="calendarWrapper">
                <div id="planningCalendarContainer">
                    <div id="calendarHeader">
                        <h3>📅 Calendrier Planning</h3>
                        <div id="status">✅ Prêt</div>
                    </div>
                    <div id="calendar"></div>
                </div>
                <div id="planningDetails">
                    <h3>📋 Détails Planning</h3>
                    <div id="selectedDateInfo">
                        <p>👉 Sélectionnez une date sur le calendrier</p>
                    </div>
                    <div id="planningData"></div>
                </div>
            </div>
        `;
        
        document.body.innerHTML = calendarHTML;
        
        // Initialiser FullCalendar
        initFullCalendar();
        
        // Marquer comme initialisé
        window.CalendarInitialized = true;
        
        // Notifier AL que le contrôle est prêt
        notifyControlReady();
        
        console.log("✅ Calendrier initialisé avec succès");
    }
    
    function initFullCalendar() {
        const calendarEl = document.getElementById('calendar');
        if (!calendarEl) {
            console.error("Élément calendar non trouvé");
            return;
        }
        
        // Créer l'instance du calendrier
        window.planningCalendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,listWeek'
            },
            locale: 'fr',
            businessHours: {
                daysOfWeek: [1, 2, 3, 4, 5], // Lundi - Vendredi
                startTime: '08:00',
                endTime: '18:00',
            },
            selectable: true,
            selectMirror: true,
            dayMaxEvents: true,
            eventDisplay: 'block',
            eventColor: '#0078d4',
            
            // Événements de sélection et de clic
            dateClick: function(info) {
                handleDateSelection(info.dateStr);
            },
            select: function(info) {
                handleDateSelection(info.startStr);
            },
            eventClick: function(info) {
                // Pour l'instant, sélectionner simplement la date de l'événement
                handleDateSelection(info.event.startStr.split('T')[0]);
            }
        });
        
        // Afficher le calendrier
        window.planningCalendar.render();
        
        // Ajouter des données de démonstration (en mode développement)
        addSampleEvents();
    }
    
    function addSampleEvents() {
        // Seulement en mode développement pour tester l'affichage
        try {
            if (typeof Microsoft === 'undefined') { // En mode développement
                const today = new Date();
                const events = [];
                
                // Générer quelques événements pour les 2 prochaines semaines
                for (let i = -5; i < 15; i++) {
                    if (Math.random() > 0.7) { // Ajouter un événement aléatoirement
                        const date = new Date(today);
                        date.setDate(date.getDate() + i);
                        const dateStr = date.toISOString().split('T')[0];
                        
                        const eventCount = Math.floor(Math.random() * 3) + 1;
                        const eventTitle = `${eventCount} livraison${eventCount > 1 ? 's' : ''}`;
                        
                        events.push({
                            title: eventTitle,
                            start: dateStr,
                            backgroundColor: getRandomColor(eventCount),
                            borderColor: getRandomColor(eventCount),
                            extendedProps: {
                                count: eventCount
                            }
                        });
                    }
                }
                
                // Ajouter les événements au calendrier
                window.planningCalendar.addEventSource(events);
            }
        } catch (e) {
            console.log("Mode développement - pas d'ajout d'événements de test");
        }
    }
    
    function getRandomColor(count) {
        // Couleurs en fonction du nombre d'événements
        const colors = [
            '#0078d4', // Bleu - par défaut
            '#107c10', // Vert - peu d'événements
            '#ffaa44', // Orange - événements modérés
            '#d13438'  // Rouge - beaucoup d'événements
        ];
        
        if (count <= 1) return colors[1];      // Vert pour 1 événement
        else if (count <= 3) return colors[2]; // Orange pour 2-3 événements
        else return colors[3];                 // Rouge pour 4+ événements
    }
    
    function handleDateSelection(dateStr) {
        console.log("📅 Date sélectionnée:", dateStr);
        
        // Mise à jour de l'interface
        updateStatus("🔄 Envoi en cours...", "#0078d4");
        updateSelectedDateInfo(dateStr, true);
        
        // Envoyer vers AL
        sendDateToBusinessCentral(dateStr);
        
        // Mettre en évidence la date sélectionnée
        highlightSelectedDate(dateStr);
    }
    
    function highlightSelectedDate(dateStr) {
        // Réinitialiser les sélections précédentes
        document.querySelectorAll('.fc-day-today').forEach(el => {
            el.classList.remove('fc-day-today');
        });
        
        // Trouver la cellule correspondant à la date et la mettre en évidence
        const dateCell = document.querySelector(`.fc-day[data-date="${dateStr}"]`);
        if (dateCell) {
            dateCell.classList.add('fc-day-today');
        }
        
        // Naviguer vers cette date si elle n'est pas visible
        window.planningCalendar.gotoDate(dateStr);
    }
    
    function updateStatus(message, color = "#605e5c") {
        const status = document.getElementById("status");
        if (status) {
            status.textContent = message;
            status.style.color = color;
        }
    }
    
    function updateSelectedDateInfo(selectedDate, isLoading = false) {
        const selectedDateInfo = document.getElementById("selectedDateInfo");
        if (!selectedDateInfo) return;
        
        const formattedDate = formatDate(selectedDate);
        
        if (isLoading) {
            selectedDateInfo.innerHTML = `
                <h4>📅 ${formattedDate}</h4>
                <p>🔄 Transmission vers Business Central...</p>
            `;
        } else {
            selectedDateInfo.innerHTML = `
                <h4>📅 ${formattedDate}</h4>
                <p>Détails du planning pour cette journée</p>
            `;
        }
    }
    
    function sendDateToBusinessCentral(selectedDate) {
        try {
            // Vérifier si l'API Business Central est disponible
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV &&
                typeof Microsoft.Dynamics.NAV.InvokeExtensibilityMethod === 'function') {
                
                console.log("📤 Envoi vers Business Central:", selectedDate);
                
                // Appeler l'événement AL
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnDateChanged", [selectedDate]);
                
                // Mise à jour succès
                updateStatus("✅ Envoyé à AL", "#107c10");
                
                setTimeout(() => {
                    const planningData = document.getElementById("planningData");
                    if (planningData) {
                        planningData.innerHTML = `
                            <div style="margin-top: 20px; padding: 15px; background-color: #f0f9ff; border-left: 4px solid #0078d4;">
                                <p><strong>Date sélectionnée:</strong> ${formatDate(selectedDate)}</p>
                                <p><strong>Statut:</strong> Transmis à AL avec succès</p>
                            </div>
                        `;
                    }
                }, 500);
                
            } else {
                throw new Error("API Business Central non disponible");
            }
            
        } catch (error) {
            console.error("❌ Erreur envoi AL:", error);
            
            // Mode développement/test
            updateStatus("⚠️ Mode test", "#ff8c00");
            
            const planningData = document.getElementById("planningData");
            if (planningData) {
                planningData.innerHTML = `
                    <div style="margin-top: 20px; padding: 15px; background-color: #fff3cd; border-left: 4px solid #ff8c00;">
                        <p><strong>Date sélectionnée:</strong> ${formatDate(selectedDate)}</p>
                        <p><strong>Mode:</strong> Test/Développement</p>
                        <p><strong>Note:</strong> L'API Business Central sera disponible une fois déployé</p>
                    </div>
                `;
            }
        }
    }
    
    // Fonction pour mettre à jour le calendrier avec des événements provenant de BC
    window.updateCalendarEvents = function(eventsJSON) {
        if (!window.planningCalendar) return;
        
        console.log("📊 Mise à jour des événements du calendrier");
        
        try {
            // Supprimer les événements existants
            window.planningCalendar.getEventSources().forEach(source => source.remove());
            
            // Analyser le JSON reçu de Business Central
            let events = [];
            
            if (eventsJSON && eventsJSON.trim() !== '') {
                // Essayer de parser le JSON
                try {
                    events = JSON.parse(eventsJSON);
                    console.log(`📅 ${events.length} événements chargés depuis AL`);
                } catch (parseError) {
                    console.error("❌ Erreur de parsing JSON:", parseError);
                    console.log("JSON reçu:", eventsJSON);
                }
            }
            
            // Ajouter les nouveaux événements au calendrier
            if (Array.isArray(events) && events.length > 0) {
                window.planningCalendar.addEventSource(events);
                
                // Mettre à jour le statut
                updateStatus(`✅ ${events.length} événements chargés`, "#107c10");
            } else {
                console.log("ℹ️ Aucun événement à ajouter ou format incorrect");
                
                // En mode développement, ajouter des événements de test
                if (typeof Microsoft === 'undefined') {
                    addSampleEvents();
                    updateStatus("⚠️ Mode test - Événements de démonstration", "#ff8c00");
                } else {
                    updateStatus("ℹ️ Aucun événement disponible", "#605e5c");
                }
            }
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des événements:", error);
            updateStatus("❌ Erreur calendrier", "#d13438");
        }
    };
    
    function notifyControlReady() {
        try {
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV &&
                typeof Microsoft.Dynamics.NAV.InvokeExtensibilityMethod === 'function') {
                
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnControlReady", []);
                console.log("📢 Notification OnControlReady envoyée");
            }
        } catch (error) {
            console.log("ℹ️ OnControlReady non disponible (mode dev)");
        }
    }
    
    function formatDate(dateString) {
        try {
            const date = new Date(dateString + 'T00:00:00');
            return date.toLocaleDateString('fr-FR', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        } catch (e) {
            return dateString;
        }
    }
    
    // === POINTS D'ENTRÉE ===
    
    // 1. StartupScript - s'exécute immédiatement
    console.log("🎯 StartupScript démarré");
    
    // 2. DOM Ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeCalendar);
    } else if (document.readyState === 'interactive' || document.readyState === 'complete') {
        // DOM déjà prêt
        initializeCalendar();
    }
    
    // 3. Window load (backup)
    window.addEventListener('load', function() {
        if (!window.CalendarInitialized) {
            console.log("🔄 Initialisation via window.load");
            initializeCalendar();
        }
    });
    
    // 4. Timeout de sécurité
    setTimeout(function() {
        if (!window.CalendarInitialized) {
            console.log("⏰ Initialisation via timeout de sécurité");
            initializeCalendar();
        }
    }, 500);
    
    console.log("📋 Script calender.js chargé et configuré");
    
})();