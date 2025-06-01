// planning-map.js - Implémentation des fonctionnalités de la carte de planning avec Bing Maps
(function () {
    // Fonctions exposées à AL
    window.UpdateLocations = updateLocations;
    window.CalculateOptimalRoute = calculateOptimalRoute;
    window.ClearRoute = clearRoute;
    window.HighlightLocation = highlightLocation;
    window.SetBingMapsKey = setBingMapsKey;
    window.SetMapParameters = setMapParameters;

    // Variables locales
    let locations = [];
    let markers = [];
    let infoboxes = [];
    
    // Définir la clé Bing Maps
    function setBingMapsKey(apiKey) {
        console.log("🔑 Mise à jour de la clé API Bing Maps");
        window.BingMapsKey = apiKey;
        
        // Si la carte est déjà initialisée, mettre à jour les credentials
        if (window.PlanningMap) {
            window.PlanningMap.setOptions({ credentials: apiKey });
        }
    }
    
    // Définir les paramètres de la carte
    function setMapParameters(mapParamsJSON) {
        try {
            const params = JSON.parse(mapParamsJSON);
            console.log("⚙️ Mise à jour des paramètres de la carte", params);
            
            // Mettre à jour la configuration
            if (params.defaultLocation) {
                window.MapConfig.defaultLocation = params.defaultLocation;
            }
            
            if (params.zoom) {
                window.MapConfig.zoom = params.zoom;
            }
            
            if (params.mapType) {
                window.MapConfig.mapType = params.mapType;
            }
            
            // Si la carte est déjà initialisée, mettre à jour les options
            if (window.PlanningMap) {
                // Mettre à jour le centre si nécessaire
                if (params.defaultLocation) {
                    window.PlanningMap.setView({
                        center: new Microsoft.Maps.Location(
                            params.defaultLocation.latitude,
                            params.defaultLocation.longitude
                        )
                    });
                }
                
                // Mettre à jour le zoom si nécessaire
                if (params.zoom) {
                    window.PlanningMap.setView({ zoom: params.zoom });
                }
                
                // Mettre à jour le type de carte si nécessaire
                if (params.mapType && Microsoft.Maps.MapTypeId[params.mapType]) {
                    window.PlanningMap.setView({ 
                        mapTypeId: Microsoft.Maps.MapTypeId[params.mapType]
                    });
                }
            }
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des paramètres de la carte:", error);
        }
    }
    
    // Mettre à jour les localisations sur la carte
    function updateLocations(locationsJSON) {
        try {
            // Analyser les données JSON
            const data = JSON.parse(locationsJSON);
            console.log("📍 Mise à jour des localisations", data);
            
            // S'assurer que la carte est initialisée
            if (!window.PlanningMap) {
                console.warn("⚠️ La carte n'est pas encore initialisée, stockage des données pour plus tard");
                window.PlanningData.locations = data;
                return;
            }
            
            // Nettoyer les marqueurs existants
            clearMarkers();
            
            // Stocker les locations
            locations = data.locations || [];
            window.PlanningData.locations = locations;
            
            // Ajouter les nouveaux marqueurs
            addMarkersToMap();
            
            // Centrer la carte sur tous les marqueurs
            fitMapToMarkers();
            
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des localisations:", error);
        }
    }
    
    // Ajouter des marqueurs à la carte
    function addMarkersToMap() {
        if (!window.PlanningMap || !locations || locations.length === 0) {
            return;
        }
        
        console.log(`🗺️ Ajout de ${locations.length} localisations à la carte`);
        
        // Créer les marqueurs et les infoboxes pour chaque localisation
        locations.forEach(location => {
            if (!location.coordinates || !location.coordinates.latitude || !location.coordinates.longitude) {
                console.warn(`⚠️ Coordonnées manquantes pour la location ${location.id}`);
                return;
            }
            
            try {
                // Créer le point sur la carte
                const position = new Microsoft.Maps.Location(
                    location.coordinates.latitude, 
                    location.coordinates.longitude
                );
                
                // Déterminer la couleur du marqueur (par défaut: rouge)
                const markerColor = location.markerColor || '#d13438';
                
                // Créer le pushpin (marqueur)
                const pushpin = new Microsoft.Maps.Pushpin(position, {
                    title: location.title || 'Sans titre',
                    subTitle: location.type || '',
                    color: markerColor,
                    text: location.id.toString().substr(0, 2) // Afficher un identifiant court
                });
                
                // Stocker l'ID de la localisation dans le pushpin pour référence
                pushpin.metadata = {
                    id: location.id,
                    info: JSON.stringify(location)
                };
                
                // Créer une infobox (popup)
                const infoboxOptions = {
                    title: location.title || 'Sans titre',
                    description: formatLocationDetails(location),
                    visible: false,
                    actions: [{
                        label: 'Sélectionner',
                        eventHandler: function() {
                            selectLocation(location.id, JSON.stringify(location));
                        }
                    }]
                };
                
                const infobox = new Microsoft.Maps.Infobox(position, infoboxOptions);
                infobox.setMap(window.PlanningMap);
                
                // Ajouter un gestionnaire d'événements de clic sur le pushpin
                Microsoft.Maps.Events.addHandler(pushpin, 'click', function() {
                    // Masquer toutes les infoboxes d'abord
                    infoboxes.forEach(box => box.setOptions({ visible: false }));
                    
                    // Afficher l'infobox liée à ce pushpin
                    infobox.setOptions({ visible: true });
                    
                    // Sélectionner la localisation
                    selectLocation(location.id, JSON.stringify(location));
                });
                
                // Ajouter le pushpin à la carte
                window.PlanningMap.entities.push(pushpin);
                
                // Stocker les références pour nettoyage ultérieur
                markers.push(pushpin);
                infoboxes.push(infobox);
                
            } catch (error) {
                console.error(`❌ Erreur lors de l'ajout du marqueur pour ${location.id}:`, error);
            }
        });
    }
    
    // Formater les détails d'une localisation pour l'infobox
    function formatLocationDetails(location) {
        let details = '';
        
        if (location.address && location.address.formatted) {
            details += `<strong>Adresse:</strong> ${location.address.formatted}<br>`;
        }
        
        if (location.type) {
            details += `<strong>Type:</strong> ${location.type}<br>`;
        }
        
        if (location.priority) {
            details += `<strong>Priorité:</strong> ${location.priority}<br>`;
        }
        
        if (location.date) {
            details += `<strong>Date:</strong> ${location.date}<br>`;
        }
        
        return details;
    }
    
    // Sélectionner une localisation
    function selectLocation(locationId, locationInfo) {
        // Mettre à jour l'ID de la localisation sélectionnée
        window.PlanningData.selectedLocationId = locationId;
        
        // Mettre à jour l'affichage des détails
        updateSelectedLocationDisplay(locationInfo);
        
        // Notifier BC de la sélection
        if (window.PlanningMapFunctions && window.PlanningMapFunctions.notifyLocationSelected) {
            window.PlanningMapFunctions.notifyLocationSelected(locationId, locationInfo);
        }
    }
    
    // Mettre à jour l'affichage des détails de la localisation sélectionnée
    function updateSelectedLocationDisplay(locationInfo) {
        try {
            const locationData = JSON.parse(locationInfo);
            const element = document.getElementById('selectedLocationInfo');
            
            if (element && locationData) {
                let html = `
                    <h4>📌 ${locationData.title || 'Localisation'}</h4>
                    <p>🆔 ID: ${locationData.id}</p>
                `;
                
                if (locationData.address && locationData.address.formatted) {
                    html += `<p>📍 Adresse: ${locationData.address.formatted}</p>`;
                }
                
                if (locationData.type) {
                    html += `<p>📋 Type: ${locationData.type}</p>`;
                }
                
                if (locationData.priority) {
                    html += `<p>🔔 Priorité: ${locationData.priority}</p>`;
                }
                
                if (locationData.date) {
                    html += `<p>📅 Date: ${locationData.date}</p>`;
                }
                
                if (locationData.coordinates) {
                    html += `<p>🌐 Coordonnées: ${locationData.coordinates.latitude}, ${locationData.coordinates.longitude}</p>`;
                }
                
                element.innerHTML = html;
            }
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour de l'affichage:", error);
        }
    }
    
    // Mettre en évidence une localisation
    function highlightLocation(locationId) {
        // Vérifier que la carte est initialisée
        if (!window.PlanningMap) {
            console.warn("⚠️ La carte n'est pas encore initialisée");
            return;
        }
        
        // Rechercher le marqueur correspondant à l'ID
        const marker = markers.find(m => m.metadata && m.metadata.id === locationId);
        if (marker) {
            // Centrer la carte sur ce marqueur
            window.PlanningMap.setView({
                center: marker.getLocation(),
                zoom: Math.max(window.PlanningMap.getZoom(), 15) // Zoom un peu plus près
            });
            
            // Simuler un clic sur le marqueur
            Microsoft.Maps.Events.invoke(marker, 'click', {});
        } else {
            console.warn(`⚠️ Aucun marqueur trouvé avec l'ID ${locationId}`);
        }
    }
    
    // Nettoyer les marqueurs existants
    function clearMarkers() {
        // Supprimer les infoboxes
        infoboxes.forEach(infobox => {
            if (infobox) {
                infobox.setMap(null);
            }
        });
        infoboxes = [];
        
        // Supprimer les marqueurs de la carte
        if (window.PlanningMap) {
            window.PlanningMap.entities.clear();
        }
        markers = [];
    }
    
    // Ajuster la vue de la carte pour inclure tous les marqueurs
    function fitMapToMarkers() {
        if (!window.PlanningMap || markers.length === 0) {
            return;
        }
        
        // Créer les limites de la carte
        const locations = markers.map(marker => marker.getLocation());
        const bounds = Microsoft.Maps.LocationRect.fromLocations(locations);
        
        // Ajuster la vue avec une petite marge
        window.PlanningMap.setView({
            bounds: bounds,
            padding: 50 // marge en pixels
        });
    }
    
    // Calculer un itinéraire optimal
    function calculateOptimalRoute(startLocationId, algorithm) {
        // Vérifier que la carte et le gestionnaire d'itinéraires sont initialisés
        if (!window.PlanningMap || !window.PlanningDirectionsManager) {
            console.warn("⚠️ La carte ou le gestionnaire d'itinéraires n'est pas initialisé");
            return;
        }
        
        try {
            console.log(`🛣️ Calcul d'itinéraire depuis ${startLocationId} avec l'algorithme ${algorithm}`);
            
            // Effacer les waypoints existants
            window.PlanningDirectionsManager.clearAll();
            
            // Trouver la localisation de départ
            let startLocation = null;
            if (startLocationId && startLocationId !== '0') {
                startLocation = locations.find(loc => loc.id === startLocationId);
            } else if (locations.length > 0) {
                // Utiliser la première localisation par défaut
                startLocation = locations[0];
            }
            
            if (!startLocation) {
                console.warn("⚠️ Aucune localisation de départ trouvée");
                return;
            }
            
            // Créer des waypoints pour toutes les localisations
            // Commencer par la localisation de départ
            if (startLocation.coordinates) {
                const startWaypoint = new Microsoft.Maps.Directions.Waypoint({
                    location: new Microsoft.Maps.Location(
                        startLocation.coordinates.latitude,
                        startLocation.coordinates.longitude
                    ),
                    address: startLocation.title || 'Départ'
                });
                window.PlanningDirectionsManager.addWaypoint(startWaypoint);
            }
            
            // Ajouter les autres localisations (sauf celle de départ)
            locations.forEach(location => {
                // Ignorer la localisation de départ (déjà ajoutée)
                if (location.id === startLocationId) {
                    return;
                }
                
                // Ignorer les localisations sans coordonnées
                if (!location.coordinates || !location.coordinates.latitude || !location.coordinates.longitude) {
                    return;
                }
                
                const waypoint = new Microsoft.Maps.Directions.Waypoint({
                    location: new Microsoft.Maps.Location(
                        location.coordinates.latitude,
                        location.coordinates.longitude
                    ),
                    address: location.title || `Point ${location.id}`
                });
                
                window.PlanningDirectionsManager.addWaypoint(waypoint);
            });
            
            // Configurer les options de l'itinéraire
            window.PlanningDirectionsManager.setRequestOptions({
                routeMode: Microsoft.Maps.Directions.RouteMode.driving,
                routeOptimization: Microsoft.Maps.Directions.RouteOptimization.timeWithTraffic,
                distanceUnit: Microsoft.Maps.Directions.DistanceUnit.km,
                maxRoutes: 1
            });
            
            // Démarrer le calcul de l'itinéraire
            window.PlanningDirectionsManager.calculateDirections();
            
            // Mise à jour du statut
            document.getElementById('mapStatus').textContent = "⏳ Calcul de l'itinéraire...";
            
        } catch (error) {
            console.error("❌ Erreur lors du calcul de l'itinéraire:", error);
            document.getElementById('mapStatus').textContent = "❌ Erreur de calcul";
        }
    }
    
    // Effacer l'itinéraire
    function clearRoute() {
        if (window.PlanningDirectionsManager) {
            window.PlanningDirectionsManager.clearAll();
            console.log("🧹 Itinéraire effacé");
            
            // Effacer les détails de l'itinéraire
            document.getElementById('routeData').innerHTML = '';
            
            // Remettre à jour les marqueurs pour s'assurer qu'ils sont tous visibles
            addMarkersToMap();
            fitMapToMarkers();
            
            // Mise à jour du statut
            document.getElementById('mapStatus').textContent = "✅ Prêt";
        }
    }
    
})(); 