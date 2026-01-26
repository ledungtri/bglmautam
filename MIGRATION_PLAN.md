# Migration Plan: bglmautam to Rails API + React Frontend

> **Last Updated:** 2026-01-25
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
| H+ | Feature Completion | [ ] In Progress |

---

## Current State

### Rails Backend (bglmautam)
- Rails 7.2, Ruby 3.3.0
- Session-based auth with bcrypt
- Pundit authorization (admin, teacher-of-classroom, self)
- Existing `/api` namespace (read-only, no auth)
- Has `rack-cors`, `active_model_serializers`, `ransack`

### React Frontend (bglmautam-react)
- Create React App + JavaScript
- Material UI (continuing with this)
- TanStack React Query
- React Router v6
- Axios

**Existing React routes:**
- `/` and `/classrooms` - Classroom list
- `/classrooms/:id` - Classroom details with tabs
- `/teachers` - Teacher list
- `/people/:id` - Person details
- `/admin` - Admin page

**Missing features:**
- Authentication (login, protected routes)
- Student list/detail pages
- Attendance CRUD operations
- Search functionality
- PDF exports
- Mobile responsiveness improvements

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

### Phase H+: Feature Completion (After Auth Works)

**Add remaining features incrementally.**

| Phase | Features | Status |
|-------|----------|--------|
| H | Rails: Classrooms v1 CRUD endpoints | [ ] |
| I | Rails: Students v1 CRUD endpoints | [ ] |
| J | React: Student list/detail pages | [ ] |
| K | Rails: Attendances v1 CRUD | [ ] |
| L | React: Attendance editing | [ ] |
| M | Rails: Search endpoint | [ ] |
| N | React: Search page | [ ] |
| O | React: Mobile navigation | [ ] |
| P | Rails: PDF export endpoints | [ ] |
| Q | React: PDF download buttons | [ ] |

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

## Industry Standards Issues Found

| Area | Issue | Priority | Phase |
|------|-------|----------|-------|
| CORS `origins '*'` | Security vulnerability | CRITICAL | D |
| State update in render | Causes infinite loops | CRITICAL | A |
| QueryClient recreation | Performance issue | HIGH | A |
| Missing DB indexes | Slow queries | HIGH | C |
| No error handling | Poor UX | HIGH | B, E |
| Hardcoded API URL | Deployment issues | MEDIUM | B |
| Invalid key props | React warnings | MEDIUM | A |