# Seamline

A lightweight, unified operations tool for small and mid-size fashion brands. One place to track styles through production, flag delay risk, score suppliers, and (in later phases) forecast demand and connect the tools fashion teams already use.

This is a **portfolio project**. Optimize for: a working demo, clean architecture, tests, and a story I can explain in an interview. It is built in phases (see Roadmap). **Phase 1 target: working demo by end of December 2026.**

## About me (the developer)

- Strong in Python (FastAPI), Postgres, Next.js, Docker basics. Shipped FDV (fashiondatavault.com) in that stack.
- **New to Java and Spring.** Used Java in college only. Teach as you build.
- Background in Operations and Supply Chain, so domain concepts (POs, lead times, BOMs, sell-through) are familiar.

## How to work with me

- **Plan first, then build.** For any non-trivial task, propose a short plan and wait for approval before writing code.
- **Small vertical slices:** migration -> entity -> repository -> service -> controller -> test. Each slice must run and pass tests before moving on.
- **Explain Spring concepts the first time they appear** (dependency injection, JPA entities, transactions, bean lifecycle, etc.) in 2-4 sentences, then don't repeat them.
- When there are two reasonable approaches, tell me the tradeoff and recommend one.
- Prefer boring, conventional patterns over clever ones.
- Commit after each working slice with a clear message.
- **Stay in the current phase.** If something belongs to a later phase, say so and stop. Don't build ahead.
- **Git workflow:** each slice gets its own branch named `slice-N-name` (e.g. `slice-1-styles`). Commit to that branch, never directly to `main`. When the slice is done, push the branch and open a pull request with a summary; I review and merge it myself.

## Teaching mode (default)

I'm learning Java through this project. Split the work so I write the parts that teach me the most and that I'll be asked about in interviews.

**You write:** setup and config, Docker and Compose, the pom, Flyway migrations, test infrastructure, repetitive wiring (repositories, simple CRUD controllers, DTO mapping), seed data, and the dashboard.

**I write, with you as tutor:**

- Business logic: delay risk, reliability score, sell-through, weeks of supply, reorder point, and any other rule with real decisions in it.
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

Versions checked on Nov 9, 2026. Dev machine is an Intel Mac (x64) running Docker Desktop and VS Code.

**Core API (Phase 1)**

