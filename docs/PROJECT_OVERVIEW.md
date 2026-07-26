# Project Overview: bglmautam

_Last updated: 2026-07-26_

## What this project is

**bglmautam** ("Mautam") is the backend for a **Vietnamese Catholic parish catechism ("giáo lý") program management system**, for a parish referred to as "Mautam" (production domain `bglmautam.com`). It tracks students ("Thiếu Nhi"), catechism teachers ("Giáo Lý Viên" / GLV), classes organized by year and level (following stages like `Khai Tâm`, `Rước Lễ`, `Thêm Sức`, `Bao Đồng`, `Vào Đời`), sacramental milestones (Baptism, Communion, Confirmation, Declaration), attendance, and grading.

It is **Ruby on Rails 7.2.3 / Ruby 3.3.0**, backed by **PostgreSQL**, and is **mid-migration** from a monolithic server-rendered Rails app to a **Rails JSON API + separate React SPA** (`bglmautam-react`, hosted at `acadex.bglmautam.com`). Both the legacy HTML UI and the new `/api/v1` API currently coexist in the same codebase. See `MIGRATION_PLAN.md` for the phase-by-phase migration tracker.

---

## End-user perspective

### Who can use it, and what they can do

There is no self-service signup — accounts are provisioned by an admin. Two implicit roles exist (not a formal enum):

- **Admin** (`users.admin` flag) — full access to everything: managing people, students, teachers, classrooms, enrollments, teaching assignments, attendance, evaluations, grades, user accounts, and the custom-fields schema system.
- **Teacher / GLV** (a `user` linked to a `teacher` record) — scoped access: can manage attendance, evaluations, and grades only for classrooms they are assigned to teach in the **current school year** (via their `teaching_assignments`). Can view most records but cannot create/delete most resources or manage other teachers' classes.
- Everyone authenticated gets read access (list/search/view) by default; write access is admin-only unless a policy explicitly grants the teacher-of-this-classroom exception.
- **Students and parents have no login** — they exist only as managed records, not accounts.

### Core features

