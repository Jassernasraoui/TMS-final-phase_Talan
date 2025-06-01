// Fichier script pour la carte

// Script d'intégration de Google Maps pour Business Central
// Variables globales
var map, markers = [], directionsService, directionsRenderer;
var addresses = [];
var optimizedWaypoints = [];
var googleMapsLoaded = false;
var pendingApiKey = '';
var mapInitialized = false;

// Fonction principale appelée par BC pour initialiser la carte
function InitializeMap() {
    console.log('[MAP] InitializeMap appelé');
    
    // Éviter les initialisations multiples
    if (mapInitialized) {
        console.log('[MAP] Carte déjà initialisée, pas de réinitialisation');
        return;
    }
    
    mapInitialized = true;
    
    // Créer le conteneur si nécessaire
    if (!document.getElementById('map_container')) {
        var container = document.createElement('div');
        container.id = 'map_container';
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.position = 'relative';
        document.body.appendChild(container);
        
        // Ajouter un message de chargement
        var loadingDiv = document.createElement('div');
        loadingDiv.id = 'loading_indicator';
        loadingDiv.style.position = 'absolute';
        loadingDiv.style.top = '50%';
        loadingDiv.style.left = '50%';
        loadingDiv.style.transform = 'translate(-50%, -50%)';
        loadingDiv.style.textAlign = 'center';
        loadingDiv.style.color = '#333';
        loadingDiv.style.fontFamily = 'Arial, sans-serif';
        loadingDiv.innerHTML = 'Chargement de la carte...<br/><div style="margin-top:10px; width:40px; height:40px; border:4px solid rgba(0,0,0,0.1); border-top:4px solid #007BFF; border-radius:50%; animation:spin 1s linear infinite; margin:0 auto;"></div>';
        
        var styleElement = document.createElement('style');
        styleElement.textContent = '@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }';
        document.head.appendChild(styleElement);
        
        container.appendChild(loadingDiv);
    }
    
    // Ajouter des meta tags pour les applications mobiles
    addMobileMetaTags();
    
    // Optimiser le chargement des images
    optimizeImageLoading();
    
    // Notifier Business Central que le contrôle est prêt
    try {
        if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
            console.log('[MAP] Déclenchement de OnControlReady');
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnControlReady', []);
        } else {
            console.error('[MAP] Objet Microsoft.Dynamics.NAV non disponible');
            showError('Erreur d\'initialisation: contexte Business Central non disponible');
        }
    } catch (e) {
        console.error('[MAP] Erreur lors de la notification BC:', e);
        showError('Erreur d\'initialisation: ' + e.message);
    }
}

// Fonction pour ajouter les meta tags nécessaires
function addMobileMetaTags() {
    // Ajouter meta tag pour le mobile
    var appleMetaTag = document.querySelector('meta[name="apple-mobile-web-app-capable"]');
    var mobileMetaTag = document.querySelector('meta[name="mobile-web-app-capable"]');
    
    if (!mobileMetaTag) {
        mobileMetaTag = document.createElement('meta');
        mobileMetaTag.name = 'mobile-web-app-capable';
        mobileMetaTag.content = 'yes';
        document.head.appendChild(mobileMetaTag);
    }
}

// Fonction pour optimiser le chargement des images
function optimizeImageLoading() {
    // Intercepter les images pour éviter le chargement paresseux non désiré
    if (window.IntersectionObserver) {
        var imgObserver = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    var img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.removeAttribute('data-src');
                    }
                    imgObserver.unobserve(img);
                }
            });
        });
        
        // Observer toutes les images avec data-src
        document.addEventListener('DOMContentLoaded', function() {
            var lazyImages = document.querySelectorAll('img[data-src]');
            lazyImages.forEach(function(img) {
                imgObserver.observe(img);
            });
        });
    }
}

// Fonction pour définir la clé API et charger Google Maps
function setApiKey(apiKey) {
    console.log('[MAP] setApiKey appelé avec une clé');
    
    if (!apiKey || apiKey.trim() === '') {
        showError('Clé API non fournie. Veuillez configurer une clé API Google Maps dans les paramètres.');
        return;
    }
    
    // Stocker la clé API pour une utilisation ultérieure
    pendingApiKey = apiKey;
    
    if (!googleMapsLoaded) {
        loadGoogleMapsScript(apiKey);
    } else {
        console.log('[MAP] Google Maps déjà chargé, pas besoin de recharger le script');
    }
}

