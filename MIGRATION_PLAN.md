# Migration Plan: bglmautam to Rails API + React Frontend

> **Last Updated:** 2026-07-28
> **Goal:** Complete the migration to a Rails API backend + mobile-friendly React frontend.

---

## Progress Tracker

| Phase | Description | Status |
|-------|-------------|--------|
| A | React Bug Fixes | [x] Complete |
| B | React Environment Setup | [x] Complete |
| C | Rails Database Indexes | [x] Complete |
| D | Rails CORS Fix | [x] Complete |
| E | Rails API v1 Base | [x] Complete |
| F | Rails Auth Endpoints | [x] Complete |
| G | React Auth Integration | [x] Complete |
| H | Rails: Classrooms, Enrollments, Attendances, Grades, Evaluations, Search, PDF API | [x] Complete |
| I | Rails: Students API endpoint | [ ] Pending |
| J | React: Student list/detail pages | [ ] Pending |
| K | Rails: Permission system refactor (Pundit + UserContext) | [x] Complete |
| L | Rails: Multi-tenancy (acts_as_tenant) | [x] Complete — all 5 phases done and deployed |
| M | React: Attendance editing, Search, PDF buttons, Mobile nav | [ ] Pending |
| N | Rails + React: Production config fixes | [x] Complete |
| O | Rails: Flatten Phone/Email/Address into Person columns | [x] Complete |
| P | Rails: Drop phones/emails/addresses tables (post-flatten cleanup) | [ ] Pending |
| Q | Rails: Seed Vietnamese address reference tables (vn_provinces, vn_districts, vn_wards) | [x] Complete — ran on prod |
| R | Rails: Vietnamese address format migration — cleanup, backfill, decommission old fields, rename subregion→ward | [ ] In Progress — Phase 1 (province_code/ward_code columns) done and deployed; phases 2-7 not started |
| S | Rails: Consolidate Student/Teacher into Person — sacraments as columns, parent-info/occupation as custom fields, decommission Student/Teacher | [ ] Steps 1-4 deployed to prod (final verification still not actually confirmed — see step 5 note); step 5 repoint + step 7 Pundit rewrite done locally, not yet deployed; column drop no longer blocked but not yet done; steps 6, 8, 9 not started |
| T | Rails: Add Sentry error tracking | [ ] Pending |
| U | Rails + React: Add creator (`person_id`) to Evaluation, show author on note | [ ] Pending |

---

## Prioritized Backlog (2026-07-27)

Ranked by risk × effort, not by phase letter. Superseded phase-by-phase status stays in the table above; this section is the actual work order.

1. **Tier 0 — Fix immediately.** ✅ Complete and deployed (Phase N items 1-4): `consider_all_requests_local` → `false`, `log_level` → `:info`, DB password rotated + moved to `ENV.fetch("DATABASE_PASSWORD")`, prod DB renamed `bglmautam_development` → `bglmautam_production`.
2. **Tier 1 — Finish multi-tenancy (Phase L).** ✅ Fully complete and deployed (2026-07-27), all 5 phases including `organization_id` on `versions`/PaperTrail. Confirmed working in prod, and cross-tenant isolation re-verified locally with a real second org (see Phase L section for detail). Nothing left here.
3. **Tier 2 — In-flight structural migrations (independent of each other).**
   - Phase S steps 1-4 (Student/Teacher → Person) — ✅ deployed to prod (2026-07-27); fixed a live data-integrity bug (`sync_person` silently clobbering Person-profile-page edits). Final health/data verification requested, still never actually run against prod — step 5's new `admin:audit_person_id_coverage` task doubles as that check (found real gaps in local dev data: 9 `Teacher` rows never `sync_person`'d), so run it against prod before enabling any new NOT NULL constraint.
   - Phase S step 5 (repoint `student_id`/`teacher_id` → `person_id`) — repoint done locally (audit task, new indexes, bidirectional `sync_person`, read/write paths switched), not yet deployed. Actual column drop was deferred pending step 7.
   - Phase S step 7 (Pundit teacher_of_classroom? rewrite to Person) — ✅ done locally, not yet deployed. This unblocks step 5's column drop (no longer a blocker, though the drop itself is still not done — a deliberate separate follow-up, not folded in silently). Steps 6, 8, 9 not started; step 8 in particular is large (~15+ files: PDFs, Excel exporters, model default_scope/sort_param, some controllers/views) — see Phase S detail for the full inventory found via a 2026-07-28 audit.
   - Phase R phases 2-7 (Vietnamese address format) — Phase Q shipped to prod; phase 1 (`province_code`/`ward_code` columns) is also confirmed migrated on prod (verified via `db:migrate:status` during Phase L work). Phases 2-7 (data cleanup, backfill, decommission old fields, rename) not yet started.
