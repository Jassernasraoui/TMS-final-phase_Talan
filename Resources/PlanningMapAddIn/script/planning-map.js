//
Nouveau
fichier
planning-map.js

// planning-map.js - Script de support pour la carte de planning
// Ce script fournit des fonctions supplémentaires pour la carte de planning

// Fonction pour convertir des coordonnées en adresse (géocodage inverse)
function reverseGeocode(latitude, longitude, callback) {
    // Vérifier si les coordonnées sont valides
    if (!latitude || !longitude) {
        console.error("❌ Coordonnées invalides pour le géocodage inverse");
        return;
    }
    
    try {
        // Utiliser l'API de géocodage inverse de GoMaps.pro
        const xhr = new XMLHttpRequest();
        xhr.open('GET', `https://app.gomaps.pro/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${getApiKey()}`, true);
        
        xhr.onload = function() {
            if (xhr.status === 200) {
                const response = JSON.parse(xhr.responseText);
                
                if (response.status === "OK" && response.results && response.results.length > 0) {
                    // Récupérer l'adresse formatée
                    const address = response.results[0].formatted_address;
                    callback(address);
                } else {
                    console.warn("⚠️ Aucun résultat de géocodage inverse");
                    callback("Adresse inconnue");
                }
            } else {
                console.error("❌ Erreur lors du géocodage inverse:", xhr.statusText);
                callback("Erreur de géocodage");
            }
        };
        
        xhr.onerror = function() {
            console.error("❌ Erreur réseau lors du géocodage inverse");
            callback("Erreur réseau");
        };
        
        xhr.send();
    } catch (error) {
        console.error("❌ Exception lors du géocodage inverse:", error);
        callback("Erreur");
    }
}

// Fonction pour obtenir la clé API actuelle
function getApiKey() {
    // Cette fonction devrait renvoyer la clé API configurée
    // Dans une implémentation réelle, elle pourrait être stockée dans une variable globale
    return window.apiKey || "AlzaSys0bqUT-VVIx-r7qTFr4ckjC4_yJmd4oOU";
}

// Fonction pour formater une distance en kilomètres
function formatDistance(meters) {
    if (meters < 1000) {
        return `${meters} m`;
    } else {
        return `${(meters / 1000).toFixed(1)} km`;
    }
}

// Fonction pour formater une durée en minutes/heures
function formatDuration(seconds) {
    if (seconds < 60) {
        return `${seconds} sec`;
    } else if (seconds < 3600) {
        return `${Math.round(seconds / 60)} min`;
    } else {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.round((seconds % 3600) / 60);
        return `${hours} h ${minutes} min`;
    }
}

// Fonction pour créer un marqueur personnalisé
function createCustomMarker(position, title, options = {}) {
    // Options par défaut
    const defaultOptions = {
        color: '#0078D4',
        label: '',
        draggable: false,
        zIndex: 1
    };
    
    // Fusionner les options par défaut avec les options fournies
    const markerOptions = Object.assign({}, defaultOptions, options);
    
    // Créer le marqueur
    return new google.maps.Marker({
        position: position,
        title: title,
        label: markerOptions.label,
        draggable: markerOptions.draggable,
        zIndex: markerOptions.zIndex,
        icon: {
            path: google.maps.SymbolPath.CIRCLE,
            fillColor: markerOptions.color,
            fillOpacity: 0.9,
            strokeColor: '#ffffff',
            strokeWeight: 2,
            scale: 10
        }
    });
}

// Fonction pour calculer la distance entre deux points
function calculateDistance(point1, point2) {
    // Utiliser la formule de Haversine pour calculer la distance entre deux points géographiques
    const R = 6371e3; // Rayon de la Terre en mètres
    const φ1 = point1.lat * Math.PI / 180;
    const φ2 = point2.lat * Math.PI / 180;
    const Δφ = (point2.lat - point1.lat) * Math.PI / 180;
    const Δλ = (point2.lng - point1.lng) * Math.PI / 180;
    
    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    
    return R * c; // Distance en mètres
}

