# Vietnamese New Address Format

> **Status:** Planned — not yet started
> **Related:** `MIGRATION_PLAN.md` Phase Q (seed) + Phase R (migration & decommission)

---

## Context

The current address format on `people` and `organizations` (street_number, street_name, ward, district, city) maps to the v1 Vietnamese administrative hierarchy (province → district → ward). The new format simplifies this to street_address + ward/commune + province, using the [provinces.open-api.vn v2 API](https://provinces.open-api.vn/api/v2/redoc) which exposes a two-level hierarchy (province → ward, no intermediate district).

`area` (Xóm Giáo) is a church-community field unrelated to the official address format — it stays on both models.

**Old format columns (to retire):** `street_number`, `street_name`, `ward`, `district`, `city`
**New format columns (already added):** `street_address`, `province`, `subregion`
**After decommission:** rename `subregion` → `ward`

**Note:** `organizations` has no legacy data (fresh table, no rows), so the old columns were already dropped directly via `RemoveV1AddressFieldsFromOrganizations` instead of waiting for Phase 7 below. `organizations` skips Phases 3/4 (no data to clean up or backfill) but still needs Phase 2 (`province_code`/`ward_code`) and Phase 8 (`subregion` → `ward` rename) once those land. Phases 3, 4, and 7 below apply to `people` only.

All existing address data is assumed to be in **Ho Chi Minh City** (province code `79`).

---

## API Reference

### v1 API — normalized, three-level (used for seeding reference DB)

| Endpoint | Returns |
|----------|---------|
| `GET /api/v1/` | All provinces — `[{name, code, division_type, codename, phone_code, districts: []}]` |
| `GET /api/v1/d` | All districts — `[{name, code, division_type, codename, province_code, wards: []}]` |
| `GET /api/v1/w` | All wards — `[{name, code, division_type, codename, district_code}]` |

### v2 API — flat, two-level (used for runtime lookups)

| Endpoint | Returns |
|----------|---------|
| `GET /api/v2/` | All provinces — `[{name, code, division_type, codename, phone_code}]` |
| `GET /api/v2/p/{code}?depth=2` | Province + flat ward list — `wards: [{name, code, division_type, codename, province_code}]` |

---

## Phase 1 — Seed Reference Tables (MIGRATION_PLAN Phase Q)

### 1a. Create tables

```ruby
# Migration: CreateVnAddressReferenceTables
create_table :vn_provinces, id: false do |t|
  t.integer :code, primary_key: true
  t.string :name, null: false
  t.string :division_type
  t.string :codename
  t.integer :phone_code
end

create_table :vn_districts, id: false do |t|
  t.integer :code, primary_key: true
  t.string :name, null: false
  t.string :division_type
  t.string :codename
  t.integer :province_code, null: false
end
add_index :vn_districts, :province_code

create_table :vn_wards, id: false do |t|
  t.integer :code, primary_key: true
  t.string :name, null: false
  t.string :division_type
  t.string :codename
  t.integer :district_code, null: false
end
add_index :vn_wards, :district_code
```

### 1b. Add AR models

```ruby
# app/models/vn_province.rb
class VnProvince < ApplicationRecord
  self.primary_key = :code
  has_many :vn_districts, foreign_key: :province_code
end

# app/models/vn_district.rb
class VnDistrict < ApplicationRecord
  self.primary_key = :code
  belongs_to :vn_province, foreign_key: :province_code
  has_many :vn_wards, foreign_key: :district_code
end

# app/models/vn_ward.rb
class VnWard < ApplicationRecord
  self.primary_key = :code
  belongs_to :vn_district, foreign_key: :district_code
end
```

### 1c. Seed service

**New file:** `app/services/vietnamese_address_seeder.rb`

```ruby
class VietnameseAddressSeeder
  BASE_URL = "https://provinces.open-api.vn/api/v1"

  def self.seed!
    seed_provinces
    seed_districts
    seed_wards
  end

  def self.seed_provinces
    data = fetch("/")
    VnProvince.upsert_all(
      data.map { |p| p.slice("code", "name", "division_type", "codename", "phone_code") },
      unique_by: :code
    )
  end

  def self.seed_districts
    data = fetch("/d")
    VnDistrict.upsert_all(
      data.map { |d| d.slice("code", "name", "division_type", "codename", "province_code") },
      unique_by: :code
    )
  end

  def self.seed_wards
    data = fetch("/w")
    # Batch upsert in chunks to avoid memory pressure (~10k records)
    data.each_slice(1000) do |batch|
      VnWard.upsert_all(
        batch.map { |w| w.slice("code", "name", "division_type", "codename", "district_code") },
        unique_by: :code
      )
    end
  end

  private

  def self.fetch(path)
    uri = URI("#{BASE_URL}#{path}")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
```

Run via `rails runner 'VietnameseAddressSeeder.seed!'` or from a migration `up` block.

---

## Phase 2 — Add Code Columns

```ruby
# Migration: AddAddressCodeColumnsToPeopleAndOrganizations
add_column :people,        :province_code, :integer
add_column :people,        :ward_code,     :integer
add_column :organizations, :province_code, :integer
add_column :organizations, :ward_code,     :integer
```

---

## Phase 3 — Data Cleanup (before migration)

All existing records are assumed to be in Ho Chi Minh City. Before running backfill:

1. **Audit non-HCMC records:**
   ```sql
   SELECT DISTINCT city FROM people WHERE city IS NOT NULL AND city NOT ILIKE '%hồ chí minh%' AND city NOT ILIKE '%ho chi minh%' AND city NOT ILIKE '%hcm%';
   ```
   Flag any non-HCMC rows — decide to correct or exclude.

2. **Audit ward value diversity (HCMC wards to match):**
   ```sql
   SELECT ward, COUNT(*) FROM people WHERE ward IS NOT NULL GROUP BY ward ORDER BY COUNT(*) DESC;
   ```
   Check for encoding issues (e.g., missing diacritics), leading/trailing whitespace, inconsistent capitalization.

3. **Normalize obvious variants** in a Rails console or one-off script before running the main migration (e.g., `"Phường 1"` vs `"P. 1"` vs `"phuong 1"`).

4. **Confirm street_address baseline:**
   ```sql
   SELECT COUNT(*) FROM people WHERE street_address IS NULL AND (street_number IS NOT NULL OR street_name IS NOT NULL);
   ```
   These rows need `street_address` built from old fields.

---

## Phase 4 — Data Migration / Backfill

```ruby
# Migration: BackfillNewAddressFieldsOnPeopleAndOrganizations

HCM_PROVINCE_CODE = 79
HCM_PROVINCE_NAME = "Thành phố Hồ Chí Minh"

# Build ward lookup: normalized_name → ward code (HCMC only)
hcm_district_codes = VnDistrict.where(province_code: HCM_PROVINCE_CODE).pluck(:code)
ward_lookup = VnWard.where(district_code: hcm_district_codes)
                    .each_with_object({}) { |w, h| h[w.name.downcase.strip] = w }

[Person, Organization].each do |klass|
  klass.unscoped.find_each do |record|
    updates = {}

    # street_address from old fields
    if record.street_address.blank?
      parts = [record.street_number, record.street_name].compact.map(&:strip).reject(&:empty?)
      updates[:street_address] = parts.join(" ").presence
    end

    # province — assume HCMC
    if record.province.blank?
      updates[:province] = HCM_PROVINCE_NAME
      updates[:province_code] = HCM_PROVINCE_CODE
    end

    # subregion + ward_code from old ward
    if record.subregion.blank? && record.ward.present?
      match = ward_lookup[record.ward.downcase.strip]
      updates[:subregion] = match&.name || record.ward
      updates[:ward_code]  = match&.code
    end

    record.update_columns(updates) if updates.any?
  end
end
```

**Post-migration audit:**
```sql
-- Unresolved wards (no code match found)
SELECT ward, subregion, ward_code FROM people WHERE subregion IS NOT NULL AND ward_code IS NULL;
-- Expected: low count after cleanup in Phase 3
```

---

## Phase 5 — Model / Serializer / Controller Updates

### `app/models/person.rb`

- Update `FIELD_SETS` address section:
  ```ruby
  { key: 'address', fields: [
    { field_name: :street_address, label: 'Địa Chỉ' },
    { field_name: :subregion,      label: 'Phường/Xã' },   # rename label to 'Phường/Xã' after Phase 8
    { field_name: :province,       label: 'Tỉnh/Thành Phố' },
    { field_name: :area,           label: 'Xóm Giáo' },
  ]}
  ```
- Update `ransackable_attributes` — add `street_address`, `province`, `province_code`, `subregion`, `ward_code`; remove `street_number`, `street_name`, `ward`, `district`, `city`
- Update `full_address`:
  ```ruby
  def full_address
    [street_address, subregion, province].compact.reject(&:empty?).join(", ").presence
  end
  ```

### `app/serializers/person_serializer.rb`

Replace `:street_number, :street_name, :ward, :district, :city` with:
`:street_address, :province, :province_code, :subregion, :ward_code`
Keep `:area`.

### Controllers — `app/controllers/people_controller.rb` and `app/controllers/api/v1/people_controller.rb`

Replace old address params with:
`:street_address, :province, :province_code, :subregion, :ward_code`
Keep `:area`.

---

## Phase 6 — API Endpoints for Frontend Dropdowns

**New file:** `app/controllers/api/v1/addresses_controller.rb`

```ruby
module Api
  module V1
    class AddressesController < BaseController
      skip_before_action :authenticate_request, only: [:provinces, :wards]

      def provinces
        render json: VnProvince.order(:name).select(:code, :name, :division_type)
      end

      def wards
        province_code = params[:province_code].to_i
        district_codes = VnDistrict.where(province_code: province_code).pluck(:code)
        render json: VnWard.where(district_code: district_codes)
                           .order(:name)
                           .select(:code, :name, :division_type, :district_code)
      end
    end
  end
end
```

**Routes (`config/routes.rb`):**
```ruby
namespace :v1 do
  get 'addresses/provinces',                               to: 'addresses#provinces'
  get 'addresses/provinces/:province_code/wards',          to: 'addresses#wards'
end
```

---

## Phase 7 — Decommission Old Fields

**Run only after Phase 4 backfill is confirmed and manually reviewed.**

```ruby
# Migration: RemoveOldAddressFieldsFromPeopleAndOrganizations
remove_column :people,        :street_number
remove_column :people,        :street_name
remove_column :people,        :ward
remove_column :people,        :district
remove_column :people,        :city
remove_column :organizations, :street_number
remove_column :organizations, :street_name
remove_column :organizations, :ward
remove_column :organizations, :district
remove_column :organizations, :city
```

---

## Phase 8 — Rename subregion → ward

```ruby
# Migration: RenameSubregionToWardOnPeopleAndOrganizations
rename_column :people,        :subregion, :ward
rename_column :organizations, :subregion, :ward
```

After migration, find-replace all `subregion` → `ward` in:
- `app/models/person.rb` (FIELD_SETS, `full_address`, `ransackable_attributes`)
- `app/serializers/person_serializer.rb`
- `app/controllers/people_controller.rb`
- `app/controllers/api/v1/people_controller.rb`

---

## Files Changed

| File | Change |
|------|--------|
| `db/migrate/..._create_vn_address_reference_tables.rb` | New — Phase 1a |
| `app/models/vn_province.rb` | New |
| `app/models/vn_district.rb` | New |
| `app/models/vn_ward.rb` | New |
| `app/services/vietnamese_address_seeder.rb` | New — Phase 1c |
| `db/seeds.rb` | Add `VietnameseAddressSeeder.seed!` call |
| `db/migrate/..._add_address_code_columns.rb` | New — Phase 2 |
| `db/migrate/..._backfill_new_address_fields.rb` | New — Phase 4 |
| `app/models/person.rb` | Update FIELD_SETS, full_address, ransackable — Phase 5 |
| `app/serializers/person_serializer.rb` | Replace address attributes — Phase 5 |
| `app/controllers/people_controller.rb` | Update permitted params — Phase 5 |
| `app/controllers/api/v1/people_controller.rb` | Update permitted params — Phase 5 |
| `app/controllers/api/v1/addresses_controller.rb` | New — Phase 6 |
| `config/routes.rb` | Add address lookup routes — Phase 6 |
| `db/migrate/..._remove_old_address_fields.rb` | New — Phase 7 |
| `db/migrate/..._rename_subregion_to_ward.rb` | New — Phase 8 |

---

## Safe Deployment Order

| Group | Phases | Notes |
|-------|--------|-------|
| Additive | 1, 2, 5, 6 | No risk — adds tables/columns/endpoints, no behavior change |
| Data | 3, 4 | Run cleanup first; backfill in a console session before committing |
| Destructive | 7 | Run only after Phase 4 audit is clean in production |
| Rename | 8 | Run after Phase 7 is stable |

---

## Verification

1. `VietnameseAddressSeeder.seed!` → `VnProvince.count` = 63, `VnWard.count` > 10_000
2. `GET /api/v1/addresses/provinces` → 63 provinces JSON
3. `GET /api/v1/addresses/provinces/79/wards` → all HCMC wards
4. After Phase 4: `Person.where(province_code: nil).count` near zero; `Person.where(ward_code: nil, subregion: nil).count` near zero
5. After Phase 7: `Person.column_names` does not include `ward`, `district`, `city`, `street_number`, `street_name`
6. After Phase 8: `Person.column_names` includes `ward` (was `subregion`)