// Fonction pour charger l'API Google Maps
function loadGoogleMapsScript(apiKey) {
    console.log('[MAP] Chargement du script Google Maps');
    
    // Supprimer le script existant s'il y en a un
    var existingScript = document.getElementById('google-maps-script');
    if (existingScript) {
        existingScript.parentNode.removeChild(existingScript);
        googleMapsLoaded = false;
    }
    
    // Créer et ajouter le nouveau script
    var script = document.createElement('script');
    script.id = 'google-maps-script';
    script.src = 'https://maps.gomaps.pro/maps/api/js?key=' + apiKey + '&callback=initGoogleMap';
    script.async = true;
    script.defer = true;
    
    script.onerror = function() {
        console.error('[MAP] Erreur de chargement du script Google Maps');
        showError('Impossible de charger Google Maps. Vérifiez votre clé API et votre connexion Internet.');
    };
    
    document.head.appendChild(script);
    console.log('[MAP] Script Google Maps ajouté au document');
}

// Fonction de callback appelée par Google Maps une fois chargé
function initGoogleMap() {
    console.log('[MAP] initGoogleMap appelé (callback de Google Maps)');
    googleMapsLoaded = true;
    
    try {
        // Masquer l'indicateur de chargement
        var loadingIndicator = document.getElementById('loading_indicator');
        if (loadingIndicator) {
            loadingIndicator.style.display = 'none';
        }
        
        // Créer la carte
        var mapOptions = {
            center: { lat: 48.856614, lng: 2.3522219 }, // Paris par défaut
            zoom: 7,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            mapTypeControl: true,
            fullscreenControl: true,
            streetViewControl: true
        };
        
        map = new google.maps.Map(document.getElementById('map_container'), mapOptions);
        
        // Initialiser les services de directions
        directionsService = new google.maps.DirectionsService();
        directionsRenderer = new google.maps.DirectionsRenderer({
            suppressMarkers: false,
            draggable: true
        });
        
        directionsRenderer.setMap(map);
        
        // Ajouter un contrôle d'optimisation d'itinéraire
        addOptimizeControl();
        
        console.log('[MAP] Carte Google Maps initialisée avec succès');
    } catch (e) {
        console.error('[MAP] Erreur lors de l\'initialisation de la carte:', e);
        showError('Erreur d\'initialisation de la carte: ' + e.message);
    }
}

// Fonction pour ajouter un contrôle personnalisé d'optimisation d'itinéraire
function addOptimizeControl() {
    if (!map) return;
    
    var controlDiv = document.createElement('div');
    controlDiv.style.padding = '10px';
    
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = '#4285F4';
    controlUI.style.border = 'none';
    controlUI.style.borderRadius = '2px';
    controlUI.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
    controlUI.style.cursor = 'pointer';
    controlUI.style.marginBottom = '22px';
    controlUI.style.textAlign = 'center';
    controlUI.title = 'Cliquez pour optimiser l\'itinéraire';
    controlDiv.appendChild(controlUI);
    
    var controlText = document.createElement('div');
    controlText.style.color = 'rgb(255,255,255)';
    controlText.style.fontFamily = 'Roboto,Arial,sans-serif';
    controlText.style.fontSize = '16px';
    controlText.style.lineHeight = '38px';
    controlText.style.paddingLeft = '5px';
    controlText.style.paddingRight = '5px';
    controlText.innerHTML = '🚚 Optimiser l\'itinéraire';
    controlUI.appendChild(controlText);
    
    controlUI.addEventListener('click', function() {
        console.log('[MAP] Bouton d\'optimisation cliqué');
        CalculateShortestRoute('');
    });
    
    map.controls[google.maps.ControlPosition.TOP_CENTER].push(controlDiv);
}

