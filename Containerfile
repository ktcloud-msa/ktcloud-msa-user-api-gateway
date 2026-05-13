FROM eclipse-temurin:23-jdk AS build
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle.kts .
COPY settings.gradle.kts .

COPY user-api-gateway/build.gradle.kts user-api-gateway/

RUN ./gradlew dependencies --no-daemon

COPY . .

RUN ./gradlew :user-api-gateway:bootJar -x test --no-daemon

FROM eclipse-temurin:23-jre
WORKDIR /app

RUN useradd -ms /bin/bash springuser
USER springuser

COPY --from=build /app/user-api-gateway/build/libs/user-api-gateway.jar app.jar

ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=staging", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "app.jar"]

EXPOSE 8080