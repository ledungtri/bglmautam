# Multi-Tenancy Plan: bglmautam

## Context

The app currently serves a single Catholic parish (Mautam). The goal is to make it multi-tenant so other parishes can register with fully isolated data. A "tenant" = one parish/church (Organization). Tenant identity is resolved from the logged-in user — no subdomain needed. We use **row-level isolation** via the `acts_as_tenant` gem (organization_id FK on every table, auto-scoped queries). Production is a VPS; migration must be safe: nullable columns first → backfill → NOT NULL constraint.

---

## Phase 1: Foundation — Organization model + gem

**Goal:** Get the Organization model and gem in place with no functional changes to existing behavior.

### Steps
1. Add `gem 'acts_as_tenant'` to `Gemfile` + `bundle install`
2. Generate `Organization` model:
   ```
   rails g model Organization name:string slug:string
   ```
   - Add `null: false` and `uniqueness: true` index on slug in the migration
3. Create `app/models/organization.rb` with basic validations
4. Run `rails db:migrate`

### Files changed
- `Gemfile` + `Gemfile.lock`
- `db/migrate/TIMESTAMP_create_organizations.rb`
- `app/models/organization.rb`

### Verify before moving on
- `rails db:migrate` succeeds
- `Organization.create!(name: "test", slug: "test")` works in console
- Existing app still boots and works normally (no tenant set yet — app unchanged)

---

## Phase 2: Structural DB migration — add organization_id (nullable)

**Goal:** Add `organization_id` to every tenant-scoped table as a nullable column. App still works unchanged because columns are nullable and models don't call `acts_as_tenant` yet.

### Tables to update (12 total)
`users`, `people`, `students`, `teachers`, `classrooms`, `enrollments`, `teaching_assignments`, `attendances`, `grades`, `evaluations`, `data_schemas`, `resource_types`

Note: `phones`, `emails`, and `addresses` were polymorphic join tables that have since been replaced by direct columns on `people` (Phase O of the migration plan) — they are not included.

### Migration pattern (one migration, safe for prod)
```ruby
def change
  tables = %i[users people students teachers classrooms enrollments
              teaching_assignments attendances grades evaluations
              data_schemas resource_types]
  tables.each do |t|
    add_reference t, :organization, null: true, foreign_key: true, index: true
  end
end
```

### Files changed
- `db/migrate/TIMESTAMP_add_organization_id_to_all_tables.rb`

### Verify before moving on
- `rails db:migrate` succeeds on dev and production
- `rails db:schema:dump` shows `organization_id` on all 15 tables
- App still boots and works (nullable, no scoping yet)

---

## Phase 3: Prod data migration — seed Mautam + backfill

**Goal:** Create the Mautam Organization record and stamp every existing row with its ID. This is the irreversible prod step — do it after Phase 2 is deployed.

### Steps

1. **On production VPS** (rails console or runner):
   ```ruby
   mautam = Organization.create!(name: "Mẫu Tâm", slug: "mautam")

   tables = [User, Person, Student, Teacher, Classroom, Enrollment,
             TeachingAssignment, Attendance, Grade, Evaluation,
             DataSchema, ResourceType]

   tables.each do |model|
     # unscoped + with_deleted to catch soft-deleted (paranoia) records
     count = model.unscoped.with_deleted.update_all(organization_id: mautam.id)
     puts "#{model.name}: #{count} rows updated"
   end
   ```
2. Verify row counts match expectations (no zeros on tables that should have data)

### Files changed
- None (data-only step run in console)
- Optionally: encode as a data migration in `db/migrate/` if you want it tracked in schema history

### Verify before moving on
- Every table has 0 rows where `organization_id IS NULL`:
  ```sql
  SELECT COUNT(*) FROM users WHERE organization_id IS NULL;
  -- repeat for each table
  ```
- `Organization.first.users.count` matches `User.unscoped.count`

---

## Phase 4: Enforce NOT NULL + wire up models

**Goal:** Lock down the schema and activate `acts_as_tenant` in all models. After this phase the app is fully multi-tenant.

### Steps

#### 4a. NOT NULL constraint migration
```ruby
def change
  tables = %i[users people students teachers classrooms enrollments
              teaching_assignments attendances grades evaluations
              data_schemas resource_types]
  tables.each do |t|
    change_column_null t, :organization_id, false
  end
end
```

#### 4b. Add `acts_as_tenant` to every model
In each of the 15 model files, add at the top:
```ruby
acts_as_tenant :organization
```
This auto-adds `WHERE organization_id = ?` to every query when a tenant is set.

