// calender.js - Script principal pour le calendrier de planning BC
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
            // Créer directement l'interface - FullCalendar est déjà chargé par le control add-in
                    createCalendarInterface();
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
                right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
            },
            locale: 'fr',
            businessHours: {
                daysOfWeek: [1, 2, 3, 4, 5], // Lundi - Vendredi
                startTime: '08:00',
                endTime: '18:00',
            },
            slotDuration: '00:30:00', // Créneaux de 30 minutes
            slotLabelFormat: {
                hour: '2-digit',
                minute: '2-digit',
                hour12: false
            },
            selectable: true,
            selectMirror: true,
            dayMaxEvents: true,
            eventDisplay: 'block',
            eventColor: '#0078D4', // Bleu Business Central
            nowIndicator: true, // Indicateur "maintenant" dans les vues avec heures
            
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
                
                // Afficher les détails de l'événement
                showEventDetails(info.event);
            },
            datesSet: function(dateInfo) {
                // Mise à jour de l'interface en fonction de la vue actuelle
                updateInterfaceForView(dateInfo.view.type);
            }
        });
        
        // Afficher le calendrier
        window.planningCalendar.render();
    }
    
    function updateInterfaceForView(viewType) {
        // Ajuster l'interface selon la vue actuelle
        const container = document.getElementById('planningCalendarContainer');
        const details = document.getElementById('planningDetails');
        
        if (viewType === 'timeGridDay') {
            // Vue quotidienne - plus d'espace pour le planning
            container.style.flex = '3';
            details.style.flex = '1';
            
            // Adapter le titre du panneau de détails
            const detailsTitle = details.querySelector('h3');
            if (detailsTitle) {
                detailsTitle.innerHTML = '📋 Planning Journalier';
            }
            
            // Afficher le planning journalier
            showDailySchedule();
        } else {
            // Autres vues - retour à la mise en page normale
            container.style.flex = '2';
            details.style.flex = '1';
            
            // Rétablir le titre du panneau de détails
            const detailsTitle = details.querySelector('h3');
            if (detailsTitle) {
                detailsTitle.innerHTML = '📋 Détails Planning';
            }
        }
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
                
                // Afficher un état de chargement
                    const planningData = document.getElementById("planningData");
                    if (planningData) {
                        planningData.innerHTML = `
                        <div style="margin-top: 12px; padding: 10px; background-color: #f8f8f8; border-left: 4px solid #0078d7; font-size: 12px;">
                            <p>📊 Chargement des données de planning...</p>
                            <div class="loading" style="height: 2px; margin-top: 8px;"></div>
                            </div>
                        `;
                    }
                
            } else {
                throw new Error("API Business Central non disponible");
            }
            
        } catch (error) {
            console.error("❌ Erreur envoi AL:", error);
            updateStatus("⚠️ Mode test", "#ffaa44");
            
            // Montrer des données de test
            showTestData(selectedDate);
        }
    }
    
    function showTestData(selectedDate) {
        const planningData = document.getElementById("planningData");
        if (!planningData) return;
        
        // Créer des données de test pour la visualisation
        const mockItems = [
            { 
                type: 'Sales', 
                description: 'Livraison client ABC', 
                itemNo: 'ITEM001', 
                sourceID: 'SO10001', 
                quantity: 5, 
                priority: 'Normal',
                customerNo: 'CUST001'
            },
            { 
                type: 'Purchase', 
                description: 'Réception fournisseur XYZ', 
                itemNo: 'ITEM002', 
                sourceID: 'PO20001', 
                quantity: 10, 
                priority: 'High',
                vendorNo: 'VEND002'
            },
            { 
                type: 'Transfer', 
                description: 'Transfert entrepôt', 
                itemNo: 'ITEM003', 
                sourceID: 'TR30001', 
                quantity: 15, 
                priority: 'Low' 
            }
        ];
        
        // Afficher les données de test
        displayPlanningData(planningData, selectedDate, mockItems);
    }
    
    function showDailySchedule() {
        const planningData = document.getElementById("planningData");
        if (!planningData) return;
        
        // Obtenir la date sélectionnée
        const date = window.planningCalendar.getDate();
        const dateStr = date.toISOString().split('T')[0];
        
        // Mettre à jour l'interface
        updateSelectedDateInfo(dateStr, false);
        
        // En mode développement, afficher un planning quotidien de démonstration
        if (typeof Microsoft === 'undefined') {
            // Créer des données de démonstration
            const demoSchedule = createDemoSchedule(date);
            
            // Afficher le planning quotidien
            displayDailySchedule(planningData, dateStr, demoSchedule);
        } else {
            // En mode production, demander les données à Business Central
            sendDateToBusinessCentral(dateStr);
        }
    }
    
    function createDemoSchedule(date) {
        // Créer un planning quotidien de démonstration
        return [
            {
                time: '08:30',
                duration: 45,
                title: 'Livraison Client XYZ',
                location: 'Paris, 15ème',
                type: 'Sales',
                priority: 'High'
            },
            {
                time: '10:15',
                duration: 30,
                title: 'Collecte Fournisseur ABC',
                location: 'Nanterre',
                type: 'Purchase',
                priority: 'Normal'
            },
            {
                time: '13:00',
                duration: 60,
                title: 'Transfert entrepôt',
                location: 'Rungis',
                type: 'Transfer',
                priority: 'Low'
            },
            {
                time: '15:30',
                duration: 90,
                title: 'Livraison Client 123',
                location: 'Versailles',
                type: 'Sales',
                priority: 'Critical'
            }
        ];
    }
    
    function displayDailySchedule(container, dateStr, scheduleItems) {
        if (!container || !scheduleItems || scheduleItems.length === 0) {
            container.innerHTML = `
                <div class="bc-field">
                    <div class="bc-field-label">Date</div>
                    <div class="bc-field-value">${formatDate(dateStr)}</div>
                </div>
                <div style="margin-top: 12px; padding: 10px; background-color: #f8f8f8; border-left: 4px solid #0078d7; font-size: 12px;">
                    Aucune tournée planifiée pour cette journée.
                </div>
            `;
            return;
        }
        
        // Créer l'en-tête du planning
        let html = `
            <div class="bc-field">
                <div class="bc-field-label">Date</div>
                <div class="bc-field-value">${formatDate(dateStr)}</div>
            </div>
            <div class="bc-field">
                <div class="bc-field-label">Tournées planifiées</div>
                <div class="bc-field-value">${scheduleItems.length} arrêt(s)</div>
            </div>
            <div class="tour-schedule-container">
                <div class="tour-schedule-header">
                    <span>Planning de la journée</span>
                    <span>${formatDate(dateStr, { weekday: 'long' })}</span>
                </div>
                <div class="tour-schedule-body">
        `;
        
        // Trier les items par heure
        scheduleItems.sort((a, b) => {
            if (a.timeSlotStart && b.timeSlotStart) {
                return a.timeSlotStart.localeCompare(b.timeSlotStart);
            } else if (a.timeSlotStart) {
                return -1;
            } else if (b.timeSlotStart) {
                return 1;
            } else {
                return 0;
            }
        });
        
        // Ajouter chaque arrêt du planning
        scheduleItems.forEach(item => {
            let priorityClass = '';
            let priorityText = '';
            let typeIcon = '';
            let addressDetails = '';
            
            // Déterminer l'icône du type de document
            switch(item.type) {
                case 'Sales':
                    typeIcon = '🛒';
                    break;
                case 'Purchase':
                    typeIcon = '📦';
                    break;
                case 'Transfer':
                    typeIcon = '🔄';
                    break;
                default:
                    typeIcon = '📋';
            }
            
            // Déterminer le style de priorité
            switch(item.priority) {
                case 'Critical':
                    priorityClass = 'bc-priority-critical';
                    priorityText = '🔴 Critique';
                    break;
                case 'High':
                    priorityClass = 'bc-priority-high';
                    priorityText = '🟠 Haute';
                    break;
                case 'Normal':
                    priorityClass = 'bc-priority-normal';
                    priorityText = '🔵 Normale';
                    break;
                case 'Low':
                    priorityClass = 'bc-priority-low';
                    priorityText = '🟢 Basse';
                    break;
            }
            
            // Construire les détails d'adresse
            if (item.addressDetails) {
                const addr = item.addressDetails;
                
                // Adresse pour les commandes de vente
                if (item.type === 'Sales') {
                    if (addr.shipToName) {
                        addressDetails = `
                            <div class="tour-address-details">
                                <div class="address-title">📍 Adresse de livraison</div>
                                <div class="address-line">${addr.shipToName}</div>
                                ${addr.shipToAddress ? `<div class="address-line">${addr.shipToAddress}</div>` : ''}
                                ${addr.shipToPostCode || addr.shipToCity ? `<div class="address-line">${addr.shipToPostCode || ''} ${addr.shipToCity || ''}</div>` : ''}
                                ${addr.shipToContact ? `<div class="address-line">Contact: ${addr.shipToContact}</div>` : ''}
                                ${addr.shipToPhoneNo ? `<div class="address-line">📞 ${addr.shipToPhoneNo}</div>` : ''}
                                ${addr.shipToEmail ? `<div class="address-line">✉️ ${addr.shipToEmail}</div>` : ''}
                            </div>
                        `;
                    } else if (addr.name) {
                        addressDetails = `
                            <div class="tour-address-details">
                                <div class="address-title">📍 Adresse client</div>
                                <div class="address-line">${addr.name}</div>
                                ${addr.address ? `<div class="address-line">${addr.address}</div>` : ''}
                                ${addr.postCode || addr.city ? `<div class="address-line">${addr.postCode || ''} ${addr.city || ''}</div>` : ''}
                                ${addr.contact ? `<div class="address-line">Contact: ${addr.contact}</div>` : ''}
                                ${addr.phoneNo ? `<div class="address-line">📞 ${addr.phoneNo}</div>` : ''}
                                ${addr.email ? `<div class="address-line">✉️ ${addr.email}</div>` : ''}
                            </div>
                        `;
                    }
                }
                
                // Adresse pour les commandes d'achat
                else if (item.type === 'Purchase') {
                    let vendorDetails = '';
                    let locationDetails = '';
                    
                    if (addr.name) {
                        vendorDetails = `
                            <div class="address-title">🏭 Adresse fournisseur</div>
                            <div class="address-line">${addr.name}</div>
                            ${addr.address ? `<div class="address-line">${addr.address}</div>` : ''}
                            ${addr.postCode || addr.city ? `<div class="address-line">${addr.postCode || ''} ${addr.city || ''}</div>` : ''}
                            ${addr.contact ? `<div class="address-line">Contact: ${addr.contact}</div>` : ''}
                            ${addr.phoneNo ? `<div class="address-line">📞 ${addr.phoneNo}</div>` : ''}
                            ${addr.email ? `<div class="address-line">✉️ ${addr.email}</div>` : ''}
                        `;
                    }
                    
                    if (addr.locationName) {
                        locationDetails = `
                            <div class="address-title">📍 Adresse de livraison</div>
                            <div class="address-line">${addr.locationName}</div>
                            ${addr.locationAddress ? `<div class="address-line">${addr.locationAddress}</div>` : ''}
                            ${addr.locationPostCode || addr.locationCity ? `<div class="address-line">${addr.locationPostCode || ''} ${addr.locationCity || ''}</div>` : ''}
                            ${addr.locationContact ? `<div class="address-line">Contact: ${addr.locationContact}</div>` : ''}
                        `;
                    }
                    
                    if (vendorDetails || locationDetails) {
                        addressDetails = `
                            <div class="tour-address-details">
                                ${vendorDetails}
                                ${locationDetails ? `<div class="address-separator"></div>${locationDetails}` : ''}
                            </div>
                        `;
                    }
                }
                
                // Adresse pour les ordres de transfert
                else if (item.type === 'Transfer') {
                    let fromDetails = '';
                    let toDetails = '';
                    
                    if (addr.fromLocationName) {
                        fromDetails = `
                            <div class="address-title">🚚 Origine</div>
                            <div class="address-line">${addr.fromLocationName}</div>
                            ${addr.fromLocationAddress ? `<div class="address-line">${addr.fromLocationAddress}</div>` : ''}
                            ${addr.fromLocationPostCode || addr.fromLocationCity ? `<div class="address-line">${addr.fromLocationPostCode || ''} ${addr.fromLocationCity || ''}</div>` : ''}
                            ${addr.fromLocationContact ? `<div class="address-line">Contact: ${addr.fromLocationContact}</div>` : ''}
                        `;
                    }
                    
                    if (addr.toLocationName) {
                        toDetails = `
                            <div class="address-title">📍 Destination</div>
                            <div class="address-line">${addr.toLocationName}</div>
                            ${addr.toLocationAddress ? `<div class="address-line">${addr.toLocationAddress}</div>` : ''}
                            ${addr.toLocationPostCode || addr.toLocationCity ? `<div class="address-line">${addr.toLocationPostCode || ''} ${addr.toLocationCity || ''}</div>` : ''}
                            ${addr.toLocationContact ? `<div class="address-line">Contact: ${addr.toLocationContact}</div>` : ''}
                        `;
                    }
                    
                    if (fromDetails || toDetails) {
                        addressDetails = `
                            <div class="tour-address-details">
                                ${fromDetails}
                                ${toDetails ? `<div class="address-separator"></div>${toDetails}` : ''}
                            </div>
                        `;
                    }
                }
            }
            
            // Construire le créneau horaire
            let timeSlot = '';
            if (item.timeSlotStart) {
                timeSlot = item.timeSlotStart;
                if (item.timeSlotEnd) {
                    timeSlot += ` - ${item.timeSlotEnd}`;
                }
            }
            
            // Ajouter un arrêt de tournée avec les détails d'adresse
            html += `
                <div class="tour-stop ${priorityClass}">
                    <div class="tour-stop-header">
                        <div class="tour-stop-time">
                            ${timeSlot ? timeSlot : 'Horaire non défini'}
                            ${item.duration ? ` (${item.duration} min)` : ''}
                        </div>
                        ${priorityText ? `<div class="tour-stop-priority">${priorityText}</div>` : ''}
                    </div>
                    <div class="tour-stop-title">
                        ${typeIcon} ${item.description || item.itemNo || `${item.type}: ${item.sourceID}`}
                    </div>
                    <div class="tour-stop-details">
                        <div class="tour-stop-info">
                            <span class="detail-label">Document:</span> <span class="detail-value">${item.sourceID}</span>
                            ${item.quantity ? `<span class="detail-separator">•</span> <span class="detail-label">Quantité:</span> <span class="detail-value">${item.quantity}</span>` : ''}
                        </div>
                    </div>
                    ${addressDetails}
                </div>
            `;
        });
        
        // Fermer le conteneur
        html += `
                </div>
            </div>
        `;
        
        // Créer la vue des créneaux horaires
        html += `
            <div class="time-slot-view">
                <div class="time-slot-header">
                    <span>Calendrier journalier</span>
                    <span>${formatDate(dateStr, { weekday: 'long' })}</span>
                </div>
                <div id="dailyTimeline" class="daily-timeline"></div>
            </div>
        `;
        
        // Mettre à jour le conteneur
        container.innerHTML = html;
        
        // Initialiser la timeline des tournées (après avoir mis à jour le DOM)
        setTimeout(function() {
            initDailyTimeline('dailyTimeline', dateStr, scheduleItems);
        }, 100);
    }
    
    // Initialise une timeline qui montre les créneaux horaires de la journée
    function initDailyTimeline(containerId, dateStr, scheduleItems) {
        const container = document.getElementById(containerId);
        if (!container || !scheduleItems || scheduleItems.length === 0) return;
        
        // Filtrer uniquement les éléments avec des créneaux horaires
        const timeSlotItems = scheduleItems.filter(item => item.timeSlotStart);
        if (timeSlotItems.length === 0) {
            container.innerHTML = '<div class="timeline-empty">Aucun créneau horaire défini pour cette journée</div>';
            return;
        }
        
        // Convertir les créneaux en minutes depuis minuit pour le positionnement
        timeSlotItems.forEach(item => {
            if (item.timeSlotStart) {
                const [hours, minutes] = item.timeSlotStart.split(':').map(Number);
                item._startMinutes = hours * 60 + minutes;
            } else {
                item._startMinutes = 0;
            }
            
            if (item.timeSlotEnd) {
                const [hours, minutes] = item.timeSlotEnd.split(':').map(Number);
                item._endMinutes = hours * 60 + minutes;
            } else {
                item._endMinutes = item._startMinutes + 60; // Défaut 1 heure
            }
            
            // Calculer la durée
            item._duration = item._endMinutes - item._startMinutes;
        });
        
        // Trier par heure de début
        timeSlotItems.sort((a, b) => a._startMinutes - b._startMinutes);
        
        // Trouver l'heure de début et de fin pour dimensionner la timeline
        let minTime = Math.max(0, Math.min(...timeSlotItems.map(item => item._startMinutes)) - 60);
        let maxTime = Math.min(24 * 60, Math.max(...timeSlotItems.map(item => item._endMinutes)) + 60);
        
        // Arrondir aux heures
        minTime = Math.floor(minTime / 60) * 60;
        maxTime = Math.ceil(maxTime / 60) * 60;
        
        // S'assurer qu'on a au moins quelques heures d'affichées
        if (maxTime - minTime < 180) {
            const midPoint = (minTime + maxTime) / 2;
            minTime = Math.max(0, midPoint - 90);
            maxTime = Math.min(24 * 60, midPoint + 90);
        }
        
        // Calculer la largeur totale en minutes
        const totalMinutes = maxTime - minTime;
        
        // Générer l'HTML de la timeline
        let html = `
            <div class="timeline-container">
                <div class="timeline-hours">
        `;
        
        // Ajouter les marqueurs d'heure
        for (let hour = Math.floor(minTime / 60); hour <= Math.ceil(maxTime / 60); hour++) {
            const hourMinutes = hour * 60;
            const position = ((hourMinutes - minTime) / totalMinutes) * 100;
            
            if (position >= 0 && position <= 100) {
                html += `
                    <div class="timeline-hour-marker" style="left: ${position}%">
                        <div class="timeline-hour-label">${hour}:00</div>
                    </div>
                `;
            }
        }
        
        html += `
                </div>
                <div class="timeline-events">
        `;
        
        // Ajouter les événements
        timeSlotItems.forEach(item => {
            const startPosition = ((item._startMinutes - minTime) / totalMinutes) * 100;
            const width = (item._duration / totalMinutes) * 100;
            let eventColor = '#0078D4'; // Bleu Business Central par défaut
            
            // Déterminer la couleur en fonction de la priorité
            if (item.priority === 'Critical') {
                eventColor = '#d13438'; // Rouge
            } else if (item.priority === 'High') {
                eventColor = '#ffaa44'; // Orange
            } else if (item.priority === 'Low') {
                eventColor = '#107c10'; // Vert
            }
            
            // Ajouter l'événement
            html += `
                <div class="timeline-event" style="left: ${startPosition}%; width: ${width}%; background-color: ${eventColor};">
                    <div class="timeline-event-content">
                        <div class="timeline-event-time">${item.timeSlotStart}${item.timeSlotEnd ? ` - ${item.timeSlotEnd}` : ''}</div>
                        <div class="timeline-event-title">${item.description || item.itemNo || `${item.type}: ${item.sourceID}`}</div>
                    </div>
                </div>
            `;
        });
        
        html += `
                </div>
            </div>
        `;
        
        container.innerHTML = html;
    }
    
    function displayPlanningData(container, dateStr, planningItems) {
        if (!container) return;
        
        if (!planningItems || planningItems.length === 0) {
            container.innerHTML = `
                <div class="bc-field">
                    <div class="bc-field-label">Date</div>
                    <div class="bc-field-value">${formatDate(dateStr)}</div>
                </div>
                <div style="margin-top: 12px; padding: 10px; background-color: #f8f8f8; border-left: 4px solid #0078d7; font-size: 12px;">
                    Aucune donnée de planning pour cette date.
                </div>
            `;
            return;
        }
        
        // Create summary at the top
        let html = `
            <div class="bc-field">
                <div class="bc-field-label">Date</div>
                <div class="bc-field-value">${formatDate(dateStr)}</div>
            </div>
            <div class="bc-field">
                <div class="bc-field-label">Lignes de planning</div>
                <div class="bc-field-value">${planningItems.length} élément(s)</div>
            </div>
        `;
        
        // Add each planning item
        planningItems.forEach(item => {
            let typeClass = 'type-other';
            if (item.type === 'Sales') typeClass = 'type-sales';
            else if (item.type === 'Purchase') typeClass = 'type-purchase';
            else if (item.type === 'Transfer') typeClass = 'type-transfer';
            
            let priorityText = '';
            if (item.priority === 'Critical') priorityText = '🔴 Critique';
            else if (item.priority === 'High') priorityText = '🟠 Haute';
            else if (item.priority === 'Normal') priorityText = '🔵 Normale';
            else if (item.priority === 'Low') priorityText = '🟢 Basse';
            
            html += `
                <div class="planning-item ${typeClass}">
                    <h5>${item.description || item.itemNo || `${item.type}: ${item.sourceID}`}</h5>
                    <div class="planning-item-details">
                        <span><span class="label">Type:</span> <span class="value">${item.type}</span></span>
                        <span><span class="label">Qté:</span> <span class="value">${item.quantity}</span></span>
                        ${priorityText ? `<span><span class="label">Priorité:</span> <span class="value">${priorityText}</span></span>` : ''}
                    </div>
                    <div class="planning-item-details">
                        <span><span class="label">Doc:</span> <span class="value">${item.sourceID}</span></span>
                        ${item.customerNo ? `<span><span class="label">Client:</span> <span class="value">${item.customerNo}</span></span>` : ''}
                        ${item.vendorNo ? `<span><span class="label">Fourn.:</span> <span class="value">${item.vendorNo}</span></span>` : ''}
                    </div>
                </div>
            `;
        });
        
        container.innerHTML = html;
    }
    
    function showEventDetails(event) {
        // Afficher les détails de l'événement sélectionné
            const planningData = document.getElementById("planningData");
        if (!planningData) return;
        
        const props = event.extendedProps;
        const startTime = event.start ? formatTime(event.start) : '';
        const endTime = event.end ? formatTime(event.end) : '';
        
        let html = `
            <div class="bc-field">
                <div class="bc-field-label">Événement</div>
                <div class="bc-field-value">${event.title}</div>
            </div>
        `;
        
        if (startTime) {
            html += `
                <div class="bc-field">
                    <div class="bc-field-label">Heure de début</div>
                    <div class="bc-field-value">${startTime}</div>
                </div>
            `;
        }
        
        if (endTime) {
            html += `
                <div class="bc-field">
                    <div class="bc-field-label">Heure de fin</div>
                    <div class="bc-field-value">${endTime}</div>
                </div>
            `;
        }
        
        if (props) {
            // Ajouter les propriétés étendues
            if (props.type) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Type</div>
                        <div class="bc-field-value">${props.type}</div>
                    </div>
                `;
            }
            
            if (props.sourceID) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Document source</div>
                        <div class="bc-field-value">${props.sourceID}</div>
                    </div>
                `;
            }
            
            if (props.quantity) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Quantité</div>
                        <div class="bc-field-value">${props.quantity}</div>
                    </div>
                `;
            }
            
            if (props.priority) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Priorité</div>
                        <div class="bc-field-value">${props.priority}</div>
                    </div>
                `;
            }
            
            if (props.customerNo) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Client</div>
                        <div class="bc-field-value">${props.customerNo}</div>
                    </div>
                `;
            }
            
            if (props.vendorNo) {
                html += `
                    <div class="bc-field">
                        <div class="bc-field-label">Fournisseur</div>
                        <div class="bc-field-value">${props.vendorNo}</div>
                    </div>
                `;
            }
        }
        
        planningData.innerHTML = html;
    }
    
    function formatTime(date) {
        if (!date) return '';
        
        try {
            return date.toLocaleTimeString('fr-FR', {
                hour: '2-digit',
                minute: '2-digit',
                hour12: false
            });
        } catch (e) {
            return '';
        }
    }
    
    function formatDate(dateString, options = {}) {
        try {
            const date = new Date(dateString + 'T00:00:00');
            return date.toLocaleDateString('fr-FR', {
                weekday: options.weekday || 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                ...options
            });
        } catch (e) {
            return dateString;
        }
    }
    
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
    
    // Fonction pour mettre à jour le calendrier avec des événements provenant de BC
    window.updateCalendarEvents = function(eventsJSON) {
        if (!window.planningCalendar) return;
        
        console.log("📊 Mise à jour des événements du calendrier");
        
        try {
            // Supprimer les événements existants
            window.planningCalendar.getEventSources().forEach(source => source.remove());
            
            // Analyser le JSON reçu de Business Central
            let events = [];
            let planningItems = [];
            let selectedDate = '';
            
            if (eventsJSON && eventsJSON.trim() !== '') {
                // Essayer de parser le JSON
                try {
                    const responseData = JSON.parse(eventsJSON);
                    
                    // Check if we have a proper structure with events and possibly details
                    if (responseData.events && Array.isArray(responseData.events)) {
                        events = responseData.events;
                        // Store planning items if provided
                        if (responseData.planningItems) {
                            planningItems = responseData.planningItems;
                        }
                        // Store selected date if provided
                        if (responseData.selectedDate) {
                            selectedDate = responseData.selectedDate;
                        }
                    } else if (Array.isArray(responseData)) {
                        // Backward compatibility - simple array of events
                        events = responseData;
                    }
                    
                    console.log(`📅 ${events.length} événements chargés depuis AL`);
                } catch (parseError) {
                    console.error("❌ Erreur de parsing JSON:", parseError);
                    console.log("JSON reçu:", eventsJSON);
                }
            }
            
            // Ajouter les nouveaux événements au calendrier
            if (Array.isArray(events) && events.length > 0) {
                // Add events to calendar
                window.planningCalendar.addEventSource(events);
                
                // Mettre à jour le statut
                updateStatus(`✅ ${events.length} événements chargés`, "#107c10");
                
                // Update planning details if we have planning items and a selected date
                if (planningItems.length > 0 && selectedDate) {
                    const planningData = document.getElementById("planningData");
                    if (planningData) {
                        // Vérifier si nous sommes en vue quotidienne
                        const viewType = window.planningCalendar.view.type;
                        if (viewType === 'timeGridDay') {
                            displayDailySchedule(planningData, selectedDate, planningItems);
                        } else {
                            displayPlanningData(planningData, selectedDate, planningItems);
                        }
                    }
                }
                
            } else {
                console.log("ℹ️ Aucun événement à ajouter ou format incorrect");
                    updateStatus("ℹ️ Aucun événement disponible", "#605e5c");
            }
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des événements:", error);
            updateStatus("❌ Erreur calendrier", "#d13438");
        }
    };
    
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