- **Classroom management** — classes organized by academic year and level/family (`Khai Tâm`, `Rước Lễ`, `Thêm Sức`, `Bao Đồng`, `Vào Đời`, etc.), with roster, attendance, and evaluation views per class.
- **Student records** — personal info, sacrament dates/places (Baptism, Communion, Confirmation, Declaration), parent contact info, enrollment history and per-year classroom placement, evaluations/grades.
- **Teacher records** — personal info, contact details, teaching assignments (which classes/positions they've taught, by year).
- **Attendance tracking** — daily/session attendance for both students (via enrollment) and teachers (via teaching assignment), including excused/late status, notes, and substitute-teacher tracking when a teacher is out.
- **Evaluations & grades** — free-text evaluation/comments per student per class, plus weighted numeric grades per enrollment.
- **Custom fields** — admins can define additional structured fields (text/number/select/date/checkbox/textarea) on People, Enrollments, or Teaching Assignments without a schema migration, via the `DataSchema`/`data` (jsonb) system.
- **Reporting/export** — extensive PDF generation (class rosters, personal-detail sheets, attendance sheets, teacher contact sheets, custom column exports, statistics) and Excel (XLSX) export for students/teachers/classrooms.
- **Global search** — fuzzy search across people/students/teachers.
- **Unified person view** — a single `Person` record links a student, teacher, and/or user account together when the same individual holds multiple roles (e.g., a former student who becomes a teacher).

---

## Technical perspective

### Data model — what's managed and how

Core entities (all in `app/models/`), all soft-deletable (`paranoia` gem, `deleted_at`) and version-audited (`paper_trail` gem) via a shared `ApplicationRecord` base:

| Entity | Purpose |
|---|---|
| `Person` | Unifying identity record — name, gender, birth info, avatar, flattened contact/address fields, `data` jsonb for custom fields. `has_one :user/:teacher/:student`. |
| `Student` | Sacrament dates/places, parent contact info, legacy address/phone fields (synced into `Person`). |
| `Teacher` | Contact info, occupation, legacy address/phone fields (synced into `Person`). |
| `Classroom` | Year, family/level, group, location. |
| `Enrollment` | Join of student ↔ classroom for a year, plus `result` (outcome, from `ResourceType` lookup). |
| `TeachingAssignment` | Join of teacher ↔ classroom for a year, plus `position` (from `ResourceType` lookup). |
| `Attendance` | Polymorphic (`attendable`: `Enrollment` or `TeachingAssignment`) — date, status, substitute-teacher tracking. |
| `Evaluation` | Polymorphic (`evaluable`: `Enrollment`) — free-text comments. |
| `Grade` | Weighted numeric grade per `Enrollment`. |
| `User` | Login account — username/password (bcrypt), `admin` flag, linked to `Person`/`Teacher`. |
| `DataSchema` / `ResourceType` | Admin-configurable metadata: custom field definitions and lookup/enum-style values (no Rails `enum` macros are used anywhere — all "state" fields are plain strings validated against `ResourceType` rows). |
| `Organization` | Tenant record (name, slug, contact/address) — see multi-tenancy below. |

Notable in-progress technical states:

- **Contact/address flattening (recently completed)**: `Address`/`Phone`/`Email` were previously separate polymorphic tables; their data has been flattened directly onto `Person` (and duplicated onto `Organization`). The old tables still exist in the DB, pending a not-yet-written migration to drop them. `Student`/`Teacher` still carry their own legacy copies of these fields, synced into `Person` via a `before_validation :sync_person` callback — this dual storage is a deliberate, temporary transitional state.
- **Multi-tenancy (in progress, not enforced)**: An `Organization` model and nullable `organization_id` columns have been added to all 12 domain tables, but **no model uses `acts_as_tenant`, no controller sets a current tenant, and no query is actually scoped by organization** — the gem is installed and the schema is ready, but today all data is still effectively global/single-tenant. See `MULTITENANCY_PLAN.md` (Phases 1–2 of 5 done; backfill, NOT NULL enforcement, and tenant wiring are pending).
- **Vietnamese address format overhaul (planned, not started)**: `docs/VIETNAMESE_ADDRESS_PLAN.md` describes introducing `VnProvince`/`VnDistrict`/`VnWard` reference tables (seeded from `provinces.open-api.vn`) and migrating `people`/`organizations` to `province_code`/`ward_code`-based addressing. No code exists yet — this is purely a planning document.

### Authorization — who can manage what, technically

- **Authentication**: two parallel schemes, no Devise — session/cookie-based for the legacy web UI (`bcrypt` via `has_secure_password`), and JWT-in-httponly-cookie (15-min access / 7-day refresh) for the `/api/v1` API consumed by the React frontend.
- **Authorization**: `pundit` gem. A custom `UserContext` (user + current school year) drives year-scoped policy checks. Default policy: read (`index?`/`show?`) open to any authenticated user; write actions admin-only unless a policy explicitly grants "admin or teacher of this classroom/student/enrollment." No formal role enum — "teacher" is inferred from `user.teacher` being present; a future `super_admin` role (for multi-tenant cross-org access) is planned but not yet implemented.
- **No admin-panel gem** (no ActiveAdmin/RailsAdmin) — admin-only functionality is just regular controllers/policies gated on `user.admin?`.

### Architecture notes

- Legacy server-rendered controllers/views coexist with a full `/api/v1` JSON API (serializers via `active_model_serializers`, filtering via `ransack`, pagination via `kaminari`); PDF/XLSX export logic is currently duplicated between the two UIs during the migration.
- No background jobs or mailers exist in the codebase (no `app/jobs`, `app/mailers`) — no async processing or email notifications.
- No automated test suite currently exists (`test/` is effectively empty).
- Deployed on a Hostinger VPS behind Cloudflare, Nginx + Puma (PM2-managed), per `docs/PRODUCTION.md`. Known pending production hardening items (tracked in `MIGRATION_PLAN.md`): `consider_all_requests_local = true` and debug-level logging left on in production, and a plaintext DB password in `config/database.yml`.

### Active development arc (recent commits)

The most recent development sequence: (1) Pundit/policy refactor → (2) multi-tenancy foundation (`Organization` model + `organization_id` columns) → (3) flattening `Address`/`Email`/`Phone` into `Person` → (4) new address fields laying groundwork for the Vietnamese address migration.

---

## Related docs

- `MIGRATION_PLAN.md` — Rails API + React frontend migration tracker
- `MULTITENANCY_PLAN.md` — multi-tenancy rollout plan
- `docs/VIETNAMESE_ADDRESS_PLAN.md` — Vietnamese address format migration plan
- `docs/PRODUCTION.md` — production ops runbook
