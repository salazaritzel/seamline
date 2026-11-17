# Progress

## Phase 1, slice 0: project skeleton (done, Nov 2026)

- Spring Boot 4.1.2 on Java 25, generated from start.spring.io (Maven wrapper 3.10.1).
- PostgreSQL 18 via Docker Compose; Flyway 12.4 with a comment-only `V1__baseline.sql`.
- Hibernate runs in `validate` mode: Flyway owns the schema.
- Actuator exposes only `/actuator/health` (includes the `db` check). Swagger UI at `/swagger-ui.html` (springdoc 3.2.0, the only hand-pinned version).
- Tests run against Testcontainers `postgres:18`: context loads, health `UP` with `db` `UP`, Flyway applied V1, `/actuator/env` returns 404.
- Multi-stage Dockerfile (Temurin 25 JDK to build, JRE to run, non-root user) and `docker-compose.yml` (`db` + `app`).

## Next: slice 1, styles (core module)

Start the `core` module with styles: migration, entity, repository, service, controller, tests. Propose the plan before writing code.

## Things to remember

- **Postgres runs on host port 5433 on this machine.** Homebrew `postgresql@17` already uses 5432, so the local `.env` sets `DB_PORT=5433`. Inside Compose, the app still connects to `db:5432`.
- `./mvnw spring-boot:run` reads `.env` directly, through `spring.config.import` in `application.yml`.
- Test classes must end in `Test` or `Tests`. `./mvnw test` (Surefire) silently skips `*IT` classes.
- Tests need Docker Desktop running. The Docker build skips tests, so run `./mvnw test` on the host.
- Boot 4 test HTTP client: `RestTestClient` with `@AutoConfigureRestTestClient`.
- Postgres 18 volume mounts at `/var/lib/postgresql`, not `/var/lib/postgresql/data`.
