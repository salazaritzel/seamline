# Seamline

A lightweight, unified production-management tool for small and mid-size fashion brands. Seamline replaces the spreadsheet-and-multiple-tools juggle with one place to track styles through production, flag delay risk, and score suppliers.

## Status

<!-- TODO: fill in current status -->

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

> The application, Dockerfile, and `docker-compose.yml` are not in the repo yet, so these commands will not work until they are added.

Create your local environment file and set your own values:

```
cp .env.example .env
```

Run the full stack:

```
docker compose up --build
```

To develop locally, start only Postgres and run the app against it:

```
docker compose up -d db
./mvnw spring-boot:run
```

## Run tests

Docker must be running, because integration tests use Testcontainers Postgres.

```
./mvnw test
```

## License

[MIT](LICENSE)
