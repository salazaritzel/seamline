# Seamline

A free, open-source platform that gives small and mid-size fashion brands full visibility into production: finding and vetting manufacturers, sharing tech packs, tracking sample and production orders, flagging delay risk, and scoring manufacturers. The full product vision is in `docs/vision.md`; read it before planning a new phase.

This is a **portfolio side project**. Optimize for a working demo, clean architecture, tests, and a story I can explain in an interview. It is built in phases (see Roadmap). **Phase 1 target: end of January 2027 (flexible).**

## About me (the developer)
- Strong in Python (FastAPI), Postgres, Next.js, Docker basics. Shipped FDV (fashiondatavault.com) in that stack.
- **New to Java and Spring.** Used Java in college only. Teach as you build.
- Background in Operations and Supply Chain, so domain concepts (POs, lead times, sampling, certifications) are familiar.

## How to work with me
- **Plan first, then build.** For any non-trivial task, propose a short plan and wait for approval before writing code.
- **Small vertical slices:** migration -> entity -> repository -> service -> controller -> test. Each slice must run and pass tests before moving on.
- **Explain Spring concepts the first time they appear** (dependency injection, JPA entities, transactions, bean lifecycle, etc.) in 2-4 sentences, then don't repeat them.
- When there are two reasonable approaches, tell me the tradeoff and recommend one.
- Prefer boring, conventional patterns over clever ones.
- Commit after each working slice with a clear message, and update `docs/progress.md`.
- **Stay in the current phase.** If something belongs to a later phase, say so and stop. Don't build ahead.

## Teaching mode (default)
I'm learning Java through this project. Split the work so I write the parts that teach me the most and that I'll be asked about in interviews.

**You write:** setup and config, Docker and Compose, the pom, Flyway migrations, test infrastructure, repetitive wiring (repositories, simple CRUD controllers, DTO mapping), file storage plumbing, seed data, and the dashboard.

**I write, with you as tutor:**
- Business logic: order status transitions, delay risk, the manufacturer scorecard, certification validity, and any other rule with real decisions in it.
- At least one entity and one service per slice, so I practice core Java and Spring by hand.

**How to tutor me:**
1. In every slice plan, label each task **(you)** or **(Itzel)**.
2. For my tasks, first explain the concept and the Java or Spring features I'll need, in a few sentences.
3. Write the tests first, run them so I can see them fail, and tell me what they check.
4. Create the file with the class and method signatures only, plus a `// TODO (Itzel)` comment. Leave the bodies for me.
5. When I'm stuck, give a hint, then a bigger hint. Only show a full solution if I ask "show me" after trying.
6. When I say "review", run the tests and review my code: what works, what to improve, and why. Let me make the fixes myself unless I ask you to.
7. Never rewrite my code without asking. If you change it, explain each change.

If I say "you write it" for a specific task, do it, and explain the code afterward.

## Stack
Versions checked on Nov 16, 2026. Dev machine is an Intel Mac (x64) running Docker Desktop and VS Code.