// Fonction pour afficher les adresses sur la carte
function ShowAddressesOnMap(addressesJson) {
    console.log('[MAP] ShowAddressesOnMap appelé');
    
    if (!map) {
        console.error('[MAP] La carte n\'est pas initialisée');
        if (pendingApiKey) {
            console.log('[MAP] Tentative de réinitialisation de la carte avec la clé API en attente');
            loadGoogleMapsScript(pendingApiKey);
        }
        return;
    }
    
    try {
        // Effacer les marqueurs existants
        clearMarkers();
        
        // Analyser le JSON
        addresses = JSON.parse(addressesJson);
        console.log('[MAP] Données d\'adresses reçues:', addresses.length, 'adresses');
        
        if (!addresses || addresses.length === 0) {
            console.log('[MAP] Aucune adresse à afficher');
            return;
        }
        
        // Créer les limites pour ajuster la vue
        var bounds = new google.maps.LatLngBounds();
        
        // Ajouter les marqueurs pour chaque adresse
        addresses.forEach(function(address) {
            if (address.latitude && address.longitude) {
                var lat = parseFloat(address.latitude);
                var lng = parseFloat(address.longitude);
                
                if (isNaN(lat) || isNaN(lng)) {
                    console.warn('[MAP] Coordonnées invalides pour l\'adresse:', address.id);
                    return;
                }
                
                var position = new google.maps.LatLng(lat, lng);
                
                // Créer le marqueur
                var marker = new google.maps.Marker({
                    position: position,
                    map: map,
                    title: address.name || 'Adresse',
                    animation: google.maps.Animation.DROP
                });
                
                // Créer l'info-bulle
                var infoContent = createInfoWindowContent(address);
                var infowindow = new google.maps.InfoWindow({
                    content: infoContent
                });
                
                // Ajouter l'événement de clic
                marker.addListener('click', function() {
                    // Fermer toutes les autres info-bulles
                    markers.forEach(function(m) {
                        if (m.infowindow) m.infowindow.close();
                    });
                    
                    // Ouvrir cette info-bulle
                    infowindow.open(map, marker);
                    
                    // Notifier Business Central
                    if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnAddressSelected', [
                            address.id,
                            address.latitude,
                            address.longitude
                        ]);
                    }
                });
                
                // Stocker l'info-bulle avec le marqueur
                marker.infowindow = infowindow;
                
                // Ajouter à la collection de marqueurs
                markers.push(marker);
                
                // Étendre les limites
                bounds.extend(position);
            }
        });
        
        // Ajuster la vue pour montrer tous les marqueurs
        if (markers.length > 0) {
            map.fitBounds(bounds);
            
            // Si un seul marqueur, zoomer à un niveau raisonnable
            if (markers.length === 1) {
                map.setZoom(14);
            }
        }
        
        console.log('[MAP] Affichage de', markers.length, 'marqueurs sur la carte');
    } catch (e) {
        console.error('[MAP] Erreur lors de l\'affichage des adresses:', e);
        showError('Erreur lors de l\'affichage des adresses: ' + e.message);
    }
}

// Fonction pour créer le contenu de l'info-bulle
function createInfoWindowContent(address) {
    var content = '<div style="font-family: Arial, sans-serif; padding: 5px; min-width: 200px;">';
    content += '<h3 style="margin-top: 0; margin-bottom: 8px; color: #4285F4; font-size: 16px; border-bottom: 1px solid #eee; padding-bottom: 5px;">' + (address.name || 'Adresse') + '</h3>';
    
    if (address.address) {
        content += '<p style="margin: 5px 0; font-size: 13px;"><strong>Adresse:</strong> ' + address.address;
        if (address.postCode || address.city) {
            content += ', ' + (address.postCode || '') + ' ' + (address.city || '');
        }
        content += '</p>';
    }
    
    if (address.contact) {
        content += '<p style="margin: 5px 0; font-size: 13px;"><strong>Contact:</strong> ' + address.contact + '</p>';
    }
    
    if (address.phoneNo) {
        content += '<p style="margin: 5px 0; font-size: 13px;"><strong>Téléphone:</strong> ' + address.phoneNo + '</p>';
    }
    
    content += '<button onclick="selectAddressForRoute(\'' + address.id + '\')" style="background-color: #4285F4; color: white; border: none; padding: 6px 12px; border-radius: 2px; margin-top: 8px; cursor: pointer; font-size: 12px;">Définir comme départ</button>';
    content += '</div>';
    
    return content;
}

// Fonction pour effacer les marqueurs
function clearMarkers() {
    markers.forEach(function(marker) {
        marker.setMap(null);
    });
    markers = [];
}

// Fonction pour effacer la carte
function ClearMap() {
    console.log('[MAP] ClearMap appelé');
    
    // Effacer les marqueurs
    clearMarkers();
    
    // Effacer les itinéraires
    if (directionsRenderer) {
        directionsRenderer.setMap(null);
        if (map) directionsRenderer.setMap(map);
    }
}

// Fonction pour sélectionner une adresse comme point de départ
function selectAddressForRoute(addressId) {
    console.log('[MAP] selectAddressForRoute appelé avec ID:', addressId);
    CalculateShortestRoute(addressId);
}

