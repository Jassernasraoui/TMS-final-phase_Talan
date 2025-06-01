// Debug Map Control for Business Central
console.log("[MAP_DEBUG] Script loading at: " + new Date().toISOString());

// Ajouter un message dans le DOM pour le débogage
function addDebugMessage(message) {
    console.log("[MAP_DEBUG] " + message);
    
    // Ajouter à la page
    try {
        var debugContainer = document.getElementById('map_debug_container');
        if (!debugContainer) {
            debugContainer = document.createElement('div');
            debugContainer.id = 'map_debug_container';
            debugContainer.style.position = 'fixed';
            debugContainer.style.top = '10px';
            debugContainer.style.right = '10px';
            debugContainer.style.backgroundColor = 'rgba(255, 255, 255, 0.9)';
            debugContainer.style.padding = '10px';
            debugContainer.style.border = '1px solid #ccc';
            debugContainer.style.borderRadius = '5px';
            debugContainer.style.maxWidth = '300px';
            debugContainer.style.maxHeight = '300px';
            debugContainer.style.overflow = 'auto';
            debugContainer.style.zIndex = '9999';
            debugContainer.style.fontSize = '12px';
            debugContainer.style.fontFamily = 'Consolas, monospace';
            document.body.appendChild(debugContainer);
        }
        
        var msgElem = document.createElement('div');
        msgElem.textContent = new Date().toLocaleTimeString() + ': ' + message;
        msgElem.style.borderBottom = '1px solid #eee';
        msgElem.style.paddingBottom = '5px';
        msgElem.style.marginBottom = '5px';
        debugContainer.appendChild(msgElem);
        
        // Limiter le nombre de messages
        while (debugContainer.childNodes.length > 20) {
            debugContainer.removeChild(debugContainer.firstChild);
        }
        
        // Scroll to bottom
        debugContainer.scrollTop = debugContainer.scrollHeight;
    } catch (e) {
        console.error("[MAP_DEBUG] Error adding debug message:", e);
    }
}

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
    addDebugMessage('InitializeMap called');
    
    try {
        // Créer le conteneur si nécessaire
        if (!document.getElementById('map_container')) {
            addDebugMessage('Creating map container');
            var container = document.createElement('div');
            container.id = 'map_container';
            container.style.width = '100%';
            container.style.height = '100%';
            container.style.position = 'relative';
            container.style.backgroundColor = '#f0f0f0';
            container.style.border = '2px solid red'; // Bordure rouge pour visualisation
            document.body.appendChild(container);
            
            // Message de test
            var testDiv = document.createElement('div');
            testDiv.style.position = 'absolute';
            testDiv.style.top = '50%';
            testDiv.style.left = '50%';
            testDiv.style.transform = 'translate(-50%, -50%)';
            testDiv.style.color = '#333';
            testDiv.style.fontFamily = 'Arial, sans-serif';
            testDiv.style.fontSize = '16px';
            testDiv.style.backgroundColor = 'white';
            testDiv.style.padding = '20px';
            testDiv.style.border = '1px solid #ccc';
            testDiv.style.borderRadius = '5px';
            testDiv.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
            testDiv.innerHTML = 'Control Add-In Loaded Successfully!<br>Waiting for Google Maps API key...';
            container.appendChild(testDiv);
            addDebugMessage('Test message added to container');
        } else {
            addDebugMessage('Map container already exists');
        }
        
        // Diagnostic du parent
        try {
            var parentInfo = '';
            var mapContainer = document.getElementById('map_container');
            if (mapContainer) {
                var parent = mapContainer.parentElement;
                if (parent) {
                    parentInfo = 'Parent: ' + parent.tagName;
                    if (parent.id) parentInfo += ' (id=' + parent.id + ')';
                    if (parent.className) parentInfo += ' (class=' + parent.className + ')';
                    
                    // Dimensions du parent
                    var rect = parent.getBoundingClientRect();
                    parentInfo += ' - Size: ' + Math.round(rect.width) + 'x' + Math.round(rect.height);
                } else {
                    parentInfo = 'No parent found';
                }
            } else {
                parentInfo = 'Map container not found';
            }
            addDebugMessage(parentInfo);
        } catch (e) {
            addDebugMessage('Error getting parent info: ' + e.message);
        }
        
        // Notifier Business Central que le contrôle est prêt
        try {
            if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
                addDebugMessage('Triggering OnControlReady');
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnControlReady', []);
            } else {
                addDebugMessage('ERROR: Microsoft.Dynamics.NAV not available');
            }
        } catch (e) {
            addDebugMessage('ERROR notifying BC: ' + e.message);
        }
    } catch (e) {
        console.error("[MAP_DEBUG] Error in InitializeMap:", e);
        addDebugMessage('CRITICAL ERROR: ' + e.message);
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

// Fonction pour définir la clé API
function setApiKey(apiKey) {
    addDebugMessage('setApiKey called with key: ' + (apiKey ? '******' + apiKey.substr(-4) : 'empty'));
    
    if (!apiKey || apiKey.trim() === '') {
        addDebugMessage('ERROR: Empty API key provided');
        return;
    }
    
    // Mettre à jour le message de test
    try {
        var mapContainer = document.getElementById('map_container');
        if (mapContainer) {
            var testDiv = mapContainer.querySelector('div');
            if (testDiv) {
                testDiv.innerHTML = 'API Key received. Loading Google Maps...';
            }
        }
    } catch (e) {
        addDebugMessage('Error updating test message: ' + e.message);
    }
    
    // Charger Google Maps
    try {
        // Supprimer le script existant s'il y en a un
        var existingScript = document.getElementById('google-maps-script');
        if (existingScript) {
            existingScript.parentNode.removeChild(existingScript);
            googleMapsLoaded = false;
            addDebugMessage('Removed existing Google Maps script');
        }
        
        // Créer et ajouter le nouveau script
        var script = document.createElement('script');
        script.id = 'google-maps-script';
        script.src = 'https://maps.gomaps.pro/maps/api/js?key=' + apiKey + '&callback=initGoogleMap';
        script.async = true;
        script.defer = true;
        
        script.onerror = function() {
            addDebugMessage('ERROR: Failed to load Google Maps script');
        };
        
        document.head.appendChild(script);
        addDebugMessage('Google Maps script added to document');
    } catch (e) {
        addDebugMessage('ERROR loading Google Maps: ' + e.message);
    }
}

// Fonction de callback appelée par Google Maps une fois chargé
function initGoogleMap() {
    addDebugMessage('initGoogleMap called (Google Maps callback)');
    googleMapsLoaded = true;
    
    try {
        // Créer la carte
        var mapOptions = {
            center: { lat: 48.856614, lng: 2.3522219 }, // Paris par défaut
            zoom: 10,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            fullscreenControl: true
        };
        
        var mapContainer = document.getElementById('map_container');
        if (!mapContainer) {
            addDebugMessage('ERROR: Map container not found!');
            return;
        }
        
        map = new google.maps.Map(mapContainer, mapOptions);
        addDebugMessage('Google Maps initialized successfully');
        
        // Mettre à jour le message de test
        try {
            var testDiv = mapContainer.querySelector('div');
            if (testDiv) {
                testDiv.parentNode.removeChild(testDiv);
            }
        } catch (e) {
            addDebugMessage('Error removing test message: ' + e.message);
        }
        
        // Ajouter un marqueur de test
        new google.maps.Marker({
            position: { lat: 48.856614, lng: 2.3522219 },
            map: map,
            title: 'Paris'
        });
        
    } catch (e) {
        addDebugMessage('ERROR initializing map: ' + e.message);
    }
}

// Fonction pour afficher les adresses sur la carte
function ShowAddressesOnMap(addressesJson) {
    addDebugMessage('ShowAddressesOnMap called');
    
    if (!map) {
        addDebugMessage('ERROR: Map not initialized');
        return;
    }
    
    try {
        addDebugMessage('Parsing JSON addresses');
        var addresses = JSON.parse(addressesJson);
        addDebugMessage('Received ' + addresses.length + ' addresses');
        
        // Ajouter des marqueurs
        addresses.forEach(function(address) {
            if (address.latitude && address.longitude) {
                var position = new google.maps.LatLng(
                    parseFloat(address.latitude),
                    parseFloat(address.longitude)
                );
                
                var marker = new google.maps.Marker({
                    position: position,
                    map: map,
                    title: address.name || 'Address'
                });
                
                markers.push(marker);
            }
        });
        
        addDebugMessage('Added ' + markers.length + ' markers to map');
    } catch (e) {
        addDebugMessage('ERROR showing addresses: ' + e.message);
    }
}

// Fonction pour calculer l'itinéraire optimal
function CalculateShortestRoute(startAddressId) {
    addDebugMessage('CalculateShortestRoute called with ID: ' + startAddressId);
}

// Fonction pour mettre à jour les adresses
function UpdateMapAddresses(addressesJson) {
    addDebugMessage('UpdateMapAddresses called');
    ShowAddressesOnMap(addressesJson);
}

// Fonction pour effacer la carte
function ClearMap() {
    addDebugMessage('ClearMap called');
    
    // Effacer les marqueurs
    markers.forEach(function(marker) {
        marker.setMap(null);
    });
    markers = [];
}

// Fonction pour zoomer sur une position
function ZoomToLocation(latitude, longitude, zoomLevel) {
    addDebugMessage('ZoomToLocation called');
    
    if (!map) {
        addDebugMessage('ERROR: Map not initialized');
        return;
    }
    
    try {
        var lat = parseFloat(latitude);
        var lng = parseFloat(longitude);
        var zoom = parseInt(zoomLevel) || 14;
        
        map.setCenter(new google.maps.LatLng(lat, lng));
        map.setZoom(zoom);
        addDebugMessage('Map zoomed to ' + lat + ', ' + lng + ' (zoom: ' + zoom + ')');
    } catch (e) {
        addDebugMessage('ERROR zooming: ' + e.message);
    }
}

// Fonction pour exécuter du JavaScript dynamique
function ExecuteJavaScript(scriptCode) {
    addDebugMessage('ExecuteJavaScript called');
    
    try {
        eval(scriptCode);
        addDebugMessage('Script executed successfully');
    } catch (e) {
        addDebugMessage('ERROR executing script: ' + e.message);
    }
}

// Initialisation immédiate
document.addEventListener('DOMContentLoaded', function() {
    addDebugMessage('DOMContentLoaded triggered');
    InitializeMap();
});

// Détecter les problèmes de chargement
window.addEventListener('error', function(e) {
    addDebugMessage('ERROR event: ' + e.message + ' at ' + e.filename + ':' + e.lineno);
});

// Appeler InitializeMap immédiatement au cas où DOMContentLoaded serait déjà passé
addDebugMessage('Script loaded');
InitializeMap();