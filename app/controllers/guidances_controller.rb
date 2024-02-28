class GuidancesController < SecondaryResourcesController
  before_action :auth, :admin?

  def model_klass
    Guidance
  end

  def permit_params
    [:position, :teacher_id, :classroom_id]
  end
end