- **Java 25** (current LTS). Do not use Java 27: it is a short-lived feature release, superseded in March 2027.
- **Spring Boot 4.1.x** (Spring Framework 7). Stay on 4.1.x for the whole project even if 4.2 ships in November. Do not use 3.x (3.5 is end-of-life).
- Maven via the wrapper (`./mvnw`). Generate the base project with start.spring.io rather than hand-writing the pom.
- Spring Web, Spring Data JPA, Bean Validation
- **PostgreSQL 18** (`postgres:18` image). Not 19 (release candidate only), not 16 or older.
- **Flyway 12.x** for migrations (use Spring Boot's managed version)
- JUnit and Mockito (Spring Boot's managed versions), **Testcontainers 2.x** (tests run against real Postgres, never H2). Testcontainers 2.x dropped JUnit 4 support, so use JUnit 5+ annotations only.
- **springdoc-openapi 3.x** for API docs (the 2.x line is for Spring Boot 3 and will not work here)
- Docker: multi-stage Dockerfile using `eclipse-temurin` 25 images (JDK to build, JRE to run) + `docker-compose.yml` with no `version:` key (obsolete). Check the official `postgres` image notes before mounting a data volume, since the data directory changed in newer major versions.

**Dashboard (end of Phase 1):** Next.js on the current Node LTS, separate service, talks to the API over REST.

**Forecasting service (Phase 2):** Python, FastAPI, pandas, and statsmodels or similar. Separate container in the same Compose file. Pick versions when Phase 2 starts.

## Version policy

- Your training data on versions is stale. Before adding or upgrading any dependency or base image, check the current stable release (start.spring.io, Maven Central, PyPI, npm, Docker Hub, or the project's release page) and tell me which version you chose.
- Prefer versions managed by the Spring Boot BOM. Do not pin Flyway, Testcontainers, JUnit, or Hibernate unless the BOM does not manage them.
- Stable releases only. No release candidates, milestones, or snapshots.
- Most blog posts and Stack Overflow answers target Spring Boot 3.x or earlier. Spring Boot 4 changed things (for example, modular starters). If an example does not compile, check the Boot 4 migration guide before improvising.

## Architecture

A Java modular monolith is the core and owns the database. Later phases add separate services around it.

```
seamline/
  src/main/java/com/seamline/
    core/            styles, milestones, delay-risk logic            (Phase 1)
    suppliers/       suppliers, POs, lead times, reliability score   (Phase 1)
    sales/           SKUs, sales history, inventory snapshots         (Phase 1: schema, API, seed data only)
    costing/         BOM and cost rollup                              (Phase 1 stretch)
    integrations/    connector interface, import/export, Shopify     (Phase 3)
    knowledge/       style attachments, notes, activity log          (Phase 3)
    shared/          error handling, config, common types
  dashboard/         Next.js                                          (Phase 1, end)
  services/forecasting/  Python forecasting service                   (Phase 2)
  docker-compose.yml
```

Rules:

- Each Java module owns its tables, entities, and repositories. **No module touches another module's repository or entities.**
- Cross-module calls go through a small public service interface (e.g. `MilestoneQueries`) and DTOs.
- Controllers stay thin: validate, delegate to a service, map to a DTO. Business logic lives in services.
- Never return JPA entities from controllers. Use records for DTOs.
- **The Java app is the only writer to the database.** Other services (forecasting, dashboard) go through its REST API. Exceptions need my approval.

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

## Design ahead for later phases (do this in Phase 1, build nothing extra)

- **Suppliers** store location (country, port) so a future risk feature can match news to suppliers.
- **Sales and inventory** tables exist from Phase 1, so forecasting needs no schema redesign. Sales history is at SKU level with a date and quantity; inventory is a dated on-hand snapshot per SKU.
- **Styles, SKUs, suppliers, and POs** carry nullable `external_source` and `external_id` columns, so Phase 3 imports can match records without duplicates.
- Lead times are stored per PO with quoted and actual dates, since restock recommendations will use real supplier lead times.

## Testing

- Every endpoint gets at least one happy-path and one failure-path test.
- Service logic with real rules (delay risk, reliability score, reorder point) gets thorough unit tests, including edge cases.
- Integration tests use Testcontainers Postgres.
- Phase 2 forecasts are backtested: train on older data, measure error on a held-out recent period, and compare against a simple baseline (e.g. last year's same weeks or a moving average).
- Don't mark a slice done if tests are red or skipped.

## Commands

```
docker compose up -d db          # start Postgres only
docker compose up --build        # run the full stack
./mvnw test                      # run all Java tests
./mvnw spring-boot:run           # run the app locally against the compose db
```

(If any of these change, or new services add commands, update this section.)

## Domain glossary

- **Style:** a single garment design (e.g. "Oversized linen shirt"), the core entity.
- **SKU:** a sellable variant of a style (style + color + size). Sales and inventory are tracked per SKU.
- **Tech pack:** the spec document for a style (measurements, materials, construction).
- **BOM (bill of materials):** materials needed per style, with quantities and unit costs.
- **Milestone / stage:** a production step with a planned date and an actual date. Typical flow: design -> tech pack -> sampling (proto, fit, sales sample) -> PO placed -> production -> QC -> ship.
- **PO (purchase order):** order to a supplier/factory for a style, with quantity, quoted lead time, and ship date.
- **Lead time:** days from PO placed to goods ready/shipped. Track **quoted** vs **actual**.
- **Delay risk:** a milestone is at risk when its projected date falls behind plan or a slipped upstream stage eats the buffer before a downstream date. (Exact rule to be refined in the first design session. Start simple and document it here.)
- **Reliability score:** per-supplier score from quoted-vs-actual lead times over time. (Formula to be designed. Keep it explainable.)
- **Sell-through rate:** units sold / units received over a period.
- **Weeks of supply:** on-hand units / average weekly sales.
- **Reorder point:** the stock level that triggers a restock, based on forecast demand over the supplier's actual lead time plus safety stock.

## Roadmap

**Phase 1: Production tracking (now through Dec 2026)**

1. **core:** styles, milestones, delay-risk flags
2. **suppliers:** suppliers, POs, quoted vs actual lead time, reliability score
3. **sales:** SKUs, sales history, inventory snapshots (tables, basic read endpoints, no forecasting)
4. Seed data generator: realistic synthetic brands, styles, SKUs, suppliers, slips, and 2+ years of sales with seasonality and trends
5. Dashboard: style timeline, at-risk list, supplier scorecard
6. **costing** (BOM and cost rollup): stretch, only if steps 1-5 landed on time

**Phase 2: Demand forecasting (January 2027)**

- Python service in `services/forecasting/`, reads data and writes results through the Java API.
- Start with explainable metrics: sell-through, weeks of supply, reorder point using each supplier's actual lead time.
- Then a forecasting model, backtested against a simple baseline.
- Dashboard view: what's selling, what to restock, what to produce next.

**Phase 3: Integrations and centralized knowledge (February 2027)**

- `integrations/`: a connector interface, CSV import/export for styles, SKUs, POs, and sales, and outbound webhooks.
- One real connector: **Shopify** (orders and products into sales and SKUs), using a free development store.
- `knowledge/`: attachments (tech packs, images), notes, and an activity log per style.
- Deploy to AWS (container on ECS Fargate or EC2, RDS Postgres) with a billing alert set first.

**Future ideas (not scheduled)**

- News-monitoring agent: ingests supply chain news (ports, tariffs, weather, factory incidents), matches it to supplier locations and materials, and flags affected POs for human review.

## Out of scope (do not build unless I say so)

- Anything from a later phase while the current phase is unfinished
- Authentication, user management, multi-tenancy
- Direct connectors to PLM or design tools (Centric, CLO 3D, Adobe, etc.). We don't have API access; Phase 3's import/export and connector interface cover this.
- Anything not in the roadmap above

## Definition of done (per slice)

- Migration applied cleanly from scratch
- Tests written and passing
- `docker compose up --build` runs the app
- README or this file updated if commands, structure, or rules changed