// Fonction pour calculer l'itinéraire optimal
function CalculateShortestRoute(startAddressId) {
    console.log('[MAP] CalculateShortestRoute appelé');
    
    if (!map || !directionsService || !directionsRenderer) {
        console.error('[MAP] Services de directions non disponibles');
        showError('Les services de directions ne sont pas disponibles.');
        return;
    }
    
    if (!addresses || addresses.length < 2) {
        console.log('[MAP] Pas assez d\'adresses pour calculer un itinéraire');
        showMessage('Il faut au moins 2 adresses pour calculer un itinéraire.');
        return;
    }
    
    try {
        // Trouver l'adresse de départ
        var startAddress = null;
        if (startAddressId && startAddressId !== '') {
            startAddress = addresses.find(function(addr) {
                return addr.id === startAddressId;
            });
        }
        
        // Si pas d'adresse de départ, prendre la première
        if (!startAddress) {
            startAddress = addresses[0];
        }
        
        // Créer un indicateur de chargement
        var loadingDiv = document.createElement('div');
        loadingDiv.id = 'route_loading';
        loadingDiv.style.position = 'absolute';
        loadingDiv.style.top = '50%';
        loadingDiv.style.left = '50%';
        loadingDiv.style.transform = 'translate(-50%, -50%)';
        loadingDiv.style.backgroundColor = 'rgba(255, 255, 255, 0.8)';
        loadingDiv.style.padding = '15px';
        loadingDiv.style.borderRadius = '5px';
        loadingDiv.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
        loadingDiv.style.zIndex = '1000';
        loadingDiv.innerHTML = 'Calcul de l\'itinéraire optimal...';
        document.getElementById('map_container').appendChild(loadingDiv);
        
        // Préparer les points intermédiaires
        var waypoints = [];
        addresses.forEach(function(address) {
            if (address.id !== startAddress.id) {
                waypoints.push({
                    location: new google.maps.LatLng(
                        parseFloat(address.latitude),
                        parseFloat(address.longitude)
                    ),
                    stopover: true,
                    addressId: address.id
                });
            }
        });
        
        // Configurer la requête
        var request = {
            origin: new google.maps.LatLng(
                parseFloat(startAddress.latitude),
                parseFloat(startAddress.longitude)
            ),
            destination: new google.maps.LatLng(
                parseFloat(startAddress.latitude),
                parseFloat(startAddress.longitude)
            ),
            waypoints: waypoints,
            optimizeWaypoints: true,
            travelMode: google.maps.TravelMode.DRIVING
        };
        
        // Appeler le service de directions
        directionsService.route(request, function(response, status) {
            // Supprimer l'indicateur de chargement
            var loadingElement = document.getElementById('route_loading');
            if (loadingElement) {
                loadingElement.parentNode.removeChild(loadingElement);
            }
            
            if (status === google.maps.DirectionsStatus.OK) {
                // Afficher l'itinéraire
                directionsRenderer.setDirections(response);
                
                // Extraire l'ordre des points intermédiaires
                var waypointOrder = response.routes[0].waypoint_order;
                
                // Stocker l'ordre optimisé
                optimizedWaypoints = waypointOrder.map(function(index) {
                    return waypoints[index].addressId;
                });
                
                // Calculer distance et durée
                var totalDistance = 0;
                var totalDuration = 0;
                var legs = response.routes[0].legs;
                
                legs.forEach(function(leg) {
                    totalDistance += leg.distance.value;
                    totalDuration += leg.duration.value;
                });
                
                // Convertir en km et heures
                var distanceKm = (totalDistance / 1000).toFixed(2);
                var durationHours = Math.floor(totalDuration / 3600);
                var durationMinutes = Math.floor((totalDuration % 3600) / 60);
                var durationText = durationHours + 'h ' + durationMinutes + 'min';
                
                // Afficher un résumé
                showMessage('Distance: ' + distanceKm + ' km | Durée: ' + durationText);
                
                // Notifier Business Central
                if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnRouteCalculated', [
                        distanceKm,
                        durationText,
                        JSON.stringify(optimizedWaypoints)
                    ]);
                }
                
                console.log('[MAP] Itinéraire calculé: ' + distanceKm + ' km, ' + durationText);
            } else {
                console.error('[MAP] Erreur de calcul d\'itinéraire:', status);
                showError('Erreur lors du calcul de l\'itinéraire: ' + status);
            }
        });
    } catch (e) {
        console.error('[MAP] Erreur lors du calcul de l\'itinéraire:', e);
        showError('Erreur lors du calcul de l\'itinéraire: ' + e.message);
    }
}