// Fonction pour optimiser un itinéraire (algorithme simple)
function optimizeRoute(points, startIndex = 0) {
    // Si moins de 3 points, pas besoin d'optimisation
    if (points.length < 3) {
        return points;
    }
    
    // Point de départ fixe
    const start = points[startIndex];
    
    // Points à visiter (sans le point de départ)
    const pointsToVisit = [...points];
    pointsToVisit.splice(startIndex, 1);
    
    // Résultat optimisé
    const optimizedRoute = [start];
    let currentPoint = start;
    
    // Tant qu'il reste des points à visiter
    while (pointsToVisit.length > 0) {
        // Trouver le point le plus proche du point actuel
        let minDistance = Infinity;
        let closestPointIndex = -1;
        
        for (let i = 0; i < pointsToVisit.length; i++) {
            const distance = calculateDistance(currentPoint, pointsToVisit[i]);
            if (distance < minDistance) {
                minDistance = distance;
                closestPointIndex = i;
            }
        }
        
        // Ajouter le point le plus proche à l'itinéraire
        currentPoint = pointsToVisit[closestPointIndex];
        optimizedRoute.push(currentPoint);
        
        // Supprimer le point de la liste des points à visiter
        pointsToVisit.splice(closestPointIndex, 1);
    }
    
    return optimizedRoute;
}

// Fonction pour générer une couleur aléatoire
function getRandomColor() {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

// Fonction pour vérifier si la carte est prête
function isMapReady() {
    return typeof google !== 'undefined' && 
           typeof google.maps !== 'undefined' && 
           typeof google.maps.Map !== 'undefined';
}

// Fonction pour créer une infobulle personnalisée
function createCustomInfoWindow(content) {
    return new google.maps.InfoWindow({
        content: content,
        maxWidth: 300,
        pixelOffset: new google.maps.Size(0, -30)
    });
}

// Fonction pour ajouter un contrôle personnalisé à la carte
function addCustomControl(map, controlDiv, title, text, callback) {
    // Créer le conteneur du contrôle
    const controlUI = document.createElement('div');
    controlUI.style.backgroundColor = '#fff';
    controlUI.style.border = '2px solid #fff';
    controlUI.style.borderRadius = '3px';
    controlUI.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
    controlUI.style.cursor = 'pointer';
    controlUI.style.marginBottom = '22px';
    controlUI.style.textAlign = 'center';
    controlUI.title = title;
    controlDiv.appendChild(controlUI);
    
    // Créer le texte du contrôle
    const controlText = document.createElement('div');
    controlText.style.color = 'rgb(25,25,25)';
    controlText.style.fontFamily = 'Roboto,Arial,sans-serif';
    controlText.style.fontSize = '16px';
    controlText.style.lineHeight = '38px';
    controlText.style.paddingLeft = '5px';
    controlText.style.paddingRight = '5px';
    controlText.innerHTML = text;
    controlUI.appendChild(controlText);
    
    // Ajouter l'événement de clic
    controlUI.addEventListener('click', callback);
    
    // Ajouter le contrôle à la carte
    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(controlDiv);
}

// Fonction pour créer un polyline entre deux points
function createPolyline(map, point1, point2, options = {}) {
    // Options par défaut
    const defaultOptions = {
        strokeColor: '#0078D4',
        strokeOpacity: 0.8,
        strokeWeight: 3
    };
    
    // Fusionner les options par défaut avec les options fournies
    const polylineOptions = Object.assign({}, defaultOptions, options);
    
    // Créer le polyline
    const polyline = new google.maps.Polyline({
        path: [point1, point2],
        geodesic: true,
        ...polylineOptions
    });
    
    // Ajouter le polyline à la carte
    polyline.setMap(map);
    
    return polyline;
}

// Exporter les fonctions pour les rendre disponibles globalement
window.reverseGeocode = reverseGeocode;
window.formatDistance = formatDistance;
window.formatDuration = formatDuration;
window.createCustomMarker = createCustomMarker;
window.calculateDistance = calculateDistance;
window.optimizeRoute = optimizeRoute;
window.getRandomColor = getRandomColor;
window.isMapReady = isMapReady;
window.createCustomInfoWindow = createCustomInfoWindow;
window.addCustomControl = addCustomControl;
window.createPolyline = createPolyline;
