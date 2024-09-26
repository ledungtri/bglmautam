class GradesController < SecondaryResourcesController
  def update
    skip_redirect
    super
  end

  private

  def model_klass
    Grade
  end

  def permit_params
    [:name, :value, :enrollment_id]
  end
end
