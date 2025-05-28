# Description du Processus Complet du Projet Logistique

Le projet est un système de gestion logistique qui comprend quatre phases principales: la gestion des ressources, la planification des tournées, la préparation/chargement des véhicules, et l'exécution des tournées. Voici une description détaillée du processus complet:

## 1. Gestion des Ressources

### 1.1 Création des Ressources
- **Personnes**
  - Saisie des informations personnelles
  - Vérification de la validité du permis de conduire
  - Configuration des certifications et qualifications
  - Attribution d'un statut initial "Disponible"

- **Véhicules**
  - Saisie des informations du véhicule (immatriculation, type)
  - Vérification des documents obligatoires (assurance, contrôle technique)
  - Configuration des caractéristiques (dimensions, poids, volume)
  - Attribution d'un statut initial "Disponible"

## 2. Planification des Tournées

### 2.1 Création de la Tournée
- Création d'un nouveau document de planification avec un numéro unique
- Saisie des dates (début/fin) et informations de base
- Définition des lieux de départ/arrivée
- Vérification que la date est supérieure ou égale à aujourd'hui

### 2.2 Affectation des Ressources
- Assignation d'un chauffeur (ressource Personne)
- Assignation d'un véhicule (ressource Véhicule)
- Vérification de la disponibilité des ressources
- Vérification de la compatibilité (permis de conduire avec type de véhicule)
- Changement du statut des ressources de "Disponible" à "Assigné"

### 2.3 Génération des Lignes de Planification
- Ajout des lignes de livraison avec informations clients
- Saisie des articles et quantités à livrer
- Définition des coordonnées géographiques
- Vérification que le poids/volume total ne dépasse pas la capacité du véhicule

### 2.4 Attribution des Créneaux Horaires
- Assignation de créneaux horaires spécifiques à chaque livraison
- Vérification que les créneaux ne se chevauchent pas
- Prise en compte des temps de trajet entre livraisons
- Équilibrage de la charge sur la période
- Respect des priorités clients

## 3. Préparation et Chargement des Véhicules

### 3.1 Document de Préparation de Chargement
- Création d'un document de préparation avec référence à la tournée
- Génération des arrêts de livraison en fonction des lignes planifiées
- Optimisation de l'ordre des arrêts
- Calcul des totaux de chargement (poids, volume)
- Vérification du respect des capacités du véhicule

### 3.2 Validation de la Préparation
- Libération du document de préparation (statut "En chargement")
- Vérification par un superviseur
- Validation formelle (signature électronique)
- Statut du document passe à "Validé"

### 3.3 Document de Chargement Véhicule
- Création d'un document de chargement référençant le document de préparation validé
- Génération des lignes de chargement correspondant aux arrêts planifiés
- Statut initial "En cours"

### 3.4 Processus de Chargement
- Enregistrement de l'heure de début du chargement
- Saisie des quantités réelles chargées pour chaque ligne
- Calcul automatique des écarts de quantité
- Justification obligatoire pour les écarts supérieurs à 10%
- Mise à jour des statuts de chaque ligne (Chargé/Partiellement/Non chargé)

### 3.5 Finalisation du Chargement
- Calcul des totaux finaux (poids/volume réels)
- Signature du responsable et du chauffeur
- Statut du document passe à "Complété"
- Génération des documents de transport

## 4. Exécution des Tournées

### 4.1 Départ en Mission
- Changement du statut de la tournée à "En mission"
- Enregistrement de l'heure de départ
- Remise des documents d'expédition au chauffeur
- Activation des systèmes de suivi GPS (si disponibles)

### 4.2 Livraisons aux Clients
- Confirmation pour chaque livraison effectuée
- Documentation des anomalies sur le terrain
- Enregistrement des heures réelles de livraison
- Collecte des signatures clients
- Documentation des incidents de trajet

### 4.3 Traitement des Exceptions
- Gestion des livraisons non effectuées ou partielles
- Documentation des causes et solutions apportées
- Décisions sur les actions correctives

### 4.4 Clôture de la Tournée
- Vérification que toutes les livraisons sont terminées ou documentées
- Changement du statut de la tournée à "Terminée"
- Libération des ressources (statut revient à "Disponible")
- Enregistrement des performances pour analyse
- Documentation des anomalies pour amélioration continue

## 5. Gestion des États et Flux de Données

Le système maintient différents états pour les documents:
- **Tournée**: Draft → Plannified → On Mission → Stopped
- **Document de Chargement**: Planned → Loading → Validated/InProgress → Completed/Canceled
- **Document de Chargement Véhicule**: InProgress → Completed/Cancelled

Chaque document est lié aux autres, formant une chaîne d'informations cohérente de la planification à l'exécution. 