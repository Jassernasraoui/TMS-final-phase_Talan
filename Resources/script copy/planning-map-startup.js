// planning-map-startup.js - Script de démarrage pour la carte de planning
(function () {
    console.log("🚀 StartupScript: Initialisation de la carte de planning avec Bing Maps...");
    
    // Variables globales
    window.MapInitialized = window.MapInitialized || false;
    window.BingMapsKey = "";  // Sera défini par BC
    window.MapConfig = {
        defaultLocation: {
            latitude: 48.856614,   // Paris par défaut
            longitude: 2.3522219
        },
        zoom: 10,
        mapType: "road"  // road, aerial, canvasLight, canvasDark, grayscale, etc.
    };
    
    // Conteneur pour les emplacements et l'itinéraire
    window.PlanningData = {
        locations: [],
        route: null,
        selectedLocationId: null
    };
    
    // Fonction principale d'initialisation
    function initializeMap() {
        // Éviter les initialisations multiples
        if (window.MapInitialized) {
            console.log("🗺️ Carte déjà initialisée, arrêt");
            return;
        }
        
        console.log("🗺️ Création de l'interface carte...");
        
        try {
            // Créer l'interface de la carte
            createMapInterface();
            
            // Vérifier si Bing Maps API est chargée
            if (typeof Microsoft === 'undefined' || !Microsoft.Maps) {
                console.log("⏳ Bing Maps API n'est pas encore chargée, attendons son chargement...");
                
                // On surveille la variable Microsoft.Maps qui sera créée lors du chargement de l'API
                var checkInterval = setInterval(function() {
                    if (typeof Microsoft !== 'undefined' && Microsoft.Maps) {
                        clearInterval(checkInterval);
                        console.log("✅ Bing Maps API chargée, initialisation de la carte");
                        initBingMap();
                    }
                }, 100);
            } else {
                console.log("✅ Bing Maps API déjà disponible");
                initBingMap();
            }
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
        
        // Ajouter des styles CSS inline pour s'assurer que la carte s'affiche correctement
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
    
    // Initialisation de la carte Bing Maps
    function initBingMap() {
        if (!window.Microsoft || !window.Microsoft.Maps) {
            console.error("❌ L'API Bing Maps n'est pas disponible");
            document.getElementById('mapStatus').textContent = "❌ Échec de chargement";
            return;
        }
        
        try {
            // Si la clé API n'est pas définie, utiliser une clé de test (à remplacer en production)
            if (!window.BingMapsKey) {
                console.warn("⚠️ Aucune clé API Bing Maps définie, utilisation de clé de test");
                window.BingMapsKey = "AuAaQIpuk6_V0xIbjiS3CQRAQ1d4K3c9RdZ3R8BbwKJ7PvVp-yXxJn91RkLQ7XAk";
            }
            
            // Créer l'instance de carte
            window.PlanningMap = new Microsoft.Maps.Map(document.getElementById('map'), {
                credentials: window.BingMapsKey,
                center: new Microsoft.Maps.Location(
                    window.MapConfig.defaultLocation.latitude, 
                    window.MapConfig.defaultLocation.longitude
                ),
                zoom: window.MapConfig.zoom,
                mapTypeId: Microsoft.Maps.MapTypeId[window.MapConfig.mapType],
                showDashboard: true,
                showScalebar: true,
                showTermsLink: false
            });
            
            // Charger les modules nécessaires
            Microsoft.Maps.loadModule(['Microsoft.Maps.AutoSuggest', 'Microsoft.Maps.Directions'], function() {
                // Initialiser le module Directions
                window.PlanningDirectionsManager = new Microsoft.Maps.Directions.DirectionsManager(window.PlanningMap);
                window.PlanningDirectionsManager.setRenderOptions({
                    autoUpdateMapView: true,
                    waypointPushpinOptions: {
                        title: 'Waypoint',
                        subTitle: 'Drag to change',
                        color: 'blue'
                    },
                    drivingPolylineOptions: {
                        strokeColor: 'blue',
                        strokeThickness: 5
                    }
                });
                
                // Écouter les événements de direction
                Microsoft.Maps.Events.addHandler(window.PlanningDirectionsManager, 'directionsUpdated', function(e) {
                    onRouteCalculated(e);
                });
                
                // Mise à jour du statut
                document.getElementById('mapStatus').textContent = "✅ Prêt";
                
                // Marquer comme initialisé
                window.MapInitialized = true;
                
                // Notifier BC que le contrôle est prêt
                notifyControlReady();
                
                console.log("✅ Carte Bing Maps initialisée avec succès");
            });
            
        } catch (error) {
            console.error("❌ Erreur lors de l'initialisation de Bing Maps:", error);
            document.getElementById('mapStatus').textContent = "❌ Erreur";
        }
    }
    
    // Fonction appelée lorsqu'un itinéraire est calculé
    function onRouteCalculated(e) {
        var route = e.route[0];
        if (route && route.routeLegs && route.routeLegs.length > 0) {
            var totalDistance = 0;
            var totalTimeInMinutes = 0;
            
            for (var i = 0; i < route.routeLegs.length; i++) {
                var leg = route.routeLegs[i];
                totalDistance += leg.distance;
                totalTimeInMinutes += leg.travelDuration / 60; // Convertir secondes en minutes
            }
            
            var routeInfo = {
                distance: totalDistance,
                time: totalTimeInMinutes,
                waypoints: route.routeLegs.length + 1,
                legs: route.routeLegs.map(function(leg) {
                    return {
                        from: leg.startWaypointLocation,
                        to: leg.endWaypointLocation,
                        distance: leg.distance,
                        time: leg.travelDuration / 60
                    };
                })
            };
            
            // Mettre à jour l'affichage des détails de l'itinéraire
            var routeDataElement = document.getElementById('routeData');
            routeDataElement.innerHTML = `
                <div class="route-summary">
                    <h4>📊 Résumé de l'itinéraire</h4>
                    <p>📍 Points d'arrêt: ${routeInfo.waypoints}</p>
                    <p>🛣️ Distance totale: ${totalDistance.toFixed(2)} km</p>
                    <p>⏱️ Temps estimé: ${totalTimeInMinutes.toFixed(0)} min</p>
                </div>
            `;
            
            // Notifier BC des résultats de l'itinéraire
            notifyRouteCalculated(JSON.stringify(routeInfo), totalDistance, totalTimeInMinutes);
        }
    }
    
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
    
    // === Exposer les fonctions au scope global pour qu'elles puissent être appelées depuis planning-map.js ===
    window.PlanningMapFunctions = {
        initializeMap: initializeMap,
        notifyLocationSelected: notifyLocationSelected,
        notifyRouteCalculated: notifyRouteCalculated
    };
    
    // === POINTS D'ENTRÉE ===
    
    // 1. StartupScript - s'exécute immédiatement
    console.log("🎯 StartupScript démarré");
    
    // 2. DOM Ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeMap);
    } else if (document.readyState === 'interactive' || document.readyState === 'complete') {
        // DOM déjà prêt
        initializeMap();
    }
    
    // 3. Window load (backup)
    window.addEventListener('load', function() {
        if (!window.MapInitialized) {
            console.log("🔄 Initialisation via window.load");
            initializeMap();
        }
    });
    
    // 4. Timeout de sécurité
    setTimeout(function() {
        if (!window.MapInitialized) {
            console.log("⏰ Initialisation via timeout de sécurité");
            initializeMap();
        }
    }, 500);
    
    // 5. Fonction GetMap (appelée par callback de l'API Bing Maps)
    window.GetMap = function() {
        console.log("🔄 GetMap appelé par le callback de l'API Bing Maps");
        if (!window.MapInitialized) {
            initializeMap();
        }
    };
    
    console.log("📋 Script planning-map-startup.js chargé et configuré");
    
})(); 