// Fonction pour mettre à jour les adresses sur la carte
function UpdateMapAddresses(addressesJson) {
    console.log('[MAP] UpdateMapAddresses appelé');
    ShowAddressesOnMap(addressesJson);
}

// Fonction pour zoomer sur une position
function ZoomToLocation(latitude, longitude, zoomLevel) {
    console.log('[MAP] ZoomToLocation appelé');
    
    if (!map) {
        console.error('[MAP] La carte n\'est pas initialisée');
        return;
    }
    
    try {
        var lat = parseFloat(latitude);
        var lng = parseFloat(longitude);
        var zoom = parseInt(zoomLevel) || 14;
        
        map.setCenter(new google.maps.LatLng(lat, lng));
        map.setZoom(zoom);
    } catch (e) {
        console.error('[MAP] Erreur lors du zoom:', e);
    }
}

// Fonction pour exécuter du JavaScript dynamique
function ExecuteJavaScript(scriptCode) {
    console.log('[MAP] ExecuteJavaScript appelé');
    try {
        eval(scriptCode);
    } catch (e) {
        console.error('[MAP] Erreur lors de l\'exécution du script:', e);
    }
}

// Fonctions utilitaires
function showMessage(message, duration) {
    var messageDiv = document.createElement('div');
    messageDiv.style.position = 'absolute';
    messageDiv.style.bottom = '20px';
    messageDiv.style.left = '50%';
    messageDiv.style.transform = 'translateX(-50%)';
    messageDiv.style.backgroundColor = 'rgba(255, 255, 255, 0.9)';
    messageDiv.style.color = '#333';
    messageDiv.style.padding = '10px 15px';
    messageDiv.style.borderRadius = '5px';
    messageDiv.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
    messageDiv.style.zIndex = '1000';
    messageDiv.style.fontFamily = 'Arial, sans-serif';
    messageDiv.innerHTML = message;
    
    var container = document.getElementById('map_container');
    if (container) {
        container.appendChild(messageDiv);
        
        // Supprimer après un délai
        setTimeout(function() {
            if (messageDiv.parentNode) {
                messageDiv.parentNode.removeChild(messageDiv);
            }
        }, duration || 5000);
    }
}

function showError(message) {
    console.error('[MAP] ERREUR:', message);
    
    var errorDiv = document.createElement('div');
    errorDiv.style.position = 'absolute';
    errorDiv.style.top = '50%';
    errorDiv.style.left = '50%';
    errorDiv.style.transform = 'translate(-50%, -50%)';
    errorDiv.style.backgroundColor = 'rgba(255, 255, 255, 0.9)';
    errorDiv.style.color = '#D32F2F';
    errorDiv.style.padding = '15px 20px';
    errorDiv.style.borderRadius = '5px';
    errorDiv.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
    errorDiv.style.zIndex = '1000';
    errorDiv.style.fontFamily = 'Arial, sans-serif';
    errorDiv.style.textAlign = 'center';
    errorDiv.style.maxWidth = '80%';
    
    errorDiv.innerHTML = '<div style="font-size:18px; margin-bottom:10px;">⚠️ ' + message + '</div>' +
                         '<div style="font-size:14px; margin-top:10px;">Vérifiez votre clé API Google Maps dans la configuration de géocodage.</div>' +
                         '<div style="margin-top:15px;"><button onclick="this.parentNode.parentNode.style.display=\'none\';" style="padding:5px 10px; background:#4285F4; color:white; border:none; border-radius:3px; cursor:pointer;">Fermer</button></div>';
    
    var container = document.getElementById('map_container');
    if (container) {
        // Supprimer les erreurs précédentes
        var previousErrors = container.querySelectorAll('[data-error-message]');
        previousErrors.forEach(function(el) {
            el.parentNode.removeChild(el);
        });
        
        errorDiv.setAttribute('data-error-message', 'true');
        container.appendChild(errorDiv);
    }
}

// Initialisation immédiate du conteneur
document.addEventListener('DOMContentLoaded', function() {
    console.log('[MAP] DOMContentLoaded déclenché');
    InitializeMap();
});

// Appeler InitializeMap immédiatement au cas où DOMContentLoaded serait déjà passé
console.log('[MAP] Script chargé');
InitializeMap();