// calender.js - Script principal avec gestion StartupScript
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
            // Nettoyer le contenu existant
            document.body.innerHTML = '';
            
            // Créer la structure HTML
            const calendarHTML = `
                <div id="calendarWrapper">
                    <div id="datePicker">
                        <h3>📅 Calendrier Planning</h3>
                        <label for="planningDatePicker">Sélectionner une date :</label>
                        <input type="date" id="planningDatePicker" />
                        <button id="loadBtn">📊 Charger Planning</button>
                        <div id="status">✅ Prêt</div>
                    </div>
                    <div id="placeholder">
                        <h3>📋 Planning Tournée</h3>
                        <p>👉 Sélectionnez une date et cliquez sur "Charger Planning"</p>
                        <div id="planningData"></div>
                    </div>
                </div>
            `;
            
            document.body.innerHTML = calendarHTML;
            
            // Configurer la date par défaut
            setupDefaultDate();
            
            // Configurer les événements
            setupEventHandlers();
            
            // Marquer comme initialisé
            window.CalendarInitialized = true;
            
            // Notifier AL que le contrôle est prêt
            notifyControlReady();
            
            console.log("✅ Calendrier initialisé avec succès");
            
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
    
    function setupDefaultDate() {
        const dateInput = document.getElementById("planningDatePicker");
        if (dateInput) {
            const today = new Date().toISOString().split('T')[0];
            dateInput.value = today;
            console.log("📅 Date par défaut définie:", today);
        }
    }
    
    function setupEventHandlers() {
        const loadBtn = document.getElementById("loadBtn");
        const dateInput = document.getElementById("planningDatePicker");
        const status = document.getElementById("status");
        const placeholder = document.getElementById("placeholder");
        
        if (!loadBtn || !dateInput || !status || !placeholder) {
            console.error("❌ Éléments DOM manquants");
            return;
        }
        
        // Gestionnaire du bouton de chargement
        loadBtn.addEventListener("click", function () {
            handleDateSelection();
        });
        
        // Gestionnaire de changement de date
        dateInput.addEventListener("change", function() {
            const selectedDate = dateInput.value;
            updatePlaceholder(selectedDate, false);
        });
        
        // Gestionnaire Enter sur input date
        dateInput.addEventListener("keypress", function(e) {
            if (e.key === 'Enter') {
                handleDateSelection();
            }
        });
        
        console.log("🔧 Gestionnaires d'événements configurés");
    }
    
    function handleDateSelection() {
        const dateInput = document.getElementById("planningDatePicker");
        const selectedDate = dateInput.value;
        
        if (!selectedDate) {
            alert("⚠️ Veuillez sélectionner une date");
            return;
        }
        
        console.log("📅 Traitement de la date:", selectedDate);
        
        // Mise à jour de l'interface
        updateStatus("🔄 Envoi en cours...", "#0078d4");
        updatePlaceholder(selectedDate, true);
        
        // Envoyer vers AL
        sendDateToBusinessCentral(selectedDate);
    }
    
    function updateStatus(message, color = "#605e5c") {
        const status = document.getElementById("status");
        if (status) {
            status.textContent = message;
            status.style.color = color;
        }
    }
    
    function updatePlaceholder(selectedDate, isLoading = false) {
        const placeholder = document.getElementById("placeholder");
        if (!placeholder) return;
        
        const formattedDate = formatDate(selectedDate);
        
        if (isLoading) {
            placeholder.innerHTML = `
                <h3>📋 Planning du ${formattedDate}</h3>
                <p>🔄 Transmission vers Business Central...</p>
                <div id="planningData" class="loading"></div>
            `;
        } else {
            placeholder.innerHTML = `
                <h3>📋 Planning du ${formattedDate}</h3>
                <p>👉 Cliquez sur "Charger Planning" pour traiter cette date</p>
                <div id="planningData"></div>
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
                    const placeholder = document.getElementById("placeholder");
                    if (placeholder) {
                        placeholder.innerHTML = `
                            <h3>📋 Planning du ${formatDate(selectedDate)}</h3>
                            <p>✅ Date transmise avec succès à Business Central</p>
                            <p>📊 Traitement en cours côté AL...</p>
                            <div id="planningData">
                                <div style="margin-top: 20px; padding: 15px; background-color: #f0f9ff; border-left: 4px solid #0078d4;">
                                    <strong>Date sélectionnée:</strong> ${selectedDate}<br>
                                    <strong>Statut:</strong> Transmis à AL avec succès
                                </div>
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
            
            const placeholder = document.getElementById("placeholder");
            if (placeholder) {
                placeholder.innerHTML = `
                    <h3>📋 Planning du ${formatDate(selectedDate)}</h3>
                    <p>🔧 Mode développement - API AL non disponible</p>
                    <div id="planningData">
                        <div style="margin-top: 20px; padding: 15px; background-color: #fff3cd; border-left: 4px solid #ff8c00;">
                            <strong>Date sélectionnée:</strong> ${selectedDate}<br>
                            <strong>Mode:</strong> Test/Développement<br>
                            <strong>Note:</strong> L'API Business Central sera disponible une fois déployé
                        </div>
                    </div>
                `;
            }
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