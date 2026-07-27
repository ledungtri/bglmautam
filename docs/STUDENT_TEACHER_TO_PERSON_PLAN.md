# Consolidate Student/Teacher into Person

> **Status:** Steps 1-4 ✅ implemented and verified locally (2026-07-27) — not yet deployed to production. Steps 5-9 not yet detailed here.
> **Related:** `MIGRATION_PLAN.md` Phase S.

**Verification performed (2026-07-27):** implemented and dress-rehearsed against a full copy of production-scale data (1978 students, 2290 people) in local dev — ran the complete migration chain (sacrament columns → backfill → drop redundant columns) cleanly, confirmed backfilled sacrament data matches source Student records exactly (spot-checked), confirmed `db/schema.rb` matches a fresh `db:schema:dump` byte-for-byte, ran the full Minitest suite (9/9 passing), and functionally verified via real HTTP requests: `/people/:id` renders correctly (sacraments section shows via the new native form, no crash from the removed `data_fields` render call), submitting the parents_info custom-fields form now actually persists (confirming the step 1 bug fix), and both `/students/:id` and `/teachers/:id` still render correctly with the `attr_accessor`/`after_find` bridge in place.

**One unrelated bug found and fixed during this verification:** `config/database.yml`'s `ENV.fetch("DATABASE_PASSWORD")` (added in Phase N) was breaking `development`/`test` environments too, not just guarding production — Rails renders the entire `database.yml` through ERB before selecting the active environment's section, so a bare `.fetch` with no default anywhere in the file raises regardless of `RAILS_ENV`. Changed to `ENV["DATABASE_PASSWORD"]` (no exception if unset) — production behavior is unchanged since the env var is already set there.

---

## Context

`Person` becomes the single canonical model. `Student` and `Teacher` are decommissioned entirely, not merely thinned — `sync_person` is transitional bridge scaffolding for this migration, not a permanent dual-write. This extends the same expand-and-contract pattern Phase O used for contact fields.

**Field disposition:**
- **Sacraments** (`date_baptism`/`place_baptism`, communion, confirmation, declaration) → **native columns on `people`**, carrying the same presence-pairing validations `Student` has today (`validates_presence_of :date_baptism, if: :place_baptism?`, etc.). Not custom fields — this data is used in PDFs/exports and completion-tracking logic, and is core/universal rather than tenant-variable.
- **Parent info** (father/mother christian_name, full_name, phone) → **custom fields** via the existing `DataSchema` entity `Person` / key `parents_info` (seeded in `lib/tasks/create_data_schemas.rake`). These fields are only ever read for display (`students_excel_export.rb`, `_info_table.html.erb`, `attendances.html.erb`) — never filtered, sorted, or joined — so jsonb has no query-performance downside here.
- **Teacher occupation / patron day (`named_date`)** → **custom fields** via existing `DataSchema` entity `Person` / key `additional_info` (already seeded).
- **Existing `DataSchema` key `sacraments` (entity `Person`)** must be removed once sacraments become native columns — it's currently a conflicting write path (see bug below).

**Known bug this migration fixes:** `Student#sync_person` overwrites `person.data['sacraments']`/`person.data['parents_info']` wholesale on every `Student` save (`person.data = {...}`), while `DataFieldsController#update` lets the Person profile page edit `person.data` directly with no write-back to `Student`'s real columns. Whichever was saved more recently silently wins. Moving sacraments to native `Person` columns and parent-info fully to `Person`-scoped custom fields (merged via `update_data_field`, not wholesale overwrite) collapses this to one write path.

**Second bug found during planning (blocks step 1):** `DataFieldsController#data_field_params` does `@schema.fields.map { |f| f['field'] }`, but every seeded schema (`create_data_schemas.rake`) and the rendering partials (`_data_fields.html.erb:16`, `_input_field.html.erb:4`) use the key `field_name`, not `field`. Today, submitting the Person-profile custom-fields form (sacraments/parents_info/additional_info) silently permits nothing — the update is a no-op. Must be fixed as part of step 1, or the required-field validator has nothing real to validate against.

---

## Steps 1-4 (planned in detail)

### Step 1 — Required-field enforcement for custom (jsonb) fields

