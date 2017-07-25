class Official::CorrectEstimatesController < Official::OfficialController
  before_action :assign_race_by_race_id, :check_assigned_race,
    :set_correct_estimates, :assign_competitors

  def index
  end

  def update
    if @race.update(correct_estimates_params)
      errors = @race.set_correct_estimates_for_competitors
      if errors.empty?
        redirect_to official_race_correct_estimates_path(@race)
      else
        flash[:error] = "Virhe tallennettaessa kilpailjan tietoja: #{errors.uniq.join('. ')}"
        render :index
      end
    else
      render :index
    end
  end

  private
  def set_correct_estimates
    @is_correct_estimates = true
  end

  def assign_competitors
    @competitors = @race.competitors.includes(:series).except(:order).order('number, id')
  end

  def correct_estimates_params
    params.require(:race).permit(correct_estimates_attributes: [:id, :min_number, :max_number, :distance1, :distance2, :distance3, :distance4, :_destroy])
  end
end