**Core API (Phases 1-2)**
- **Java 25** (current LTS). Do not use Java 27: it is a short-lived feature release.
- **Spring Boot 4.1.x** (Spring Framework 7). Currently 4.1.2. Stay on 4.1.x; do not move to 4.2 mid-project. Do not use 3.x (3.5 is end-of-life).
- Maven via the wrapper (`./mvnw`).
- Spring Web MVC, Spring Data JPA, Bean Validation, Actuator
- **PostgreSQL 18** (`postgres:18` image), exposed on host port **5433** because Homebrew Postgres 17 uses 5432 on my Mac.
- **Flyway 12.x** for migrations (Spring Boot's managed version)
- JUnit and Mockito (Spring Boot's managed versions), **Testcontainers 2.x** (tests run against real Postgres, never H2). Use JUnit 5+ annotations only.
- **springdoc-openapi 3.x** for API docs (the only hand-pinned version)
- **Spring Security:** Phase 2 only.
- Docker: multi-stage Dockerfile using `eclipse-temurin` 25 images (JDK to build, JRE to run) + `docker-compose.yml` with no `version:` key. The Postgres 18 data volume mounts at `/var/lib/postgresql`.

**Dashboard (end of Phase 1):** Next.js on the current Node LTS, separate service, talks to the API over REST.

**Forecasting service (Phase 3):** Python, FastAPI, pandas, statsmodels or similar. Separate container in the same Compose file.

## Version policy
- Your training data on versions is stale. Before adding or upgrading any dependency or base image, check the current stable release (start.spring.io, Maven Central, PyPI, npm, Docker Hub, or the project's release page) and tell me which version you chose.
- Prefer versions managed by the Spring Boot BOM. Do not pin Flyway, Testcontainers, JUnit, or Hibernate unless the BOM does not manage them.
- Stable releases only. No release candidates, milestones, or snapshots.
- Most blog posts and Stack Overflow answers target Spring Boot 3.x or earlier. Spring Boot 4 changed things (for example, modular starters and `RestTestClient`). If an example does not compile, check the Boot 4 migration guide before improvising.

## Architecture
A Java modular monolith is the core and owns the database. Later phases add separate services around it.

```
seamline/
  src/main/java/com/seamline/
    manufacturers/   directory, capabilities, location, certifications      (Phase 1)
    styles/          styles, tech pack files                                (Phase 1)
    orders/          sample orders, production orders, status history       (Phase 1)
    risk/            delay-risk rules and flags                             (Phase 1)
    scoring/         manufacturer scorecard                                 (Phase 1)
    accounts/        users, brands, roles, security                         (Phase 2)
    quotes/          quote requests and responses                           (Phase 2)
    sales/           SKUs, sales history, inventory snapshots               (Phase 3)
    integrations/    CSV import/export, webhooks, Shopify                   (Phase 4)
    shared/          error handling, config, common types
  dashboard/         Next.js                                                (Phase 1, end)
  services/forecasting/  Python forecasting service                         (Phase 3)
  docs/              vision.md, progress.md
  docker-compose.yml
```

Rules:
- Each Java module owns its tables, entities, and repositories. **No module touches another module's repository or entities.**
- Cross-module calls go through a small public service interface (e.g. `OrderQueries`) and DTOs.
- Controllers stay thin: validate, delegate to a service, map to a DTO. Business logic lives in services.
- Never return JPA entities from controllers. Use records for DTOs.
- **The Java app is the only writer to the database.** Other services go through its REST API. Exceptions need my approval.
- **Uploaded files** (tech packs, certification documents) are stored outside the database: a Docker volume in Phases 1-3, S3 in Phase 4. The database stores only metadata (file name, type, size, storage key, uploaded_at). Accept PDF and common image types only, with a size limit.

## Java conventions
- Constructor injection only. No field `@Autowired` in application code.
- Records for DTOs and value objects.
- Use `java.time` (`LocalDate`, `Instant`). Never `Date`.
- Money: `BigDecimal` plus an explicit currency. Never `double`.
- Enums for statuses and types, stored as strings (`@Enumerated(EnumType.STRING)`).
- Handle errors with a global `@RestControllerAdvice` returning a consistent JSON error shape.
- Keep methods short. Name things in domain language.

## Database rules
- Flyway only: `src/main/resources/db/migration/V{n}__{description}.sql`.
- **Never edit a migration that has been applied.** Add a new one.
- Snake_case tables and columns, plural table names, `id` as the primary key, `created_at` and `updated_at` on every table.
- Add indexes for foreign keys and any column used in filters.

## Design ahead for later phases (do this in Phase 1, build nothing extra)
- **Manufacturers** store location (country, city, nearest port) for the Phase 4 disruption-risk feature.
- **Brand ownership:** styles and orders carry a `brand_id`, even though Phase 1 has a single seeded brand and no login. Phase 2 adds accounts and permissions without reshaping the tables.
- **Manufacturer ownership:** a nullable `owner_account_id` on manufacturers, filled in Phase 2 when factories manage their own profiles.
- **Status changes** are recorded in a history table (from status, to status, changed_at, changed_by), so Phase 2 can record who made each change.
- Styles, manufacturers, and orders carry nullable `external_source` and `external_id` columns for Phase 4 imports.

## Testing
- Every endpoint gets at least one happy-path and one failure-path test.
- Rules with real decisions (status transitions, delay risk, scorecard, certification validity) get thorough unit tests, including edge cases.
- Integration tests use Testcontainers Postgres. Test class names must end in `Test` or `Tests`, or `./mvnw test` skips them.
- Phase 3 forecasts are backtested against a simple baseline.
- Don't mark a slice done if tests are red or skipped.

## Commands
```
docker compose up -d db          # start Postgres only (host port 5433)
docker compose up --build        # run the full stack
docker compose down              # stop everything
./mvnw test                      # run all Java tests (Docker Desktop must be running)
./mvnw spring-boot:run           # run the app locally against the compose db (reads .env)
```
Health check: `http://localhost:8080/actuator/health`. API docs: `http://localhost:8080/swagger-ui.html`.
(If any of these change, or new services add commands, update this section.)

## Domain glossary
- **Brand:** the fashion company using Seamline. Phase 1 has one seeded brand.
- **Manufacturer:** a factory or workshop in the directory, with capabilities (product types, materials), location, minimum order quantity, and certifications.
- **Certification:** a standard a manufacturer holds, e.g. GOTS or OEKO-TEX (materials), Fair Trade, SA8000, or WRAP (workers' rights), bluesign or ISO 14001 (environmental). Stored with issuing body, issue and expiry dates, a verified flag, and an optional document.
- **Style:** a single garment design (e.g. "Oversized linen shirt"), the core entity a brand works on.
- **Tech pack:** the spec document for a style (measurements, materials, construction). Seamline stores the file; it does not build tech packs.
- **Sample order:** a request to a manufacturer to make a sample of a style. A style can have several sample rounds, possibly with different manufacturers.
- **Production order (PO):** a confirmed order for a style with quantity, price, and planned dates.
- **Order status:** each sample and production order moves through defined statuses with timestamps. Proposed starting point, to refine in design:
  - Sample: REQUESTED -> IN_PRODUCTION -> SHIPPED -> DELIVERED -> APPROVED or REVISION_NEEDED
  - Production: PLACED -> CONFIRMED -> IN_PRODUCTION -> QC -> SHIPPED -> DELIVERED
  - Either can be CANCELLED before SHIPPED.
- **Planned vs actual dates:** each order has planned dates for key statuses; actual dates come from the status history.
- **Delay risk:** an order is at risk when it is behind plan, or a late earlier status leaves too little buffer before a later planned date. Every flag carries a plain-language reason. (Exact rule to be designed with me.)
- **Manufacturer scorecard:** a computed on-time score from planned vs actual dates, plus the brand's own rating. (Formula to be designed with me. Keep it explainable.)

## Roadmap
**Phase 1: Brand side core (target end of January 2027, flexible)**
1. **manufacturers:** directory with capabilities, location, and certifications; search and filter endpoints
2. **styles:** styles with tech pack upload
3. **orders:** sample orders and production orders, allowed status transitions, status history
4. **risk:** delay-risk flags with reasons
5. **scoring:** manufacturer scorecard
6. Seed data: one brand, 15-25 fictional manufacturers in several countries with certifications, styles, and orders in different states (some on time, some late)
7. Dashboard: manufacturer directory, style detail with order timelines, at-risk list, scorecard

**Phase 2: Manufacturer side**
- `accounts/`: sign-up and login, brand and manufacturer roles, with Spring Security.
- Data isolation: brands see only their styles and orders; manufacturers see only orders sent to them.
- Manufacturers manage their own profile and certifications.
- `quotes/`: brands send quote requests with a tech pack; manufacturers respond.
- Manufacturers update sample and production order statuses.

**Phase 3: Demand forecasting**
- `sales/` tables and seed data with seasonality.
- Python service in `services/forecasting/`: sell-through, weeks of supply, reorder points, then a forecast backtested against a simple baseline.

**Phase 4: Connections and risk**
- CSV import and export, outbound webhooks, and a Shopify connector.
- External-disruption risk: match events (port closures, weather, conflict) to manufacturer locations and flag affected orders for review.
- Deploy to AWS (ECS Fargate or EC2, RDS Postgres, S3 for files) with a billing alert set first.

## Out of scope (do not build unless I say so)
- Anything from a later phase while the current phase is unfinished
- Authentication, user management, and multi-tenancy before Phase 2
- Building tech packs (measurements, sketches); Seamline only stores the files
- Payments, invoicing, and freight booking
- Direct connectors to PLM or design tools (Centric, CLO 3D, Adobe, etc.)
- Real manufacturer names or data in seed data: use fictional companies

## Definition of done (per slice)
- Migration applied cleanly from scratch
- Tests written and passing
- `docker compose up --build` runs the app
- `docs/progress.md` updated
- README or this file updated if commands, structure, or rules changed