4. **Tier 3 — Low-risk housekeeping, do opportunistically.** Phase P (drop `phones`/`emails`/`addresses` tables once prod row counts are audited), Phase T (Sentry error tracking — valuable for ops visibility, not blocking, needs a DSN from you first), Phase U (Evaluation creator/author — small additive nullable column, no dependents).
5. **Tier 4 — Bottom of the list.** Phase I (Students API), Phase J (React student pages), Phase M (remaining React features / mobile nav). The Rails ERB UI already has full working equivalents for all of these (CRUD forms, real per-tab content, wired export/PDF buttons) — this tier is purely about the React app catching up, and per Tier 1's dependency note shouldn't ship new functionality to production ahead of multi-tenancy anyway. Exception worth considering case-by-case: fixing an already-broken button (e.g. Phase J's dead `onClick` handlers) doesn't expose new data, so isolated bug fixes here could reasonably jump the queue independently of Tier 1.

---

## Current State

### Rails Backend (bglmautam)
- Rails 7.2, Ruby 3.3.0
- Session-based auth (web) + JWT access/refresh token pair in HTTP-only cookies (API)
- Pundit authorization with `UserContext` (admin, teacher-of-classroom, self) — refactored 2026-05-22
- Full `/api/v1` namespace with JWT auth
- `acts_as_tenant` gem installed, `Organization` model created — multi-tenancy Phase 1 done

**Live API v1 endpoints:**
- `auth` — login, logout, refresh, me
- `classrooms` — full CRUD + enrollments, teaching_assignments, attendances, evaluations, overview, PDF/XLSX exports
- `enrollments`, `teaching_assignments`, `attendances`, `grades`, `evaluations` — full CRUD
- `people` — index, show, update
- `users` — full CRUD (admin only)
- `data_schemas` — full CRUD (admin only)
- `search`, `resource_types` — read only

**Missing API endpoint:**
- `students` — no dedicated endpoint; students are accessed through `people` and `enrollments`

### React Frontend (bglmautam-react)
- Create React App + JavaScript
- Material UI
- TanStack React Query
- React Router v6
- Axios with JWT cookie auth

**Existing React routes:**
- `/login` — auth
- `/` and `/classrooms` — Classroom list
- `/classrooms/:id` — Classroom details with tabs
- `/teachers` — Teacher list
- `/people/:id` — Person details
- `/admin` — Admin page

**Missing React features:**
- Student list/detail pages
- Attendance CRUD UI
- Search page
- PDF download buttons
- Mobile navigation improvements

---

## Decisions Made

- **UI Framework:** Material UI (keeping existing)
- **Authentication:** JWT in HTTP-only cookies
- **Build Tool:** Create React App (keeping existing)
- **Language:** JavaScript (keeping existing)

---

## Implementation Phases (Incremental, Low-Risk First)

---

### Phase A: React Bug Fixes (Lowest Impact)

**No backend changes. Fix existing React bugs.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Move QueryClient outside component | `src/App.js` | None - internal fix |
| 2 | Fix state update in render | `src/modules/classrooms/StudentsTab.js` | None - bug fix |
| 3 | Fix invalid key prop | `src/modules/classrooms/AttendancesTab.js` | None - bug fix |

**Code changes:**

**A.1 - Fix App.js:**
```javascript
// MOVE OUTSIDE component (module level)
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
    },
  },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      {/* ... */}
    </QueryClientProvider>
  );
}
```

**A.2 - Fix StudentsTab.js:**
```javascript
// REPLACE conditional state in render with useEffect
React.useEffect(() => {
  if (!result && enrollments.length > 0) {
    const defaultResult = getCount('Đang Học') === 0 ? 'Lên Lớp' : 'Đang Học';
    setResult(defaultResult);
  }
}, [enrollments]);
```

**A.3 - Fix AttendancesTab.js:**
```javascript
// CHANGE from:
<MenuItem value={opt} key={{opt}}>{opt}</MenuItem>
// TO:
<MenuItem value={opt} key={opt}>{opt}</MenuItem>
```

**Verification:**
- [ ] Run `npm start`
- [ ] Navigate to classrooms list
- [ ] Open a classroom detail
- [ ] Check StudentsTab loads without console errors
- [ ] Check AttendancesTab loads without key warnings

---

### Phase B: React Environment Setup (Low Impact)

**Add configuration without changing behavior.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Create .env files | `.env.development`, `.env.production` | None |
| 2 | Update API to use env var | `src/api/index.js` | None if URL same |
| 3 | Add axios error interceptor | `src/api/index.js` | Improved error UX |
| 4 | Add ErrorBoundary component | `src/components/ErrorBoundary.js` | None - new file |

**Code changes:**

**B.1 - Create .env.development:**
```
REACT_APP_API_URL=http://localhost:3000/api
```

**B.2 - Create .env.production:**
```
REACT_APP_API_URL=https://bglmautam.com/api
```

**B.3 - Update src/api/index.js:**
```javascript
const HOST = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

// Add after createAxiosInstance:
axiosInstance.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error.response?.status, error.message);
    if (error.response?.status === 401) {
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

**B.4 - Create src/components/ErrorBoundary.js:**
```javascript
import React from 'react';
import { Alert } from '@mui/material';

class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <Alert severity="error" sx={{ m: 2 }}>
          Something went wrong. Please refresh the page.
        </Alert>
      );
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
```

**Verification:**
- [ ] `npm start` still works
- [ ] API calls still work
- [ ] Check console for "API Error" logs on failed requests
- [ ] Console should be clean on normal usage

---

### Phase C: Rails Database Indexes (Low Impact)

**Add indexes - no code changes, improves performance.**

| # | Task | Impact |
|---|------|--------|
| 1 | Create migration for missing indexes | None - additive |
| 2 | Run migration | Brief DB lock |

**Code changes:**

**C.1 - Create migration:**
```bash
rails generate migration AddMissingIndexes
```

**C.2 - Edit migration file:**
```ruby
class AddMissingIndexes < ActiveRecord::Migration[7.2]
  def change
    # Skip if index already exists
    unless index_exists?(:enrollments, :student_id)
      add_index :enrollments, :student_id
    end

    unless index_exists?(:enrollments, :classroom_id)
      add_index :enrollments, :classroom_id
    end

    unless index_exists?(:enrollments, [:student_id, :classroom_id])
      add_index :enrollments, [:student_id, :classroom_id], unique: true
    end

    unless index_exists?(:teaching_assignments, :teacher_id)
      add_index :teaching_assignments, :teacher_id
    end

    unless index_exists?(:teaching_assignments, [:teacher_id, :classroom_id])
      add_index :teaching_assignments, [:teacher_id, :classroom_id], unique: true
    end

    unless index_exists?(:attendances, [:attendable_type, :attendable_id, :date])
      add_index :attendances, [:attendable_type, :attendable_id, :date]
    end
  end
end
```

**Verification:**
- [ ] `rails db:migrate` succeeds
- [ ] `rails db:migrate:status` shows new migration as "up"
- [ ] Existing Rails app still works
- [ ] React app still fetches data

---

### Phase D: Rails CORS Fix (Medium Impact)

**Security fix - may affect API access.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Update CORS config | `config/initializers/cors.rb` | React must be in allowed origins |

**Code changes:**

**D.1 - Update config/initializers/cors.rb:**
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3000,http://localhost:3001').split(',')

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 600
  end
end
```

**D.2 - Add to .env (or environment):**
```
CORS_ORIGINS=http://localhost:3001,https://your-react-domain.com
```

**Verification:**
- [ ] Restart Rails server
- [ ] React app can still call API
- [ ] Open browser console, test: `fetch('http://localhost:3000/api/classrooms').then(r => r.json())`
- [ ] Test from different origin (should fail) - security check

---

### Phase E: Rails API v1 Base (Medium Impact)

**Create new API namespace - doesn't break existing.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Add jwt gem | `Gemfile` | None |
| 2 | Create JwtService | `app/services/jwt_service.rb` | None - new file |
| 3 | Create v1 base controller | `app/controllers/api/v1/base_controller.rb` | None - new file |
| 4 | Add v1 routes (empty) | `config/routes.rb` | None - additive |

**Code changes:**

**E.1 - Add to Gemfile:**
```ruby
gem 'jwt'
gem 'kaminari'  # For pagination
```

**E.2 - Run bundle install:**
```bash
bundle install
```

**E.3 - Create app/services/jwt_service.rb:**
```ruby
class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV['JWT_SECRET']
  ALGORITHM = 'HS256'

  class << self
    def encode(payload, exp: 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.error("JWT decode error: #{e.message}")
      nil
    end
  end
end
```

