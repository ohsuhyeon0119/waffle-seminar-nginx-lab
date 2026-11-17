# Stage 1: build the jar with the Gradle wrapper
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY . .
RUN ./gradlew bootJar --no-daemon

# Stage 2: run the jar on a JRE-only image
FROM eclipse-temurin:21-jre
WORKDIR /app
# Version label set by CI (e.g. v12); returned by /api/hello.
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
COPY --from=build /src/build/libs/app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-Xmx256m", "-jar", "app.jar"]
