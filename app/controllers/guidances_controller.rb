class GuidancesController < SecondaryResourcesController
  before_action :auth, :admin?

  def update
    skip_redirect
    super
  end

private

  def model_klass
    Guidance
  end

  def permit_params
    [:position, :teacher_id, :classroom_id]
  end
end
