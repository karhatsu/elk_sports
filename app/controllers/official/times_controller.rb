class Official::TimesController < Official::OfficialController
  before_action :assign_series_by_series_id, :check_assigned_series, :require_three_sports_race, :set_times

  def index
  end

  private
  def set_times
    @is_times = true
  end
end