- Fix the bug: `app/controllers/data_fields_controller.rb` — change `data_field_params` to read `f['field_name']` instead of `f['field']`.
- Add the validator: `app/models/concerns/data_fieldable.rb` — add an `included do validate :validate_required_data_fields end` block plus a private method that, for each `DataSchema.where(entity: self.class.name)`, checks every field flagged `required: true` and adds an error if `data_field_value(schema.key, field['field_name'])` is blank. `Person` is the only includer of `DataFieldable` today, so this is scoped correctly with no other model affected.
- No schema/field data changes needed — `required` already round-trips through `Api::V1::DataSchemasController` (`fields: [..., :required, ...]` permitted at `data_schemas_controller.rb:69`); it just wasn't read by anything. No field is currently seeded with `required: true`, so this is additive (no behavior change until someone flags a field required via the DataSchema admin UI).
- Scoped to `required` presence only — no `format` support. Student's `father_phone`/`mother_phone` digits-only format check has no equivalent elsewhere on `Person` (`phone`, `Organization#phone` aren't format-validated either), so it's dropped rather than generalizing the validator.

**Files:** `app/models/concerns/data_fieldable.rb`, `app/controllers/data_fields_controller.rb`.

### Step 2 — Sacrament native columns on `people`

- Migration `AddSacramentColumnsToPeople`: adds `date_baptism`, `place_baptism`, `date_communion`, `place_communion`, `date_confirmation`, `place_confirmation`, `date_declaration`, `place_declaration` to `people` (types matching `students`: `date_*` as `:date`, `place_*` as `:string`).
- `app/models/person.rb`:
  - Add the same presence-pairing validations `Student` has today: `validates_presence_of :date_baptism, if: :place_baptism?` (×4 pairs), copied verbatim.
  - Add a `sacraments` entry to `Person::FIELD_SETS`, matching `Student::FIELD_SETS`'s `sacraments` key/labels.
  - Add `father_name`/`mother_name` helper methods, reading from the `parents_info` custom field (`data_field_value('parents_info', 'father_christian_name')` etc.) — these already populate correctly today via `Student#sync_person`'s existing (buggy but data-compatible) writes, confirmed by matching field-name keys between `sync_person` and the `create_data_schemas.rake` seed.
  - Update schema annotation comment.
- **Not ported:** `Student.result(classroom)` has zero callers anywhere in `app/` — dead code, not worth porting. `validates_presence_of :gender, :date_birth` + the `Nam`/`Nữ` inclusion check, and the `in_classroom` scope are **already present on `Person` independently** (`person.rb:62-63`, `person.rb:65`) — the doc was slightly stale here; no action needed beyond noting the existing duplication collapses naturally once `Student` is dropped in step 9.
- **UI note:** `app/views/people/show.html.erb` renders `Person::FIELD_SETS` via `components/form/form`, then separately renders `components/form/data_fields` with `schema_key: 'sacraments'` right below it. Adding a `sacraments` `FIELD_SETS` entry here means `/people/:id` will show sacrament fields **twice** — once in the new native form section, once in the still-present old custom-fields section — until step 3 removes the latter. This duplication is expected and temporary, not a bug to fix in step 2.

**Files:** new migration, `app/models/person.rb`.

### Step 3 — Bridge `Student#sync_person`, retire the `sacraments` DataSchema entry

- Backfill migration `BackfillSacramentColumnsOnPeopleFromStudents`: for every `Student`, set the linked `Person`'s new native sacrament columns, preferring the `Student`'s own column value and falling back to the existing `person.data['sacraments']` value when the `Student` field is blank (handles the known write-conflict — a Person-profile-page edit could be more recent than a stale/never-touched `Student` field). This is an addition beyond the doc's literal text, since dropping read access to `data['sacraments']` without backfilling would silently lose whichever side wasn't reflected in `Student`'s own columns.
- `app/models/student.rb`: update `sync_person` to assign `person.date_baptism = date_baptism` etc. (native columns) instead of writing into `person.data['sacraments']`; drop the `'sacraments'` key from the `person.data = {...}` hash entirely (the `'parents_info'` key stays here for now — that only moves in step 4).
- Data cleanup (rake task or one-off console command, not a schema migration): `DataSchema.find_by(key: 'sacraments', entity: 'Person')&.destroy` — removes the now-obsolete custom-field definition so it stops appearing in the Person profile's custom-fields UI. Needs to run in every environment that ran `create_data_schemas.rake` (dev/staging/prod).
- **Required, not optional:** `app/views/people/show.html.erb` — remove the `render 'components/form/form/data_fields', object: @person, schema_key: 'sacraments', editable: editable` block. `_data_fields.html.erb` does `schema = DataSchema.find_by_key(schema_key); title = schema.title` with no nil guard — if the `DataSchema` row is deleted but this render call is left in place, **every visit to `/people/:id` raises `NoMethodError` (`title` for `nil`)**. This view edit must land in the same deploy as the `DataSchema` row deletion, not as a follow-up. Doing so also resolves step 2's temporary duplicate rendering.

