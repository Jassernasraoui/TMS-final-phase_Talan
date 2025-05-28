# Instructions pour visualiser vos diagrammes PlantUML

## Méthode 1: Utiliser PlantUML en ligne

1. Allez sur [PlantUML Online Server](http://www.plantuml.com/plantuml/uml/)
2. Copiez le contenu complet d'un de vos fichiers .puml (ProfessionalLogisticsProcessDiagram.puml ou DetailedLogisticsProcessDiagram.puml)
3. Collez-le dans la zone de texte sur le site
4. Le diagramme sera automatiquement généré
5. Vous pouvez télécharger l'image générée en PNG, SVG ou d'autres formats

## Méthode 2: Installation locale (nécessite Java)

1. Téléchargez Java depuis [le site officiel](https://www.java.com/fr/download/)
2. Téléchargez PlantUML depuis [le site officiel](https://plantuml.com/download)
3. Exécutez la commande: `java -jar plantuml.jar votre_fichier.puml`

## Méthode 3: Extensions pour éditeurs

Si vous utilisez VS Code:
1. Installez l'extension "PlantUML" par jebbs
2. Ouvrez votre fichier .puml
3. Utilisez Alt+D pour prévisualiser le diagramme

## Problèmes courants

Si les diagrammes ne compilent pas correctement:
1. Vérifiez que tous les blocs sont correctement fermés (accolades, parenthèses)
2. Vérifiez que toutes les commandes PlantUML sont correctes
3. Parfois, les couleurs personnalisées peuvent causer des problèmes - essayez de simplifier le diagramme

## Exemple pour tester

Voici un exemple simple que vous pouvez tester pour vérifier que PlantUML fonctionne:

```
@startuml
start
:Hello world;
:This is a test;
stop
@enduml
``` 