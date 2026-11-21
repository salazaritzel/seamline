# Seamline: Vision

## One line
Seamline is a free, open-source platform that gives small and mid-size fashion brands full visibility into production, from finding a manufacturer to receiving finished goods.

## The problem
Fashion production is scattered and opaque. A single style passes through sketches, tech packs, sample rounds with several factories, quotes, purchase orders, production, shipping, and warehousing. Each step lives in a different place: email threads, spreadsheets, WhatsApp, PDFs, and separate tools.

Small and mid-size brands feel this most. They care about seeing every step, and about who makes their clothes and under what conditions, but they can't afford enterprise software or a dedicated operations team. When something slips, they usually find out too late.

## Who it's for
- **Brands (first):** small and mid-size fashion brands that manage their own sourcing and production.
- **Manufacturers (later):** factories and workshops that want to be discovered, receive clear tech packs and quote requests, and share production updates in one place.

## What exists today, and the gap
Every piece of Seamline already exists, but as separate products for different buyers:

| Need | Existing tools |
|---|---|
| Find manufacturers, request quotes and samples | Sewport, Maker's Row, World Collective, the CFDA Production Directory |
| Track POs, milestones, and supplier performance | Anvyl (now Sage Supply Chain Intelligence) |
| Certifications, traceability, and supplier risk | TrusTrace, Retraced |
| Tech packs and product development | PLM tools such as Techpacker, Onbrand, and Centric |

A small brand would need several subscriptions, some priced per seat for larger companies, and would still copy data between them by hand. Seamline's angle is one connected, free, open-source place covering the core of that workflow. It does not try to match every feature of the enterprise tools.

## Principles
1. **Visibility at every step.** Every style, sample, and order has a status, a history, and dates you can trust.
2. **Traceability.** You can always see which manufacturer made what, when, and with which certifications.
3. **Explainable logic.** Delay-risk flags and supplier scores show their reasons. No black boxes.
4. **Brand-first, manufacturer-ready.** Build for brands first, but model the data so manufacturers can join later.
5. **Open source and free.** No price tag between a small brand and good operations.

## The full picture (long-term)

**Brand side**
- Explore a directory of manufacturers: capabilities, location, minimums, and certifications.
- Create styles and upload tech packs.
- Request quotes for samples and compare them.
- Place sample orders and track each round: requested, in production, shipped, delivered, approved or revised.
- Place production orders and track them: placed, confirmed, in production, QC, shipped, delivered.
- See delay-risk flags before ship dates are missed.
- Score manufacturers: a computed on-time score from real dates, plus the brand's own rating.

**Manufacturer side**
- Create and manage a directory profile, including certifications.
- Receive tech packs and quote requests, and respond with quotes.
- Update sample and production status as work progresses.

**Intelligence**
- Demand forecasting from sales history: what's selling, what to restock, what to produce next.
- External-disruption risk: flag orders affected by events such as port closures, extreme weather, or conflict near a manufacturer's location.

**Connections**
- Import and export data (CSV), webhooks, and a Shopify connector for sales.

## Phases

**Phase 1: Brand side core**
- Manufacturer directory with certifications, filled with realistic, fictional seed data.
- Styles with tech pack upload.
- Sample orders and production orders as state machines, with a timestamped history of every status change.
- Delay-risk flags with reasons.
- Manufacturer scorecard.
- A simple dashboard.

Done means: in a 2-minute demo, a viewer can browse manufacturers, open a style, see its sample and production orders move through statuses, spot an at-risk order and why, and compare manufacturer scores.

**Phase 2: Manufacturer side**
- Accounts and two roles (brand and manufacturer) with Spring Security.
- Each side sees only its own data.
- Manufacturers manage profiles, answer quote requests, and update order statuses.

**Phase 3: Demand forecasting**
- A Python service for sell-through, weeks of supply, reorder points, and a forecast backtested against a simple baseline.

**Phase 4: Connections and risk**
- CSV import and export, a Shopify connector, deployment to AWS, and the external-disruption risk feature.

## Non-goals
- Building tech packs (measurements, sketches). Seamline stores and shares them; PLM tools create them.
- Payments, invoicing, and logistics booking.
- Matching enterprise tools feature for feature.
- Real manufacturer listings during development. Seed data uses fictional companies so no real factory's details or certifications are misrepresented.

## Why I'm building it
I studied operations and supply chain because I wanted to work in fashion, then moved into software engineering to build solutions to the problems I'd studied. Seamline is where both meet: a real operations problem, modeled carefully and built with modern engineering practices.
## Open questions
- Exact sample and production order statuses, and which transitions are allowed.
- The delay-risk rule: what makes an order "at risk", and how early to flag it.
- The scorecard formula: how to weigh lateness, frequency, and brand ratings.
- How to verify certifications (expiry dates, a verified flag, the document itself).
