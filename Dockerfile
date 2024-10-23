# Utiliser une image de base Java 19
FROM openjdk:19-jdk-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier le fichier JAR généré
COPY target/demo-0.0.1-SNAPSHOT.jar /app/app.jar

# Exposer le port utilisé par l'application
EXPOSE 8090

# Lancer l'application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