**Files:** new migration, `app/models/student.rb`, `app/views/people/show.html.erb`.

### Step 4 — Confirm parents_info/additional_info round-trip; drop redundant native columns

- Verification first (no code change): with step 1's fix + validator in place, confirm editing sacraments/parents_info/additional_info via the Person profile's generic custom-fields form (`_data_fields.html.erb`) actually persists (it was silently broken before step 1). This is the "round-trip" the doc step 4 asks to confirm.
- `app/models/student.rb`:
  - Replace the native `father_christian_name`/`father_full_name`/`father_phone`/`mother_christian_name`/`mother_full_name`/`mother_phone` columns with `attr_accessor`-backed virtual attributes, populated via `after_find` from `person.data_field_by_key('parents_info')` (mapping `father_full_name` ↔ jsonb key `father_name`, etc. — matches existing `sync_person` naming).
  - Update `sync_person` to call `person.update_data_field('parents_info', {...})` (merges into existing `data['parents_info']`) instead of the wholesale `person.data = {...}` overwrite — this is the actual fix for the "known bug" above (Student save and Person-profile-page edit silently clobbering each other).
- `app/models/teacher.rb`: same pattern for `occupation`/`named_date` → `attr_accessor` + `after_find` + `update_data_field('additional_info', {...})`.
- Migration `RemoveParentAndOccupationColumnsFromStudentsAndTeachers`: drops the 6 columns from `students` and 2 from `teachers` — run only after confirming the round-trip in the step above (same caution pattern as Phase P).
- **No changes needed** to `students_controller.rb`/`teachers_controller.rb` permitted params, or to the ~8 call sites (`_info_table.html.erb` ×2, `attendances.html.erb`, `student_pdf.rb`, `students_personal_details_pdf.rb`, `students_pdf.rb`, `teachers_pdf.rb`, `students_excel_export.rb`, `teachers_excel_export.rb`) — `attr_accessor` + `after_find` preserves the exact same public read/write interface these callers already use. Their rewrite to query `Person` directly is step 8, deferred.

**Files:** new migration, `app/models/student.rb`, `app/models/teacher.rb`.

---

## Explicitly out of scope for steps 1-4

FK re-pointing (`enrollments.student_id`/`teaching_assignments.teacher_id` → `person_id`), `User`/auth teacher-status derivation, Pundit policy consolidation, the ~10 PDF classes + 2 Excel exporters + React surfaces rewrite, and dropping `students`/`teachers` tables — see `MIGRATION_PLAN.md` Phase S steps 5-9. Also not touched: the pre-existing `PersonConcern` bug (`validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?` — the `||` makes it inert for `ward?`/`district?`) and the `students_personal_details_pdf.rb:100` double-dot typo (`@student..date_declaration`) — both pre-existing, unrelated to this migration.

---

## Verification

- No test suite exists in this repo (`test/` has zero test files) — this migration establishes the first real test coverage. Add Minitest cases in `test/models/person_test.rb` and `test/models/student_test.rb`: required-field validator (blank required custom field fails save; non-required blank field passes), sacrament presence-pairing validation on `Person`, and `sync_person` round-trip (create a `Student`, confirm linked `Person`'s native sacrament columns and `data['parents_info']` reflect it after save).
- All migrations need to be run against a real DB (`rails db:migrate`) — same as the address-migration work.
- Manual check after step 1 fix: submit the Person profile's sacraments/parents_info/additional_info custom-fields form and confirm the value actually saves (previously silently didn't).
- Manual check after step 3 backfill: spot-check a handful of `Person` records where `Student`'s sacrament columns and `person.data['sacraments']` previously disagreed, to confirm the fallback picked a sane value.
