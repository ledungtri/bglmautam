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
    data = fetch("/d/")
    VnDistrict.upsert_all(
      data.map { |d| d.slice("code", "name", "division_type", "codename", "province_code") },
      unique_by: :code
    )
  end

  def self.seed_wards
    data = fetch("/w/")
    data.each_slice(1000) do |batch|
      VnWard.upsert_all(
        batch.map { |w| w.slice("code", "name", "division_type", "codename", "district_code") },
        unique_by: :code
      )
    end
  end

  def self.fetch(path)
    uri = URI("#{BASE_URL}#{path}")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
  private_class_method :fetch
end
