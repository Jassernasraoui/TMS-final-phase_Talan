// google-maps-integration.js - Script d'intégration pour GoMaps.pro (basé sur Google Maps)
(function () {
    // Variables globales
    let map;
    let markers = [];
    let infoWindows = [];
    let directionsService;
    let directionsRenderer;
    let apiKey = '';
    
    // Initialisation de la carte
    window.initGoogleMap = function() {
        console.log("🚀 Initialisation de GoMaps.pro...");
        
        // Créer l'élément de script pour GoMaps
        const script = document.createElement('script');
        script.src = 'https://app.gomaps.pro/maps/api/js?key=' + apiKey + '&callback=googleMapCallback';
        script.async = true;
        script.defer = true;
        document.head.appendChild(script);
        
        // Créer l'interface de la carte
        createMapInterface();
    };
    
    // Callback appelé quand l'API Maps est chargée
    window.googleMapCallback = function() {
        console.log("✅ API GoMaps.pro chargée");
        
        try {
            // Options par défaut de la carte
            const mapOptions = {
                center: { lat: 48.856614, lng: 2.3522219 }, // Paris par défaut
                zoom: 6,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            
            // Créer la carte
            map = new google.maps.Map(document.getElementById('map'), mapOptions);
            
            // Initialiser les services de directions
            directionsService = new google.maps.DirectionsService();
            directionsRenderer = new google.maps.DirectionsRenderer({
                map: map,
                suppressMarkers: false,
                polylineOptions: {
                    strokeColor: '#0078D4',
                    strokeWeight: 5
                }
            });
            
            // Notifier BC que la carte est prête
            notifyControlReady();
            
            // Mettre à jour le statut
            updateStatus("✅ Carte prête");
        } catch (error) {
            console.error("❌ Erreur lors de l'initialisation de la carte:", error);
            updateStatus("❌ Erreur d'initialisation");
            
            // Fallback à une carte simple si l'API échoue
            initFallbackMap();
        }
    };
    
    // Initialiser une carte de secours si l'API échoue
    function initFallbackMap() {
        try {
            // Créer une image statique comme fallback
            const mapContainer = document.getElementById('map');
            if (mapContainer) {
                mapContainer.innerHTML = `
                    <div style="text-align: center; padding: 20px;">
                        <p>⚠️ Impossible de charger la carte interactive.</p>
                        <img src="https://app.gomaps.pro/maps/api/staticmap?center=48.856614,2.3522219&zoom=5&size=600x400&key=${apiKey}" 
                             alt="Carte statique" style="max-width: 100%; border: 1px solid #ccc;">
                    </div>
                `;
            }
            
            // Notifier BC que la carte est prête (même en mode dégradé)
            notifyControlReady();
        } catch (error) {
            console.error("❌ Erreur lors de l'initialisation de la carte de secours:", error);
            updateStatus("❌ Erreur critique - Aucune carte disponible");
        }
    }
    
    // Créer l'interface de la carte
    function createMapInterface() {
        // Nettoyer le contenu existant
        document.body.innerHTML = '';
        
        // Créer la structure HTML
        const mapHTML = `
            <div id="mapWrapper">
                <div id="planningMapContainer">
                    <div id="mapHeader">
                        <h3>🗺️ Carte Planning</h3>
                        <div id="mapStatus">⏳ Chargement...</div>
                    </div>
                    <div id="map"></div>
                </div>
                <div id="mapDetails">
                    <h3>📋 Détails Itinéraire</h3>
                    <div id="selectedLocationInfo">
                        <p>👉 Sélectionnez un point sur la carte</p>
                    </div>
                    <div id="routeData"></div>
                </div>
            </div>
        `;
        
        document.body.innerHTML = mapHTML;
        
        // Ajouter des styles CSS
        const styleElement = document.createElement('style');
        styleElement.textContent = `
            #mapWrapper {
                display: flex;
                flex-direction: column;
                height: 100%;
                width: 100%;
            }
            #planningMapContainer {
                flex: 1;
                display: flex;
                flex-direction: column;
                min-height: 300px;
            }
            #mapHeader {
                display: flex;
                justify-content: space-between;
                padding: 5px 10px;
                background-color: #f0f0f0;
                border-bottom: 1px solid #ddd;
            }
            #map {
                flex: 1;
                min-height: 300px;
                position: relative;
            }
            #mapDetails {
                max-height: 200px;
                overflow-y: auto;
                padding: 10px;
                border-top: 1px solid #ddd;
            }
        `;
        document.head.appendChild(styleElement);
    }
    
    // Mettre à jour le statut de la carte
    function updateStatus(message) {
        const statusElement = document.getElementById('mapStatus');
        if (statusElement) {
            statusElement.textContent = message;
        }
    }
    
    // Mettre à jour les localisations sur la carte
    window.UpdateLocations = function(locationsJSON) {
        try {
            // Analyser les données JSON
            const data = JSON.parse(locationsJSON);
            console.log("📍 Mise à jour des localisations", data);
            
            // S'assurer que la carte est initialisée
            if (!map) {
                console.warn("⚠️ La carte n'est pas encore initialisée");
                return;
            }
            
            // Nettoyer les marqueurs existants
            clearMarkers();
            
            // Ajouter les nouveaux marqueurs
            const locations = data.locations || [];
            addMarkersToMap(locations);
            
            // Centrer la carte sur tous les marqueurs
            fitMapToMarkers();
            
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des localisations:", error);
        }
    };
    
    // Ajouter des marqueurs à la carte
    function addMarkersToMap(locations) {
        if (!map || !locations || locations.length === 0) {
            return;
        }
        
        console.log(`🗺️ Ajout de ${locations.length} localisations à la carte`);
        
        // Créer les marqueurs pour chaque localisation
        locations.forEach(location => {
            if (!location.coordinates || !location.coordinates.latitude || !location.coordinates.longitude) {
                console.warn(`⚠️ Coordonnées manquantes pour la location ${location.id}`);
                return;
            }
            
            try {
                // Créer le point sur la carte
                const position = {
                    lat: parseFloat(location.coordinates.latitude),
                    lng: parseFloat(location.coordinates.longitude)
                };
                
                // Déterminer la couleur du marqueur (par défaut: rouge)
                const markerColor = location.markerColor || '#d13438';
                
                // Créer le marqueur
                const marker = new google.maps.Marker({
                    position: position,
                    map: map,
                    title: location.title || 'Sans titre',
                    label: location.id.toString().substr(0, 1)
                });
                
                // Créer une infowindow (popup)
                const infoContent = `
                    <div class="info-window">
                        <h4>${location.title || 'Sans titre'}</h4>
                        <p>${formatLocationDetails(location)}</p>
                        <button onclick="selectLocation('${location.id}', '${JSON.stringify(location).replace(/'/g, "\\'")}')">Sélectionner</button>
                    </div>
                `;
                
                const infoWindow = new google.maps.InfoWindow({
                    content: infoContent
                });
                
                // Ajouter un gestionnaire d'événements de clic sur le marqueur
                marker.addListener('click', () => {
                    // Fermer toutes les autres infowindows
                    infoWindows.forEach(info => info.close());
                    
                    // Ouvrir l'infowindow pour ce marqueur
                    infoWindow.open(map, marker);
                    
                    // Sélectionner la localisation
                    window.selectLocation(location.id, JSON.stringify(location));
                });
                
                // Stocker les références pour nettoyage ultérieur
                markers.push(marker);
                infoWindows.push(infoWindow);
                
            } catch (error) {
                console.error(`❌ Erreur lors de l'ajout du marqueur pour ${location.id}:`, error);
            }
        });
    }
    
    // Formater les détails d'une localisation pour l'infowindow
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
    window.selectLocation = function(locationId, locationInfo) {
        try {
            // Mettre à jour l'affichage des détails
            updateSelectedLocationDisplay(locationInfo);
            
            // Notifier BC de la sélection
            notifyLocationSelected(locationId, locationInfo);
        } catch (error) {
            console.error("❌ Erreur lors de la sélection de la localisation:", error);
        }
    };
    
    // Mettre à jour l'affichage des détails de la localisation sélectionnée
    function updateSelectedLocationDisplay(locationInfo) {
        try {
            const locationData = typeof locationInfo === 'string' ? JSON.parse(locationInfo) : locationInfo;
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
    window.HighlightLocation = function(locationId) {
        // Trouver le marqueur correspondant à l'ID
        const marker = markers.find((m, index) => {
            // Ici nous utilisons l'index car Google Maps n'attache pas de métadonnées aux marqueurs
            // Dans une implémentation réelle, vous pourriez stocker l'ID dans un tableau parallèle
            return index === parseInt(locationId) - 1;
        });
        
        if (marker) {
            // Centrer la carte sur ce marqueur
            map.setCenter(marker.getPosition());
            map.setZoom(Math.max(map.getZoom(), 15)); // Zoom un peu plus près
            
            // Déclencher l'événement de clic sur le marqueur
            google.maps.event.trigger(marker, 'click');
        } else {
            console.warn(`⚠️ Aucun marqueur trouvé avec l'ID ${locationId}`);
        }
    };
    
    // Nettoyer les marqueurs existants
    function clearMarkers() {
        // Fermer toutes les infowindows
        infoWindows.forEach(infoWindow => infoWindow.close());
        infoWindows = [];
        
        // Supprimer les marqueurs de la carte
        markers.forEach(marker => marker.setMap(null));
        markers = [];
    }
    
    // Ajuster la vue de la carte pour inclure tous les marqueurs
    function fitMapToMarkers() {
        if (!map || markers.length === 0) {
            return;
        }
        
        // Créer les limites de la carte
        const bounds = new google.maps.LatLngBounds();
        
        // Ajouter tous les marqueurs aux limites
        markers.forEach(marker => {
            bounds.extend(marker.getPosition());
        });
        
        // Ajuster la vue pour inclure tous les marqueurs
        map.fitBounds(bounds);
        
        // Si le zoom est trop élevé (quand il n'y a qu'un seul marqueur), le réduire
        const zoomChangeListener = google.maps.event.addListener(map, 'idle', () => {
            if (map.getZoom() > 15) {
                map.setZoom(15);
            }
            google.maps.event.removeListener(zoomChangeListener);
        });
    }
    
    // Calculer un itinéraire optimal
    window.CalculateOptimalRoute = function(startLocationId, algorithm) {
        try {
            console.log(`🛣️ Calcul d'itinéraire depuis ${startLocationId}`);
            
            // S'assurer que la carte et les services de directions sont initialisés
            if (!map || !directionsService || !directionsRenderer) {
                console.warn("⚠️ Les services de directions ne sont pas initialisés");
                return;
            }
            
            // S'assurer qu'il y a au moins deux marqueurs
            if (markers.length < 2) {
                console.warn("⚠️ Au moins deux points sont nécessaires pour calculer un itinéraire");
                updateStatus("⚠️ Au moins deux points sont nécessaires");
                return;
            }
            
            // Mise à jour du statut
            updateStatus("⏳ Calcul de l'itinéraire...");
            
            // Récupérer le point de départ
            let startIndex = 0;
            if (startLocationId && startLocationId !== '0') {
                startIndex = parseInt(startLocationId) - 1;
                if (isNaN(startIndex) || startIndex < 0 || startIndex >= markers.length) {
                    startIndex = 0;
                }
            }
            
            // Configurer la requête de directions
            const request = {
                origin: markers[startIndex].getPosition(),
                destination: markers[markers.length - 1].getPosition(),
                waypoints: markers.slice(1, markers.length - 1).map(marker => ({
                    location: marker.getPosition(),
                    stopover: true
                })),
                optimizeWaypoints: true,
                travelMode: google.maps.TravelMode.DRIVING
            };
            
            // Calculer l'itinéraire
            directionsService.route(request, (result, status) => {
                if (status === google.maps.DirectionsStatus.OK) {
                    // Afficher l'itinéraire sur la carte
                    directionsRenderer.setDirections(result);
                    
                    // Afficher les détails de l'itinéraire
                    displayRouteDetails(result);
                    
                    // Mettre à jour le statut
                    updateStatus("✅ Itinéraire calculé");
                } else {
                    console.error("❌ Erreur lors du calcul de l'itinéraire:", status);
                    updateStatus("❌ Erreur de calcul");
                }
            });
        } catch (error) {
            console.error("❌ Erreur lors du calcul de l'itinéraire:", error);
            updateStatus("❌ Erreur de calcul");
        }
    };
    
    // Afficher les détails de l'itinéraire
    function displayRouteDetails(result) {
        try {
            const route = result.routes[0];
            if (!route) return;
            
            // Calculer la distance et le temps totaux
            let totalDistance = 0;
            let totalDuration = 0;
            
            route.legs.forEach(leg => {
                totalDistance += leg.distance.value;
                totalDuration += leg.duration.value;
            });
            
            // Convertir en unités plus lisibles
            const distanceInKm = (totalDistance / 1000).toFixed(2);
            const durationInMinutes = Math.round(totalDuration / 60);
            
            // Préparer l'information sur l'itinéraire
            const routeInfo = {
                distance: distanceInKm,
                time: durationInMinutes,
                waypoints: route.legs.length + 1,
                legs: route.legs.map(leg => ({
                    from: leg.start_address,
                    to: leg.end_address,
                    distance: (leg.distance.value / 1000).toFixed(2),
                    time: Math.round(leg.duration.value / 60)
                }))
            };
            
            // Mettre à jour l'affichage des détails de l'itinéraire
            const routeDataElement = document.getElementById('routeData');
            if (routeDataElement) {
                routeDataElement.innerHTML = `
                    <div class="route-summary">
                        <h4>📊 Résumé de l'itinéraire</h4>
                        <p>📍 Points d'arrêt: ${routeInfo.waypoints}</p>
                        <p>🛣️ Distance totale: ${routeInfo.distance} km</p>
                        <p>⏱️ Temps estimé: ${routeInfo.time} min</p>
                    </div>
                `;
            }
            
            // Notifier BC des résultats de l'itinéraire
            notifyRouteCalculated(JSON.stringify(routeInfo), parseFloat(distanceInKm), durationInMinutes);
        } catch (error) {
            console.error("❌ Erreur lors de l'affichage des détails de l'itinéraire:", error);
        }
    }
    
    // Effacer l'itinéraire
    window.ClearRoute = function() {
        try {
            if (directionsRenderer) {
                directionsRenderer.setDirections({ routes: [] });
            }
            
            // Effacer les détails de l'itinéraire
            const routeDataElement = document.getElementById('routeData');
            if (routeDataElement) {
                routeDataElement.innerHTML = '';
            }
            
            // S'assurer que tous les marqueurs sont visibles
            markers.forEach(marker => {
                marker.setVisible(true);
            });
            
            // Mettre à jour le statut
            updateStatus("✅ Itinéraire effacé");
        } catch (error) {
            console.error("❌ Erreur lors de l'effacement de l'itinéraire:", error);
        }
    };
    
    // Définir la clé API (non utilisée pour Google Maps si vous utilisez la version sans clé)
    window.SetBingMapsKey = function(apiKey) {
        console.log("ℹ️ SetBingMapsKey appelé mais non utilisé pour GoMaps.pro");
    };
    
    // Définir la clé API Google Maps
    window.SetGoogleMapsKey = function(newApiKey) {
        console.log("🔑 Configuration de la clé API GoMaps.pro");
        
        // Mettre à jour la clé API
        apiKey = newApiKey;
        
        // Si la carte est déjà initialisée, recharger avec la nouvelle clé
        if (map) {
            // Supprimer les scripts existants
            const scripts = document.querySelectorAll('script');
            scripts.forEach(script => {
                if (script.src && script.src.includes('gomaps.pro')) {
                    script.parentNode.removeChild(script);
                }
            });
            
            // Recharger la carte
            initGoogleMap();
        }
        
        console.log("✅ Clé API GoMaps.pro configurée");
    };
    
    // Définir les paramètres de la carte
    window.SetMapParameters = function(mapParamsJSON) {
        try {
            const params = JSON.parse(mapParamsJSON);
            console.log("⚙️ Mise à jour des paramètres de la carte", params);
            
            // Mettre à jour la configuration si la carte est déjà initialisée
            if (map) {
                // Mettre à jour le centre si nécessaire
                if (params.defaultLocation) {
                    map.setCenter({
                        lat: params.defaultLocation.latitude,
                        lng: params.defaultLocation.longitude
                    });
                }
                
                // Mettre à jour le zoom si nécessaire
                if (params.zoom) {
                    map.setZoom(params.zoom);
                }
                
                // Mettre à jour le type de carte si nécessaire
                if (params.mapType) {
                    switch (params.mapType.toLowerCase()) {
                        case 'aerial':
                        case 'satellite':
                            map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
                            break;
                        case 'hybrid':
                            map.setMapTypeId(google.maps.MapTypeId.HYBRID);
                            break;
                        case 'terrain':
                            map.setMapTypeId(google.maps.MapTypeId.TERRAIN);
                            break;
                        default:
                            map.setMapTypeId(google.maps.MapTypeId.ROADMAP);
                            break;
                    }
                }
            }
        } catch (error) {
            console.error("❌ Erreur lors de la mise à jour des paramètres de la carte:", error);
        }
    };
    
    // Fonction pour notifier BC que le contrôle est prêt
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
    
    // Fonction pour notifier BC des résultats de l'itinéraire
    function notifyRouteCalculated(routeInfo, totalDistance, totalTime) {
        try {
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV &&
                typeof Microsoft.Dynamics.NAV.InvokeExtensibilityMethod === 'function') {
                
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnRouteCalculated", [routeInfo, totalDistance, totalTime]);
                console.log("📢 Notification OnRouteCalculated envoyée");
            }
        } catch (error) {
            console.log("ℹ️ OnRouteCalculated non disponible (mode dev)");
        }
    }
    
    // Fonction pour notifier BC de la sélection d'un emplacement
    function notifyLocationSelected(locationId, locationInfo) {
        try {
            if (typeof Microsoft !== 'undefined' && 
                Microsoft.Dynamics && 
                Microsoft.Dynamics.NAV &&
                typeof Microsoft.Dynamics.NAV.InvokeExtensibilityMethod === 'function') {
                
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnLocationSelected", [locationId, locationInfo]);
                console.log("📢 Notification OnLocationSelected envoyée");
            }
        } catch (error) {
            console.log("ℹ️ OnLocationSelected non disponible (mode dev)");
        }
    }
    
    // Initialiser la carte au chargement de la page
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', window.initGoogleMap);
    } else {
        window.initGoogleMap();
    }
})(); 