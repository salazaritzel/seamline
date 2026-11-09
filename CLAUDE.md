# Seamline

A lightweight, unified production-management tool for small and mid-size fashion brands. It replaces the spreadsheet-and-multiple-tools juggle with one place to track styles through production, flag delay risk, and score suppliers.

This is a **portfolio project**. Optimize for: a working demo, clean architecture, tests, and a story I can explain in an interview. Target: working demo by end of December 2026 (about 7 weeks from Nov 9).

## About me (the developer)
- Strong in Python (FastAPI), Postgres, Next.js, Docker basics. Shipped FDV (fashiondatavault.com) in that stack.
- **New to Java and Spring.** Used Java in college only. Teach as you build.
- Background in Operations and Supply Chain, so domain concepts (POs, lead times, BOMs) are familiar.

## How to work with me
- **Plan first, then build.** For any non-trivial task, propose a short plan and wait for approval before writing code.
- **Small vertical slices:** migration -> entity -> repository -> service -> controller -> test. Each slice must run and pass tests before moving on.
- **Explain Spring concepts the first time they appear** (dependency injection, JPA entities, transactions, bean lifecycle, etc.) in 2-4 sentences, then don't repeat them.
- When there are two reasonable approaches, tell me the tradeoff and recommend one.
- Prefer boring, conventional Spring patterns over clever ones.
- Commit after each working slice with a clear message.

## Stack
Versions checked on Nov 9, 2026. Dev machine is an Intel Mac (x64) running Docker Desktop and VS Code.
- **Java 25** (current LTS). Do not use Java 27: it is a short-lived feature release, superseded in March 2027.
- **Spring Boot 4.1.x** (Spring Framework 7). Stay on 4.1.x for the whole project even if 4.2 ships in November. Do not use 3.x (3.5 is end-of-life).
- Maven via the wrapper (`./mvnw`). Generate the base project with start.spring.io rather than hand-writing the pom.
- Spring Web, Spring Data JPA, Bean Validation
- **PostgreSQL 18** (`postgres:18` image). Not 19 (release candidate only), not 16 or older.
- **Flyway 12.x** for migrations (use Spring Boot's managed version)
- JUnit and Mockito (Spring Boot's managed versions), **Testcontainers 2.x** (tests run against real Postgres, never H2). Testcontainers 2.x dropped JUnit 4 support, so use JUnit 5+ annotations only.
- **springdoc-openapi 3.x** for API docs (the 2.x line is for Spring Boot 3 and will not work here)
- Docker: multi-stage Dockerfile using `eclipse-temurin` 25 images (JDK to build, JRE to run) + `docker-compose.yml` with no `version:` key (obsolete). Services: `app`, `db`, later `dashboard`. Check the official `postgres` image notes before mounting a data volume, since the data directory changed in newer major versions.
- Dashboard (later): Next.js on the current Node LTS, separate service, talks to the API over REST. Check current versions when we get there.

## Version policy
- Your training data on versions is stale. Before adding or upgrading any dependency or base image, check the current stable release (start.spring.io, Maven Central, Docker Hub, or the project's release page) and tell me which version you chose.
- Prefer versions managed by the Spring Boot BOM. Do not pin Flyway, Testcontainers, JUnit, or Hibernate unless the BOM does not manage them.
- Stable releases only. No release candidates, milestones, or snapshots.
- Most blog posts and Stack Overflow answers target Spring Boot 3.x or earlier. Spring Boot 4 changed things (for example, modular starters). If an example does not compile, check the Boot 4 migration guide before improvising.

## Architecture: modular monolith
One Spring Boot app, one database, separate modules. Package by module, not by layer.

```
src/main/java/com/seamline/
  core/          styles, milestones, delay-risk logic
  suppliers/     suppliers, purchase orders, lead times, reliability score
  costing/       BOM and cost rollup (STRETCH, build last)
  shared/        error handling, config, common types
```

Rules:
- Each module owns its tables, entities, and repositories. **No module touches another module's repository or entities.**
- Cross-module calls go through a small public service interface (e.g. `MilestoneQueries`) and DTOs.
- Controllers stay thin: validate, delegate to a service, map to a DTO. Business logic lives in services.
- Never return JPA entities from controllers. Use records for DTOs.

## Java conventions
- Constructor injection only. No field `@Autowired`.
- Records for DTOs and value objects.
- Use `java.time` (`LocalDate`, `Instant`). Never `Date`.
- Money: `BigDecimal` plus an explicit currency. Never `double`.
- Enums for stage and status values, stored as strings (`@Enumerated(EnumType.STRING)`).
- Handle errors with a global `@RestControllerAdvice` returning a consistent JSON error shape.
- Keep methods short. Name things in domain language.

## Database rules
- Flyway only: `src/main/resources/db/migration/V{n}__{description}.sql`.
- **Never edit a migration that has been applied.** Add a new one.
- Snake_case tables and columns, plural table names, `id` as the primary key, `created_at` and `updated_at` on every table.
- Add indexes for foreign keys and any column used in filters.

## Testing
- Every endpoint gets at least one happy-path and one failure-path test.
- Service logic with real rules (delay risk, reliability score) gets thorough unit tests, including edge cases.
- Integration tests use Testcontainers Postgres.
- Don't mark a slice done if tests are red or skipped.

## Commands
```
docker compose up -d db          # start Postgres only
docker compose up --build        # run the full stack
./mvnw test                      # run all tests
./mvnw spring-boot:run           # run the app locally against the compose db
```
(If any of these change, update this section.)

## Domain glossary
- **Style:** a single garment design (e.g. "Oversized linen shirt"), the core entity.
- **Tech pack:** the spec document for a style (measurements, materials, construction).
- **BOM (bill of materials):** materials needed per style, with quantities and unit costs.
- **Milestone / stage:** a production step with a planned date and an actual date. Typical flow: design -> tech pack -> sampling (proto, fit, sales sample) -> PO placed -> production -> QC -> ship.
- **PO (purchase order):** order to a supplier/factory for a style, with quantity, quoted lead time, and ship date.
- **Lead time:** days from PO placed to goods ready/shipped. Track **quoted** vs **actual**.
- **Delay risk:** a milestone is at risk when its projected date falls behind plan or a slipped upstream stage eats the buffer before a downstream date. (Exact rule to be refined in the first design session. Start simple and document it here.)
- **Reliability score:** per-supplier score from quoted-vs-actual lead times over time. (Formula to be designed. Keep it explainable.)

## Build order
1. **core:** styles, milestones, delay-risk flags
2. **suppliers:** suppliers, POs, quoted vs actual lead time, reliability score
3. Seed data generator (realistic synthetic brands, styles, suppliers, slips)
4. Dashboard: style timeline, at-risk list, supplier scorecard
5. **costing** (BOM and cost rollup): only if weeks 1-5 landed on time

## Out of scope (do not build unless I say so)
- Authentication, user management, multi-tenancy
- Real integrations with PLM/ERP tools
- News/risk-monitoring agent (a future post-MVP idea, see below)
- Anything not in the build order above

## Future idea (not now)
A news-monitoring agent that ingests supply chain news (ports, tariffs, weather, factory incidents), matches it to supplier countries/ports/materials already in the database, and flags affected POs for human review. Design the supplier data model so location (country, port) is stored and queryable, but don't build the agent yet.

## Definition of done (per slice)
- Migration applied cleanly from scratch
- Tests written and passing
- `docker compose up --build` runs the app
- README or this file updated if commands, structure, or rules changed