**E.4 - Create app/controllers/api/v1/base_controller.rb:**
```ruby
module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_request
      before_action :set_current_year

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from Pundit::NotAuthorizedError, with: :forbidden

      attr_reader :current_user

      private

      def authenticate_request
        token = cookies.signed[:jwt] || extract_token_from_header
        return render_unauthorized unless token

        payload = JwtService.decode(token)
        return render_unauthorized unless payload

        @current_user = User.find_by(id: payload[:user_id])
        render_unauthorized unless @current_user
      end

      def extract_token_from_header
        header = request.headers['Authorization']
        header&.split(' ')&.last
      end

      def set_current_year
        @current_year = params[:year]&.to_i || 2025
      end

      def render_unauthorized
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors }, status: :unprocessable_entity
      end

      def forbidden
        render json: { error: 'Forbidden' }, status: :forbidden
      end
    end
  end
end
```

**E.5 - Update config/routes.rb (add inside namespace :api):**
```ruby
namespace :api do
  # Existing routes...

  namespace :v1 do
    # Will add routes in next phases
  end
end
```

**Verification:**
- [ ] `bundle install` succeeds
- [ ] Rails server starts without errors
- [ ] Existing `/api/classrooms` still works
- [ ] `curl http://localhost:3000/api/v1` returns routing error (expected - no routes yet)

---

### Phase F: Rails Auth Endpoints (Medium Impact)

**Add login/logout - doesn't require React changes yet.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Create auth controller | `app/controllers/api/v1/auth_controller.rb` | None - new |
| 2 | Add auth routes | `config/routes.rb` | None - additive |

**Code changes:**

**F.1 - Create app/controllers/api/v1/auth_controller.rb:**
```ruby
module Api
  module V1
    class AuthController < ActionController::API
      def login
        user = User.find_by(username: params[:username])

        if user&.authenticate(params[:password])
          token = JwtService.encode(user_id: user.id)

          cookies.signed[:jwt] = {
            value: token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :lax,
            expires: 24.hours.from_now
          }

          render json: {
            user: {
              id: user.id,
              username: user.username,
              admin: user.admin,
              teacher_id: user.person&.teacher&.id
            }
          }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      def logout
        cookies.delete(:jwt)
        render json: { message: 'Logged out' }
      end

      def me
        token = cookies.signed[:jwt] || extract_token_from_header
        return render json: { error: 'Not authenticated' }, status: :unauthorized unless token

        payload = JwtService.decode(token)
        return render json: { error: 'Invalid token' }, status: :unauthorized unless payload

        user = User.find_by(id: payload[:user_id])
        return render json: { error: 'User not found' }, status: :unauthorized unless user

        render json: {
          user: {
            id: user.id,
            username: user.username,
            admin: user.admin,
            teacher_id: user.person&.teacher&.id
          }
        }
      end

      private

      def extract_token_from_header
        header = request.headers['Authorization']
        header&.split(' ')&.last
      end
    end
  end
end
```

**F.2 - Update config/routes.rb (inside namespace :v1):**
```ruby
namespace :v1 do
  post '/auth/login', to: 'auth#login'
  post '/auth/logout', to: 'auth#logout'
  get '/auth/me', to: 'auth#me'
end
```

**Verification:**
- [ ] Test login:
  ```bash
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"your_user","password":"your_pass"}' \
    -c cookies.txt -v
  ```
- [ ] Check response includes user object
- [ ] Check Set-Cookie header has jwt (httponly)
- [ ] Test /me with cookie:
  ```bash
  curl http://localhost:3000/api/v1/auth/me -b cookies.txt
  ```
- [ ] Test logout:
  ```bash
  curl -X POST http://localhost:3000/api/v1/auth/logout -b cookies.txt
  ```

---

### Phase G: React Auth Integration (Higher Impact)

**Connect React to new auth endpoints.**

| # | Task | File | Impact |
|---|------|------|--------|
| 1 | Create AuthContext | `src/contexts/AuthContext.js` | None - new |
| 2 | Create useAuth hook | `src/hooks/useAuth.js` | None - new |
| 3 | Create LoginPage | `src/modules/auth/LoginPage.js` | None - new |
| 4 | Create ProtectedRoute | `src/components/ProtectedRoute.js` | None - new |
| 5 | Update App.js | `src/App.js` | Routes now protected |
| 6 | Update API client | `src/api/index.js` | Add withCredentials |

*Detailed code will be provided when we reach this phase.*

**Verification:**
- [ ] Start React app
- [ ] Should redirect to /login
- [ ] Login with valid credentials → redirects to home
- [ ] Refresh page → stays logged in (cookie persists)
- [ ] Logout → redirects to login
- [ ] Direct URL access while logged out → redirects to login

---

### Phase H: Rails API — ✅ Complete (except Students)

All major API endpoints are live. The only missing dedicated endpoint is `students_controller`. Students are currently accessible through `people` (person record) and `enrollments` (classroom participation). A dedicated `/api/v1/students` endpoint may be added if the React frontend needs it (Phase I).

---

### Phase I: Rails Students API — Pending

**Goal:** Add a dedicated `GET /api/v1/students` endpoint if needed by the React frontend.

May not be necessary — students are fully reachable via `/people` and `/enrollments`. Decide when building Phase J.

---

### Phase J: React Student Pages — Partially Done (audited 2026-07-26)

**Goal:** Student list and detail pages in React.

Re-audited against the actual Rails ERB UI (`/students`, `/teachers`, `/people/show`) vs. the current React app. `StudentList`/`TeacherList` and a basic `PersonDetails` page already exist, but several pieces are stubbed, unwired, or missing outright:

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Student list page | [x] Done | Read-only card list, `/students` |
| 2 | Teacher list page | [x] Done | Read-only card list, `/teachers` |
| 3 | Link from classroom detail | [x] Done | Classroom tabs link into person pages |
| 4 | **PersonDetails tab content** | [x] Done (2026-07-27) | Each tab now has real content: `BasicInfoTab` (name/gender/birth), `ContactInfoTab` (phone/email/address + `parents_info`), `SpiritualJourneyTab` (sacraments + enrollment/classroom history via `/api/v1/enrollments?filters[person_id_eq]`), `ApostolicJourneyTab` (`additional_info` + teaching-assignment/classroom history via `/api/v1/teaching_assignments?filters[person_id_eq]`). Required also adding the sacrament columns to `PersonSerializer`, which Phase S step 2 had added to the `people` table but never exposed over the API. Read-only — edit/delete is still item 5. |
| 5 | **PersonDetails edit/delete** | [x] Done (2026-07-27) | "Cập Nhật" opens `PersonEditDialog` (`PUT /api/v1/people/:id`, already-supported fields). "Xóa" opens `PersonDeleteDialog` (`DELETE /api/v1/people/:id`) — this endpoint didn't exist yet (route + controller action added, cascades to `enrollments`/`teaching_assignments`/`student`/`teacher`/`user`, soft-delete via `paranoia`, same pattern as `ClassroomsController#destroy`). Found along the way: the legacy Rails `PeopleController` had the same gap — route declared `:destroy` but no matching action, so its "Xóa" button would 500 if clicked; fixed there too. |
| 6 | Student/Teacher create+edit forms | [ ] Missing | No create/edit form exists in React for a Person, Enrollment, or TeachingAssignment record — Rails has full CRUD via `students_controller`/`teachers_controller`. Only result/position selects and attendance status are mutable inline today. |
| 7 | Grade entry UI | [ ] Missing | Rails `evaluations` view has real per-student grade entry (4 term grades). React's evaluations tab only has comment + result select, no grade fields. |
| 8 | DataSchema-driven custom fields | [ ] Missing | `/data-schemas` admin CRUD exists and works, but nothing renders schema-driven fields dynamically in any React form — current "custom" fields are hardcoded `additionalInfos` props, not schema-driven like Rails' `_data_fields` partial. Schemas defined in the admin UI currently have zero effect. |
| 9 | Export buttons on Student/Teacher list | [ ] Broken | Menu items ("In Danh Sách", "Xuất Excel") exist visually but have no `onClick` — unlike `ClassroomDetails`, where the equivalent buttons are correctly wired via `window.open`. |

