# == Schema Information
#
# Table name: classrooms
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  family          :string
#  group           :string
#  level           :integer
#  location        :string
#  year            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_classrooms_on_deleted_at       (deleted_at)
#  index_classrooms_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Classroom < ApplicationRecord
  acts_as_tenant :organization
  has_many :enrollments
  has_many :students, through: :enrollments
  # has_many :people, through: :guidances
  has_many :evaluations, through: :enrollments

  has_many :teaching_assignments
  has_many :teachers, through: :teaching_assignments
  # has_many :people, through: :teaching_assignments

  validates_presence_of :year, :family
  validates :group, format: { with: /\A\d?[A-Z]?\z/, message: 'invalid input' }, allow_blank: true

  def self.ransackable_attributes(auth_object = nil)
    %w[year family level group location]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[enrollments students teachers teaching_assignments]
  end

  FIELD_SETS = [
    {
      key: 'classroom',
      fields: [
        { field_name: :year, label: 'Năm Học', field_type: :number_field },
        { field_name: :family, label: 'Khối' },
        { field_name: :level, label: 'Lớp' },
        { field_name: :group, label: 'Nhóm' },
        { field_name: :location, label: 'Vị Trí Lớp' }
      ]
    }
  ]

  def long_year
    "#{year} - #{year + 1}" unless year.nil?
  end

  def name
    "#{family} #{level}#{group}".strip
  end

  def enrollments_overview
    stats = {}
    types = ResourceType.for_key('enrollment_result').pluck(:value)
    # unscope(:includes) — Enrollment's default_scope eager-loads `student: :person`, which is
    # irrelevant here and, worse, triggers Student#load_parents_info's after_find callback (a
    # per-record Person query) for every enrollment. A grouped count needs neither the includes
    # nor any Enrollment instantiation at all.
    counts_by_result = enrollments.unscope(:includes, :order).group(:result).count
    types.each { |type| stats[type] = counts_by_result[type] || 0 }
    stats
  end

  def teaching_assignments_overview
    # unscope(:includes) — TeachingAssignment's default_scope eager-loads :teacher, which is not
    # needed here and triggers Teacher#load_additional_info's after_find callback (a per-record
    # Person query) for every teaching assignment. Re-add only the :person include we actually need.
    teaching_assignments.unscope(:includes, :order).includes(:person)
                         .sort_by { |ta| [ta.position_sort_param, ta.person&.sort_param.to_s] }
                         .map { |ta| { id: ta.id, position: ta.position, person: { id: ta.person_id, full_name: ta.person&.full_name } } }
  end

  def sort_param
    families_order = [
      'Trưởng Ban',
      'Kỹ Thuật',
      'Khai Tâm',
      'Rước Lễ',
      'Thêm Sức',
      'Bao Đồng',
      'Vào Đời'
    ]

    "#{year}#{families_order.index(family) || families_order.count}#{level || 0}#{group || 0}#{}"
  end
end
