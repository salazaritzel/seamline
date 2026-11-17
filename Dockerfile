# --- Build stage: JDK + Maven wrapper ---
FROM eclipse-temurin:25-jdk AS build
WORKDIR /workspace

# Copy the build files first so dependency downloads are cached
# until pom.xml changes, not on every source edit.
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN ./mvnw -B -q dependency:go-offline

COPY src src
# Tests run on the host (./mvnw test): Testcontainers needs a Docker daemon,
# which is not available inside a Docker build.
RUN ./mvnw -B -q package -DskipTests

# --- Runtime stage: JRE only ---
FROM eclipse-temurin:25-jre
WORKDIR /app

RUN groupadd --system seamline && useradd --system --gid seamline seamline
COPY --from=build /workspace/target/seamline-*.jar app.jar
USER seamline

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
