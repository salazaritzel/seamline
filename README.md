# Seamline

A lightweight, unified production-management tool for small and mid-size fashion brands. Seamline replaces the spreadsheet-and-multiple-tools juggle with one place to track styles through production, flag delay risk, and score suppliers.

## Status

Phase 1, slice 0 done: Spring Boot 4.1 skeleton with PostgreSQL 18, Flyway migrations, a health check, and Testcontainers tests. Next: the core module (styles, milestones, delay risk).

## Tech stack

- Java 25
- Spring Boot 4.1.x (Spring Framework 7): Spring Web, Spring Data JPA, Bean Validation
- Maven (via the wrapper, `./mvnw`)
- PostgreSQL 18
- Flyway 12.x for migrations
- JUnit, Mockito, and Testcontainers 2.x (tests run against real Postgres)
- springdoc-openapi 3.x for API docs
- Docker and Docker Compose
- Dashboard (planned): Next.js as a separate service, talking to the API over REST

## Architecture

TODO

## Demo

TODO

## Run with Docker

Create your local environment file and set your own values:

```
cp .env.example .env
```

If another Postgres already listens on port 5432 (for example a Homebrew install), set `DB_PORT=5433` in `.env`. Both Docker Compose and `./mvnw spring-boot:run` read it.

Run the full stack:

```
docker compose up --build
```

To develop locally, start only Postgres and run the app against it:

```
docker compose up -d db
./mvnw spring-boot:run
```

Once running:

- Health check: http://localhost:8080/actuator/health
- API docs (Swagger UI): http://localhost:8080/swagger-ui.html

## Run tests

Docker must be running, because integration tests use Testcontainers Postgres.

```
./mvnw test
```

## License

[MIT](LICENSE)
