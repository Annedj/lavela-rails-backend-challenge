# Lavela Health Backend Take-Home

## Notes on the task

- Clients and providers information (name and email) are encrypted using Active Record Encryption to mirror the future behaviour where all PHI data will be encrypted and kept separate in a different database.
- Master key for these encryptions are stored in `config/credentials.yml.enc` and are decrypted using the `RAILS_MASTER_KEY` environment variable.
- Time zone is set to UTC to avoid issues with timezone conversions.
- Assumption is made that all availability slots in the `test/fixtures/files/calendly_slots.json` correspond to an appointment.
- AvailabilitySync#call is designed to be idempotent, we can run it multiple times without worrying about duplicates.
- However it depends on the provider_id, so we need to reset the database between seed runs to avoid duplicates. For this reason, we would rather use `bin/rails db:reset` to reset the database as written below.

## Task Description

Welcome! This repository is the starting point for a short backend exercise. The goal is to ingest third-party availability data and expose appointment booking endpoints on top of a small scheduling domain.

## Prerequisites

- Ruby 3.4.3 (see `.ruby-version`)
- Bundler (`gem install bundler` if it is missing)
- SQLite (bundled with macOS, no extra setup required)

## Rules
- Please do not use LLM coding tools (Codex, Claude Code, Cursor, etc) to complete this exercise. Looking things up from the web or using ChatGPT as a reference is fine!

## Getting Started

1. Fork this repo.
2. Install dependencies: `bundle install`
3. Create your database schema: add a migration that models the scheduling domain described below, then run `bin/rails db:setup`
4. Run the test suite: `bin/rails test`
5. Add seed data: `bin/rails db:reset`

## What You Need to Build

We're building a simple scheduling app with a database and a few API endpoints. The app should be able to synchronize availability from Calendly for a given provider,
and expose three endpoints:
* `GET /providers/:provider_id/availabilities?from=<datetime>&to=<datetime>`
* `POST /appointments`
* (optional, if you have time) `DELETE /appointents/:id`

To complete this, you'll need to:

1. Design the data model for the core entities. Capture enough attributes to uniquely identify each record, and be able to accurately serve the three endpoints above.
    1. clients (people booking time)
    2. providers (people offering care)
    3. availability windows for each provider
    4. appointments connecting a client to a provider at a specific time.
2. Implement the corresponding ActiveRecord models with associations, validations, and any enums or scopes you find helpful.
3. Implement `AvailabilitySync#call` to fetch slots from `CalendlyClient` and upsert `Availability` records. No external HTTP requests are needed.
4. Expose `GET /providers/:provider_id/availabilities?from=...&to=...` to return free slot windows for a provider that fall within the requested time range.
5. Build `POST /appointments`, taking a client id and a provider id. Should validate that the requested slot fits inside an existing availability window and does not conflict with other appointments. Persists a new appointment in a scheduled state.
6. (Bonus) Implement `DELETE /appointments/:id` to soft-cancel an appointment by marking it as canceled rather than deleting it outright.

## What We Already Provide

- REST routes and empty controllers for:
  - `GET /providers/:provider_id/availabilities`
  - `POST /appointments`
  - `DELETE /appointments/:id` (bonus)
- A Calendly-like client that reads from a local fixture (`app/services/calendly_client.rb`, fixture at `spec/fixtures/calendly_slots.json`)
- A service object stub where you can implement ingest logic (`app/services/availability_sync.rb`)
- Skeleton integration tests with `skip` markers so you can focus on behavior (`test/controllers/*`)


### Calendly data

The data provided by our fake Calendly is a list of objects that represents the weekly schedule of a provider. For simplicity, you can assume that the availability repeats week-over-week with no start or end date.
```json
[
  {
    "id": "p1-slot-early-morning",
    "provider_id": 1,
    "starts_at": {
      "day_of_week": "monday",
      "time": "06:30"
    },
    "ends_at": {
      "day_of_week": "monday",
      "time": "07:00"
    },
    "source": "calendly"
  },
  ...
]
```


### Things to Keep in Mind

- No need to build any auth.
- Enforce data integrity with validations and appropriate error responses.
- Feel free to add more tests or helper classes if they help you demonstrate your approach.
- Document any assumptions or trade-offs directly in code comments or a short write-up.

Good luck, and thanks for taking the time to work on this exercise!