**Dependency:** Multi-tenancy Phase 4 must be complete before shipping to prod (API will be tenant-scoped).

---

### Phase K: Permission System Refactor — ✅ Complete (2026-05-22)

- `UserContext` struct threads request year into Pundit policies
- `ApplicationPolicy` initializer reads from `UserContext` instead of hardcoded 2025
- `pundit_user` override in both `ApplicationController` and `Api::V1::BaseController`
- Auth methods removed from `User` model — policies are now the single source of truth
- `teacher_of_classroom?` bug fixed (was checking only `.first` classroom)
- Contact policies (Address, Email, Phone) now restrict to owner or admin
- Views updated to use `policy(record).action?` instead of `current_user.admin_or_*`

---

### Phase L: Multi-Tenancy — ✅ Complete and Deployed, All 5 Phases (2026-07-27)

See `MULTITENANCY_PLAN.md` for full detail. Current state:

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Organization model + acts_as_tenant gem | ✅ Done |
| 2 | Add nullable organization_id to all 12 tables | ✅ Done |
| 3 | Seed Mautam org + backfill prod data | ✅ Done — ran and verified clean on prod |
| 4 | Enforce NOT NULL + wire acts_as_tenant into models/controllers | ✅ Done — deployed and confirmed working (see incidents below) |
| 5 | Add `organization_id` to `versions` (PaperTrail) | ✅ Done — deployed and confirmed on prod (migration status `up`, column present, PM2 healthy) |

The app is now fully tenant-scoped. Confirmed in prod via `ActsAsTenant.with_tenant(mautam) { ... }`: 343 classrooms, 1929 students, 332 teachers all correctly scoped. Cross-tenant isolation was further re-verified locally (2026-07-27) with a real second organization: tenant-scoped counts stay isolated, direct ID lookups across tenants correctly raise `RecordNotFound`, and a real HTTP request from an "other org" user to a Mautam-owned record returns 404 end-to-end.

**All React feature work intended for production can now proceed** — the API scopes every response to the logged-in user's organization.

**Two production incidents during this deploy, both fixed same-day:**
1. **`DATABASE_PASSWORD` KeyError crash-loop.** The value was correctly set in `ecosystem.config.js`'s `env` block (from the Phase N rollout), but `pm2 restart --update-env` didn't pick it up for an already-running process — same gotcha documented in Phase N, recurring because this was a fresh restart of a process PM2 had cached without that env var. Fixed with a full `pm2 delete bglmautam && pm2 start ecosystem.config.js`. Also affects any bare `rake`/`rails runner` command run over SSH — remember to `export DATABASE_PASSWORD=...` in the shell first, separate from PM2's copy.
2. **`NoMethodError: undefined method 'set_current_tenant'`** on every request after the first successful boot. `acts_as_tenant` only defines that instance method when a controller calls its `set_current_tenant_through_filter` class macro — neither `ApplicationController` nor `Api::V1::BaseController` did. This wasn't caught by either research pass before implementation since it required actually booting the app to surface (a static grep of the gem's public API wouldn't have caught the DSL requirement). Fixed by adding `set_current_tenant_through_filter` to both controllers.

**Note:** two separate bugs found in `MULTITENANCY_PLAN.md` while implementing step 4 and fixed in that doc — its Phase 4c snippet referenced a `current_api_user` method that doesn't exist (actual method is `current_user`), and its Phase 4d ("review Pundit Scope#resolve") doesn't apply since this app has no Pundit `Scope` classes at all (confirmed via grep across all 13 policy files) — `acts_as_tenant`'s automatic query scoping is the only mechanism needed, no policy changes required.

