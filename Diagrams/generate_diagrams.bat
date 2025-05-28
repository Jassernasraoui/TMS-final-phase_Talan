@echo off
echo ====================================
echo Génération des diagrammes PlantUML
echo ====================================

echo Vérification de Java...
java -version

if %ERRORLEVEL% NEQ 0 (
    echo Java non trouvé. Veuillez installer Java pour utiliser PlantUML.
    exit /b 1
)

echo Téléchargement de PlantUML si nécessaire...
if not exist plantuml.jar (
    echo Téléchargement de PlantUML...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/plantuml/plantuml/releases/download/v1.2023.10/plantuml-1.2023.10.jar' -OutFile 'plantuml.jar'"
)

echo Génération des diagrammes...
java -jar plantuml.jar CompleteFinalProcessDiagram.puml
java -jar plantuml.jar EnhancedLogisticsProcessDiagram.puml

echo Terminé! Les fichiers PNG ont été générés dans le même répertoire.
echo ==================================== 