Note: `Organization` itself does NOT call `acts_as_tenant` (it's the root).

#### 4c. Set current tenant in controllers

**`app/controllers/application_controller.rb`** — add after `set_current_user`:
```ruby
before_action :set_tenant

def set_tenant
  set_current_tenant(@current_user.organization) if @current_user
end
```

**`app/controllers/api/v1/base_controller.rb`** — add after `authenticate_user!`:
```ruby
before_action :set_tenant

def set_tenant
  set_current_tenant(current_api_user.organization) if current_api_user
end
```

#### 4d. Update Pundit policies
`acts_as_tenant` raises `ActiveRecord::RecordNotFound` for cross-tenant access automatically. Review `Scope#resolve` in each policy — `scope.all` is sufficient (acts_as_tenant adds the WHERE clause). No explicit `organization_id` checks needed in policy methods.

#### 4e. Update seeds.rb
Wrap existing seed data in `ActsAsTenant.with_tenant(mautam) { ... }` so reseed works correctly:
```ruby
mautam = Organization.find_or_create_by!(slug: "mautam") { |o| o.name = "Mẫu Tâm" }
ActsAsTenant.with_tenant(mautam) do
  # ... existing classroom/student/teacher seed data
end
```

### Files changed
- `db/migrate/TIMESTAMP_change_organization_id_not_null.rb`
- `app/models/*.rb` (12 files — add `acts_as_tenant :organization`)
- `app/controllers/application_controller.rb`
- `app/controllers/api/v1/base_controller.rb`
- `app/policies/application_policy.rb` (review Scope)
- `db/seeds.rb`

### Verify before moving on
- Existing Mautam user logs in → sees all data (classrooms, students, teachers)
- No `organization_id IS NULL` errors
- Console: set tenant manually and confirm scoped queries work:
  ```ruby
  ActsAsTenant.with_tenant(Organization.first) { Classroom.count }
  ```

---

## Phase 5: New tenant provisioning + super_admin flag

**Goal:** Add `super_admin` boolean, update controllers for cross-tenant bypass, and build the rake task for onboarding new parishes.

### Role structure (final)
| Flag | Column | Purpose |
|------|--------|---------|
| `admin` | `users.admin` (existing) | Org-level admin — full access within their tenant |
| `super_admin` | `users.super_admin` (new) | System-level — can bypass tenant scope |
| Teacher | `users.teacher_id` presence (existing) | Implicit — scoped to assigned classrooms via `teaching_assignments` |

No gems needed. Two booleans, simple and direct.

---

### Step 5a: Add `super_admin` column

```ruby
# migration
add_column :users, :super_admin, :boolean, default: false, null: false
```

Add to `app/models/user.rb`:
```ruby
def super_admin? = super_admin
```

Pundit `app/policies/application_policy.rb` — add helper:
```ruby
def super_admin?
  user&.super_admin?
end
```

---

### Step 5b: Update ApplicationController for super_admin tenant bypass

**`app/controllers/application_controller.rb`:**
```ruby
def set_tenant
  if @current_user&.super_admin?
    # super_admin can pass ?org=slug to switch orgs; no param = no tenant (sees all)
    org = params[:org].present? ? Organization.find_by(slug: params[:org]) : nil
    set_current_tenant(org)
  else
    set_current_tenant(@current_user&.organization)
  end
end
```

Same pattern in `app/controllers/api/v1/base_controller.rb`.

---

### Step 5c: Rake task for new tenant provisioning

**`lib/tasks/tenants.rake`:**
```ruby
# rails tenants:create NAME="Mỹ Phước" SLUG="myphuoc" ADMIN_EMAIL="..." ADMIN_PASSWORD="..."
ActsAsTenant.without_tenant do
  org = Organization.create!(name: ENV["NAME"], slug: ENV["SLUG"])
  User.create!(
    email: ENV["ADMIN_EMAIL"],
    password: ENV["ADMIN_PASSWORD"],
    organization: org,
    admin: true
  )
end
```

### Files changed
- `db/migrate/TIMESTAMP_add_super_admin_to_users.rb`
- `app/models/user.rb` (add `super_admin?` helper)
- `app/policies/application_policy.rb` (add `super_admin?` helper)
- `app/controllers/application_controller.rb` (super_admin tenant bypass)
- `app/controllers/api/v1/base_controller.rb` (same)
- `lib/tasks/tenants.rake` (new)

### Verify before moving on
- `rails tenants:create ...` creates org + admin user
- Log in as new-parish admin → sees empty data (no Mautam records)
- Log in as Mautam admin → still sees all Mautam data
- Fetch `/classrooms/:mautam_id` while logged in as other parish → 404
- super_admin user with `?org=mautam` → sees Mautam data; without param → sees nothing (no tenant set)

---

## Rollback Notes

| Phase | Rollback |
|-------|---------|
| 1 | `rails db:rollback`, remove gem |
| 2 | `rails db:rollback` (drops nullable columns — no data lost) |
| 3 | **No easy rollback** — take a DB snapshot before running this step |
| 4 | `rails db:rollback` (drops NOT NULL), revert model + controller changes |
| 5 | `rails db:rollback` (drops super_admin column), delete rake task |

---

## Progress Checklist

- [x] Phase 1: Organization model + acts_as_tenant gem installed
- [ ] Phase 2: Nullable org_id columns on all 12 tables (dev + prod)
- [ ] Phase 3: Mautam org seeded + all prod rows backfilled + verified
- [ ] Phase 4: NOT NULL enforced, models wired, controllers set tenant, seeds updated
- [ ] Phase 5: super_admin flag + tenant rake task