**L-5 detail:** `versions` (PaperTrail's audit table, `has_paper_trail` is included repo-wide in `ApplicationRecord`) was excluded from the original 12-table `organization_id` rollout since it only has `item_type`/`item_id`. Without it, any cross-tenant "recent changes" admin view would leak other orgs' audit history. Done (2026-07-27):
- Migration `AddOrganizationIdToVersions` — nullable `organization_id` bigint + index + FK on `versions`. Nullable and no backfill needed — historical audit rows legitimately have no org context, new ones get it automatically going forward. No `acts_as_tenant`/query-scoping added to `PaperTrail::Version` itself (no dedicated admin view reads it yet), so this carries none of Phase L step 4's deploy-ordering risk.
- `ApplicationRecord`: `has_paper_trail meta: { organization_id: ->(record) { record.try(:organization_id) } }` so it's captured automatically on every version write — `try` handles `Organization` itself (the only model without the column; `Address`/`Email`/`Phone` model classes were already deleted in Phase O, only their DB tables remain pending Phase P).

---

### Phase M: Remaining React Features — Partially Done (audited 2026-07-26)

| # | Feature | Status | Depends on |
|---|---------|--------|------------|
| 1 | Attendance CRUD UI | [x] Done | Classroom + standalone teacher-attendance pages support create/update via inline status select (no delete UI, matches Rails) |
| 2 | Search page | [x] Done | `/search`, debounced, groups Students/Teachers |
| 3 | PDF download buttons (Classroom) | [x] Done | Wired via `window.open` + `CustomExportDialog` |
| 3b | PDF/Excel buttons (Student/Teacher lists) | [ ] Broken | See Phase J #9 — buttons present, not wired |
| 4 | Mobile navigation improvements | [ ] Pending | Independent — no real mobile/desktop nav split today; single centered 900px shell with a MUI drawer regardless of viewport |
| 5 | Classroom "Tổng Quan" (Overview) tab | [x] Done (2026-07-27) | Admin-only tab on `ClassroomDetails`, gated via `useAuth().isAdmin`; reuses the existing `ClassroomCard` component against a new single-classroom endpoint (`GET /api/v1/classrooms/:id/overview_card` → `ClassroomOverviewQuery#call_for_classroom`) instead of refetching the full list-page overview query |

---

### Phase N: Production Config Fixes — ✅ Complete (2026-07-27)

| # | Issue | File | Fix |
|---|-------|------|-----|
| 1 | `consider_all_requests_local = true` | `config/environments/production.rb` | ✅ Changed to `false`, deployed |
| 2 | `log_level = :debug` | `config/environments/production.rb` | ✅ Changed to `:info`, deployed |
| 3 | DB password in plaintext | `config/database.yml` | ✅ Production reads `ENV.fetch("DATABASE_PASSWORD")`; actual Postgres password rotated, deployed |
| 4 | Production DB name is `bglmautam_development` | `config/database.yml` | ✅ Renamed to `bglmautam_production` on the server, config updated to match, deployed |

Error tracking/alerting (Sentry) split out to Phase T.

**Notes for future manual ops work:** `DATABASE_PASSWORD` must be exported in any bare SSH shell before running `rails console`/`rake` commands by hand — `ecosystem.config.js`'s `env` block only reaches the process PM2 spawns, not an ad-hoc shell command. It's set in `/root/.bashrc` on the server for this. Also added `/.env` and `/.env.*` to `.gitignore` so a future `.env`-based setup (e.g. `dotenv-rails`) doesn't accidentally get committed.

### Phase O: Flatten Phone/Email/Address into Person — ✅ Complete (2026-05-22)

Removed the `Phone`, `Email`, and `Address` polymorphic join models and moved all data into direct columns on `people`.

- Migration `20260521192452_flatten_contact_fields_on_people.rb` — adds 8 columns (`phone`, `email`, `street_number`, `street_name`, `ward`, `district`, `city`, `area`) and backfills from old tables in the same transaction
- `Person` model — `FIELD_SETS` updated with phone/email/address fields; `full_address` helper added; polymorphic `has_many` associations removed
- `PersonSerializer` — now returns flat attributes instead of `has_many :phones/:addresses` + `primary_phone`
- `Student#sync_person` and `Teacher#sync_person` — updated to write directly to `person.phone`, `person.email`, and address columns instead of the deleted polymorphic models; also fixed a pre-existing bug where `declaration_date`/`declaration_place` were copying `confirmation` values
- `people/show.html.erb` — removed separate Phone/Email/Address form renders; fields now appear in the main person `FIELD_SETS` form
- Deleted: `phones_controller`, `emails_controller`, `addresses_controller`, `phone_policy`, `email_policy`, `address_policy`, `phone.rb`, `email.rb`, `address.rb`
- Routes: removed `:phones`, `:emails`, `:addresses` from `secondary_resources`
- `ApplicationPolicy`: removed `admin_or_owner_of_person?` (no longer needed)

Old tables (`phones`, `emails`, `addresses`) left in DB — see Phase P.

---

### Phase Q: Seed Vietnamese Address Reference Tables — Complete

Seed `vn_provinces`, `vn_districts`, and `vn_wards` from the [provinces.open-api.vn v1 API](https://provinces.open-api.vn/api/v1/redoc). Full detail in [`docs/VIETNAMESE_ADDRESS_PLAN.md`](docs/VIETNAMESE_ADDRESS_PLAN.md) Phase 1.

**Key deliverables:**
- Migration: `CreateVnAddressReferenceTables` — three tables with integer PKs ✅ written and run on prod
- Models: `VnProvince`, `VnDistrict`, `VnWard` (`app/models/vn_*.rb`) ✅ written
- Service: `VietnameseAddressSeeder` (`app/services/vietnamese_address_seeder.rb`) ✅ written, call added to `db/seeds.rb`
- Run: `rails runner 'VietnameseAddressSeeder.seed!'` — ✅ ran on prod. Initial run hit `JSON::ParserError` on `seed_districts`/`seed_wards`: `provinces.open-api.vn` 307-redirects `/d` → `/d/` and `/w` → `/w/`, but `Net::HTTP.get_response` doesn't follow redirects, so `fetch` got an empty body. Fixed by using the canonical trailing-slash paths (`/d/`, `/w/`) directly in the seeder.

**Verification:** `VnProvince.count` = 63, `VnWard.count` > 10_000

---

### Phase R: Vietnamese Address Format Migration — In Progress

Migrate `people` from the old address format (`street_number`, `street_name`, `ward`, `district`, `city`) to the new format (`street_address`, `province`/`province_code`, `subregion`/`ward_code`→`ward`). `organizations` has no legacy data, so it already dropped the old columns directly (see `RemoveV1AddressFieldsFromOrganizations` migration) and only needs the `province_code`/`ward_code` + rename steps below. Depends on Phase Q. Full detail in [`docs/VIETNAMESE_ADDRESS_PLAN.md`](docs/VIETNAMESE_ADDRESS_PLAN.md).

**Phases (in safe deployment order):**
1. Add `province_code` + `ward_code` integer columns to both tables ✅ done — migration (`AddAddressCodeColumnsToPeopleAndOrganizations`) confirmed migrated on prod (`up` in `db:migrate:status`, verified during Phase L work)
2. Data cleanup — audit ward/city values (all assumed HCMC, province code 79)
3. Backfill new fields from old; match wards against `vn_wards` table
4. Update `Person` FIELD_SETS, `PersonSerializer`, controller permitted params
5. Add `GET /api/v1/addresses/provinces` + `.../wards` endpoints for frontend dropdowns
6. Drop old columns: `street_number`, `street_name`, `ward`, `district`, `city` (after prod audit)
7. Rename `subregion` → `ward`

**Prerequisite:** Phase Q complete (reference tables seeded).

---

### Phase S: Consolidate Student/Teacher into Person — Steps 1-4 Deployed to Prod (2026-07-27), Final Verification In Progress

**Decision:** `Person` becomes the single canonical model. `Student` and `Teacher` are decommissioned entirely, not merely thinned — `sync_person` is transitional bridge scaffolding for this migration, not a permanent dual-write. This extends the same expand-and-contract pattern Phase O used for contact fields.

Steps 1-4 (the backend data-layer groundwork) are implemented, verified against a local copy of production-scale data, and detailed in full — including two bugs found during planning and one found during verification — in [`docs/STUDENT_TEACHER_TO_PERSON_PLAN.md`](docs/STUDENT_TEACHER_TO_PERSON_PLAN.md). Summary of field disposition and steps below; steps 5-9 remain at the summary level only.

**Verification performed locally (2026-07-27):** full migration chain (sacrament columns → backfill → drop redundant columns) run cleanly against 1978 real students/2290 real people; backfilled sacrament data spot-checked and matches source `Student` records exactly; `db/schema.rb` confirmed to match a fresh `db:schema:dump` byte-for-byte; full Minitest suite passing (9/9); real HTTP requests confirmed `/people/:id` renders correctly (no crash from the removed `data_fields` render call), the step 1 bug fix actually persists custom-field submissions now, and both `/students/:id` and `/teachers/:id` still render correctly via the `attr_accessor`/`after_find` bridge. Also found and fixed an unrelated bug during this pass: `database.yml`'s `ENV.fetch("DATABASE_PASSWORD")` (from Phase N) was breaking `development`/`test`, not just guarding production, since Rails ERB-renders the whole file regardless of active environment — changed to `ENV["DATABASE_PASSWORD"]` (no exception if unset); production is unaffected since the var is already set there.

**Deployed to prod (2026-07-27):** unlike Phase L, the backfill here is a real ActiveRecord migration (`BackfillSacramentColumnsOnPeopleFromStudents`), not a manual pre-step, so a single `rake db:migrate` applies the full sequence (sacrament columns → backfill → drop redundant columns) correctly in order — no two-deploy split needed. Migrations ran, app restarted, and the `sacraments` `DataSchema` row was destroyed via console (confirmed: "Destroyed sacraments DataSchema row"). Final health/data verification (`pm2 status`, migration status, sacrament/parents_info counts, HTTPS check) requested, results pending.

**Field disposition:**
- **Sacraments** (`date_baptism`/`place_baptism`, communion, confirmation, declaration) → **native columns on `people`**, carrying the same presence-pairing validations Student has today (`validates_presence_of :date_baptism, if: :place_baptism?`, etc.). Not custom fields — this data is used in PDFs/exports and completion-tracking logic, and is core/universal rather than tenant-variable.
- **Parent info** (father/mother christian_name, full_name, phone) → **custom fields** via the existing `DataSchema` entity `Person` / key `parents_info` (already seeded correctly in `lib/tasks/create_data_schemas.rake`). Confirmed via grep that these fields are only ever read for display (`students_excel_export.rb`, `_info_table.html.erb`, `attendances.html.erb`) — never filtered, sorted, or joined — so jsonb has no query-performance downside here. The `format: { with: /\A\d+\z/ }` validation currently on `father_phone`/`mother_phone` has no equivalent elsewhere on `Person` (`phone`, `Organization#phone` aren't format-validated either) — dropped rather than generalizing the required-field validator to also support `format`.
- **Teacher occupation / patron day (`named_date`)** → **custom fields** via existing `DataSchema` entity `Person` / key `additional_info` (already seeded).
- **Existing `DataSchema` key `sacraments` (entity `Person`)** must be removed once sacraments become native columns — it's currently a conflicting write path (see bug below).

**Known bug this migration fixes:** `Student#sync_person` overwrites `person.data['sacraments']`/`person.data['parents_info']` wholesale on every Student save, while `DataFieldsController#update` lets the Person profile page edit `person.data` directly with no write-back to `Student`'s real columns. Whichever was saved more recently silently wins. Moving sacraments to native `Person` columns and parent-info fully to `Person`-scoped custom fields (merged via `update_data_field`, not wholesale overwrite) collapses this to one write path.

**Second bug found during planning (blocks step 1):** `DataFieldsController#data_field_params` reads `f['field']`, but every seeded schema and the rendering partials use `field_name` — the Person-profile custom-fields form (sacraments/parents_info/additional_info) currently permits nothing and silently no-ops on submit. Must be fixed as part of step 1.

**Steps (in order):**
1. ✅ Done — Add required-field validation for `DataFieldable` models (validate presence for any `DataSchema` field flagged `required`, scoped to that record's `data` keys) — today `required` is a permitted param with no enforcement anywhere. Also fixes the `field`/`field_name` bug above.
2. ✅ Done — Add sacrament columns + validations to `people`; update `Person::FIELD_SETS`; add `father_name`/`mother_name` helpers. (`validates_presence_of :gender, :date_birth`, the gender inclusion check, and `in_classroom` are already present on `Person` independently — nothing to port there; `Student.result(classroom)` has zero callers, not ported.)
3. ✅ Done and deployed — Point `Student#sync_person` at the new `Person` sacrament columns (bridge), with a backfill migration preferring `Student`'s column over stale `person.data['sacraments']`; removed the corresponding `render 'components/form/data_fields', schema_key: 'sacraments'` block from `people/show.html.erb` in the same change. The `DataSchema` `sacraments`/entity-Person row was destroyed via console command on prod (2026-07-27).
4. ✅ Done — `parents_info`/`additional_info` custom fields round-trip correctly against `Person` (verified via real HTTP POST to `/people/:id/data_fields/parents_info`); dropped the now-redundant native `father_*`/`mother_*` columns from `Student` and `occupation`/`named_date` from `Teacher`, replaced with `attr_accessor` + `after_find` compatibility shims so the ~8 existing call sites (views/PDFs/Excel exports) keep working unchanged until step 8 — confirmed via rendering `/students/:id` and `/teachers/:id` directly.
5. ✅ Repoint done locally, not yet deployed — `person_id` already existed on both tables and "add the new column" was already done pre-Phase-S; this step turned out to be audit + read/write-path repoint + (deferred) drop:
   - Added `admin:audit_person_id_coverage` rake task (`lib/tasks/migrate_to_people.rake`) checking null/drift/orphan counts for both tables, including soft-deleted rows via `with_deleted` (paranoia's default scope would otherwise hide a bad `person_id` on a soft-deleted row). **Run this against prod before touching NOT NULL/unique constraints there** — local dev data is NOT clean: 9 active `teaching_assignments` have `person_id: nil` because the underlying `Teacher` itself was never `sync_person`'d (`teacher.person_id` is `nil`), plus 208/55 more null hits among soft-deleted enrollments/teaching_assignments. This is exactly the still-open "final verification" from steps 1-4 above, surfaced for real this time — resolve by hand (re-run `admin:teacher_person_id`/`admin:student_person_id` after backfilling the affected `Teacher`/`Student` rows' own `person_id`) before adding any NOT NULL constraint.
   - Added migration `20260728080600_add_unique_index_on_person_classroom...` — new partial unique indexes `index_enrollments_unique_person_classroom` / `index_teaching_assignments_unique_person_classroom` on `(person_id, classroom_id) WHERE deleted_at IS NULL`, alongside (not replacing) the existing ones on `student_id`/`teacher_id`. Ran clean locally (no constraint violation). The `NOT NULL` constraint itself is intentionally a separate, not-yet-written migration, gated on the prod audit above being clean.
   - `Enrollment#sync_person` / `TeachingAssignment#sync_person` made bidirectional (fills whichever of `person_id`/legacy-id is missing from the other, using `with_deleted.find` so a soft-deleted `Student`/`Teacher` no longer raises `RecordNotFound` on save) — both columns now stay populated regardless of which one a caller sets, verified via `rails runner` for all four directions (person→legacy and legacy→person, both models) plus the "person has no matching Teacher" validation-error path (clean `ActiveRecord` error, no crash).
   - `Enrollment` no longer requires `student_id` present (only `person_id`); `TeachingAssignment` now also requires `person_id` present (closed a real pre-existing gap — it previously validated `teacher_id`/`classroom_id` only).
   - Write paths switched to permit/set `person_id` instead of the legacy column: `app/controllers/enrollments_controller.rb`, `app/controllers/api/v1/enrollments_controller.rb`, `app/views/enrollments/_new.html.erb`, and the teaching-assignment equivalents. `Student#result` now queries `enrollments.where(person_id: ...)`. `lib/tasks/end_of_year_tasks.rake` and `lib/tasks/import_teacher_attendances.rake` switched their `student_id`/`teacher_id` comparisons to `person_id` (left `Attendance#substitute_teacher_id` in the latter file untouched — unrelated column, easy to confuse by name).
   - **Actual `remove_column` still deferred, not done** — but no longer blocked as of step 7 below (see there). Left for a deliberate follow-up rather than folded silently into this pass.
6. Update `User`/`AuthController` to derive teacher status from `person.teaching_assignments.any?` instead of `person.teacher` (currently `user.person&.teacher&.id`). **Not done.** (Two read sites found beyond `AuthController` proper — this app has no separate `AuthController` file; the equivalent is `SessionsController#create`'s post-login redirect (`sessions_controller.rb:17-18`, `if user&.teacher` / `TeachingAssignment...where(teacher: user.teacher)`) and `app/views/layouts/_header.html.erb:17`'s `teacher_url(@current_user.teacher)` nav link — both still `.teacher`-based, unchanged.)
7. ✅ Done — Pundit `teacher_of_classroom?`/`teacher_of_enrollment?`/`teacher_of_teaching_assignment?` (previously three copy-pasted `user.teacher&.teaching_assignments&.for_year(@current_year)&.map(&:classroom)&.include?(...)` expressions in `app/policies/application_policy.rb`) deduplicated into one memoized `assigned_classrooms` helper, rewritten to `user&.person&.teaching_assignments` instead of `user.teacher`. `admin_or_teacher_of_student?` also switched its internal enrollment lookup from `student.enrollments` to `student.person.enrollments`. Verified via `rails runner` against real data: `assigned_classrooms` returns identical classroom sets whether derived from `Teacher` (old) or `Person` (new); positive/negative authorization checks all matched expected results for `admin_or_teacher_of_classroom?`/`_enrollment?`/`_teaching_assignment?`/`_student?`, including a non-teacher `Person` correctly getting `false`/`[]` with no crash. Full Minitest suite (9/9) still passing. **This was the reason step 5's column drop was deferred — it's no longer blocked**, though the drop itself hasn't been done (see step 5).
   Also added to `Person` (`app/models/person.rb`), needed as supporting infrastructure: `father_christian_name`/`father_full_name`/`father_phone`/`mother_christian_name`/`mother_full_name`/`mother_phone` (reading the `parents_info` data field, mirroring `Student#sync_person`'s write side), `named_date`/`occupation` (reading `additional_info`, mirroring `Teacher#sync_person`), and `Person#result(classroom)` (mirrors `Student#result`). Cross-checked all of these against real `Student`/`Teacher` records via `rails runner` — values matched exactly. Deliberately did **not** add `Person#classrooms` — `Student`/`Teacher` each only have one path to it (`through: :enrollments` / `through: :teaching_assignments` respectively), but `Person` has both, so a single `has_many :classrooms` would silently collide/overwrite; left commented out with a note, since grep confirmed zero live callers of `student.classrooms`/`teacher.classrooms` today.
8. Rewrite Rails and React surfaces to query `Person` scoped by association presence (`person.enrollments.any?` / `person.teaching_assignments.any?`) instead of a dedicated `Student`/`Teacher` model — tracked as two sub-steps given the surface area found in the UI audit:
   - **8a. Rails:** `StudentsController`/`TeachersController` → Person-scoped controllers/routes; `StudentPolicy`/`TeacherPolicy` → a Person-scoped policy; the ~10 PDF classes (`StudentsPdf`, `TeachersPdf`, `CompactStudentsPdf`, etc.) and 2 Excel exporters updated to query `Person`. **Not done.** A full exhaustive grep (2026-07-28) found this is large: `Enrollment`/`TeachingAssignment`'s own `default_scope`/`FIELD_SETS`/`sort_param` still read `.student`/`.teacher`; every PDF (`students_pdf.rb`, `compact_students_pdf.rb`, `students_personal_details_pdf.rb`, `student_pdf.rb`, `evaluations_pdf.rb`, `custom_students_pdf.rb`, `teachers_pdf.rb`, `teachers_contact_pdf.rb`, `teachers_custom_pdf.rb`) and both Excel exporters (`students_excel_export.rb`, `teachers_excel_export.rb`) read `.student`/`.teacher` off enrollments/teaching_assignments; several controllers/views too (`application_controller.rb#search` — note `Api::V1::SearchController` is already fully Person-based and is the reference pattern to copy; `classrooms_controller.rb`/`api/v1/classrooms_controller.rb`'s `Student.in_classroom` calls feeding the personal-details PDF; `people/show.html.erb` routing through `@person.student`/`@person.teacher` shadow objects instead of `@person.enrollments`/`@person.teaching_assignments` directly despite already having them). **A real gotcha found**: `student.name`/`teacher.name` (`PersonConcern`, = `christian_name + full_name`) is NOT the same as `person.name` (just the `full_name` column alone) — every rename must target `person.full_name`, not `person.name`, or displayed names silently truncate. **A schema gap found**: `Attendance.substitute_teacher_id` is a `Teacher`-typed FK with no `Person` equivalent — can't be eliminated without a schema decision (add `substitute_person_id`, or accept it as a deliberate exception).
   - **8b. React:** `StudentList`, `TeacherList`, `PersonDetails`, and related components/API calls updated to the new Person-scoped endpoints. Confirmed low-risk when audited for step 5 (2026-07-27): frontend already queries `v1/enrollments`/`v1/teaching_assignments` by `person_id_eq`, no dedicated Student/Teacher endpoints exist, no `student_id`/`teacher_id` query params anywhere. Only remaining item: `src/modules/users/List.js`'s admin user-management screen still uses `teacher_id` for its person picker — depends on whatever shape step 6 gives `v1/users`/`v1/auth/me`.
9. Remove `sync_person`; drop `students` and `teachers` tables.

**Note:** supersedes Phase J item 6 (Student/Teacher create+edit forms) and Phase I (dedicated Students API) — once decommissioned, these become Person-scoped forms/endpoints instead.

---

### Phase P: Drop phones/emails/addresses Tables — Pending

After verifying the flatten data looks correct in production, drop the now-unused polymorphic tables.

**Prerequisite:** confirm row counts on prod match expectations — `SELECT COUNT(*) FROM people WHERE phone IS NOT NULL` should match the old `phones` primary row count.

```ruby
class DropPhoneEmailAddressTables < ActiveRecord::Migration[7.2]
  def change
    drop_table :phones
    drop_table :emails
    drop_table :addresses
  end
end
```

---

### Phase T: Add Sentry Error Tracking — Pending

Split out from Phase N item 5. No error tracking/alerting exists today — errors are only visible by tailing `log/production.log` (or PM2's STDOUT capture) over SSH.

**Key deliverables:**
- Add `sentry-ruby` + `sentry-rails` gems to `Gemfile`.
- New `config/initializers/sentry.rb`, configured with DSN via `ENV['SENTRY_DSN']` (same env-var pattern as `DATABASE_PASSWORD` — set in `ecosystem.config.js`'s `env` block on the server, never committed).
- Free Developer tier (5K events/month, 1 user) is plenty at this app's scale.

**Prerequisite:** needs a Sentry account/DSN from you first — nothing to implement until that exists.

---

### Phase U: Add Evaluation Creator — Pending

**Goal:** Track which teacher/person wrote an `Evaluation` (the "Nhận Xét" note on an enrollment), so the UI can show "— Teacher Name" attribution. Motivated by the `EnrollmentHistoryCard.js` quote-block redesign — currently `Evaluation` has no author reference at all (`content`, `evaluable_type`, `evaluable_id`, `organization_id` only; confirmed via `app/models/evaluation.rb` and `app/serializers/evaluation_serializer.rb`).

**Rails:**
1. Migration: add nullable `person_id` (bigint, FK → `people`, indexed) to `evaluations`. Nullable — existing rows have no known author and shouldn't be backfilled with a guess.
2. `Evaluation` model: `belongs_to :person, optional: true`.
3. `EvaluationSerializer`: add `belongs_to :person` so responses include `person.full_name` alongside `content`.
4. `EvaluationsController#create`: set `person_id` from `current_user.person_id` server-side (don't accept a client-supplied value — this is "who wrote it," not user-editable data). No policy change needed; existing teacher-of-classroom scoping already covers who's allowed to write an evaluation.

**React:**
5. `EnrollmentHistoryCard.js` / `EvaluationCard.js`: render `evaluation.person?.full_name` as an attribution line after the note content (e.g. "— {name}"); omit the line entirely when `person` is null (all pre-existing evaluations).

**Verification:**
- Create a new evaluation as a teacher user → confirm `person_id` is set to that teacher's own person record and the UI shows "— {Teacher Name}".
- Confirm pre-existing evaluations (no `person_id`) still render with no attribution line, no crash.

---

## Critical Files Summary

### Rails Backend
```
# FIXES
config/initializers/cors.rb                     # Phase D: Security fix
db/migrate/xxx_add_missing_indexes.rb           # Phase C: Performance

# NEW API
app/services/jwt_service.rb                     # Phase E: JWT handling
app/controllers/api/v1/base_controller.rb       # Phase E: Base controller
app/controllers/api/v1/auth_controller.rb       # Phase F: Auth endpoints
app/controllers/api/v1/classrooms_controller.rb # Phase H: CRUD
app/controllers/api/v1/students_controller.rb   # Phase I: CRUD
app/controllers/api/v1/attendances_controller.rb # Phase K: CRUD

# MODIFY
config/routes.rb                                # Phases E-Q: Add routes
Gemfile                                         # Phase E: Add gems
```

### React Frontend
```
# FIXES
src/App.js                              # Phase A: QueryClient fix
src/modules/classrooms/StudentsTab.js   # Phase A: State bug fix
src/modules/classrooms/AttendancesTab.js # Phase A: Key prop fix
src/api/index.js                        # Phase B: Env var + interceptor

# NEW FILES
.env.development                        # Phase B: API URL
.env.production                         # Phase B: API URL
src/components/ErrorBoundary.js         # Phase B: Error handling
src/contexts/AuthContext.js             # Phase G: Auth state
src/hooks/useAuth.js                    # Phase G: Auth hook
src/modules/auth/LoginPage.js           # Phase G: Login form
src/components/ProtectedRoute.js        # Phase G: Route guard
src/modules/students/List.js            # Phase J: Student list
src/modules/students/Details.js         # Phase J: Student detail
src/modules/search/SearchPage.js        # Phase N: Search
src/components/layout/MobileNav.js      # Phase O: Mobile nav
```

---

## Issues Found

| Area | Issue | Priority | Status |
|------|-------|----------|--------|
| CORS `origins '*'` | Security vulnerability | CRITICAL | ✅ Fixed (Phase D) |
| State update in render | Causes infinite loops | CRITICAL | ✅ Fixed (Phase A) |
| QueryClient recreation | Performance issue | HIGH | ✅ Fixed (Phase A) |
| Missing DB indexes | Slow queries | HIGH | ✅ Fixed (Phase C) |
| No error handling | Poor UX | HIGH | ✅ Fixed (Phase B, E) |
| Hardcoded API URL | Deployment issues | MEDIUM | ✅ Fixed (Phase B) |
| Invalid key props | React warnings | MEDIUM | ✅ Fixed (Phase A) |
| `teacher_of_classroom?` only checked first assignment | Auth bug | HIGH | ✅ Fixed (Phase K) |
| Auth logic duplicated across User model + policies | Maintainability | MEDIUM | ✅ Fixed (Phase K) |
| Hardcoded `@current_year = 2025` in policies | Wrong auth in non-current years | MEDIUM | ✅ Fixed (Phase K) |
| Contact policies open to any authenticated user | Security gap | HIGH | ✅ Fixed (Phase K) |
| `consider_all_requests_local = true` in production | Exposes stack traces | CRITICAL | ✅ Fixed (Phase N) |
| `log_level = :debug` in production | Leaks sensitive data in logs | MEDIUM | ✅ Fixed (Phase N) |
| DB password plaintext in database.yml | Credential exposure risk | HIGH | ✅ Fixed (Phase N) — password rotated |
| No multi-tenancy | All data globally visible | HIGH | ✅ Fixed (Phase L) — cross-tenant isolation confirmed end-to-end |
| `Student#sync_person` wrote `date_confirmation` into `declaration_date` | Wrong sacrament data | MEDIUM | ✅ Fixed (Phase O) |
| `Student#sync_person` / `Teacher#sync_person` wrote to deleted Phone/Email/Address models | Runtime crash on student/teacher save | CRITICAL | ✅ Fixed (Phase O) |
| `Student#sync_person`/`Teacher#sync_person` wholesale-overwrote `person.data`, clobbering Person-profile-page custom-field edits | Silent data loss, last-write-wins | MEDIUM | ✅ Fixed (Phase S) — now merges via `update_data_field` |
| `DataFieldsController#data_field_params` read `f['field']` instead of `f['field_name']` | Custom-fields form (sacraments/parents_info/additional_info) silently permitted nothing | MEDIUM | ✅ Fixed (Phase S) |