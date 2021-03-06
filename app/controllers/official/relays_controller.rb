class Official::RelaysController < Official::OfficialController
  before_action :assign_race_by_race_id, :check_assigned_race, :require_three_sports_race, :set_relays
  before_action :assign_relay_by_id, :only => [:edit, :update, :destroy]
  before_action :handle_time_parameters, :only => [:create, :update]
  before_action :set_no_result_reason_options, :only => [:edit, :update]
  before_action :set_relay_main, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @relay = @race.relays.build(:legs_count => 4)
    @penalty_method = 'run'
  end

  def create
    @relay = @race.relays.build(create_relay_params)
    handle_penalty_method
    if @relay.save
      flash[:success] = 'Viesti luotu. Voit nyt lisätä viestiin joukkueita.'
      redirect_to edit_official_race_relay_path(@race, @relay)
    else
      render :new
    end
  end

  def edit
    @penalty_method = @relay.penalty_seconds? ? 'penalty_seconds' : 'run'
  end

  def update
    @relay.attributes = update_relay_params
    handle_penalty_method
    if @relay.updated_at.to_i != params[:updated_at].to_i
      flash[:error] = 'Joku muu on muokannut viestiä samaan aikaan. Yritä tallennusta uudestaan tai kokeile tulosten tallentamista Pikasyötön avulla.'
      redirect_to edit_official_race_relay_path(@race, @relay)
    elsif @relay.save
      @relay.touch unless @relay.changed?
      flash[:success] = 'Viestin tiedot päivitetty'
      redirect_to edit_official_race_relay_path(@race, @relay)
    else
      render :edit
    end
  end

  def destroy
    @relay.destroy
    flash[:success] = 'Viesti poistettu'
    redirect_to official_race_relays_path(@race)
  end

  private

  def set_relay_main
    @relay_main = true
  end

  def set_no_result_reason_options
    @no_result_reason_options = [[t(:normal), '']]
    @no_result_reason_options << [RelayTeam::DNS, RelayTeam::DNS]
    @no_result_reason_options << [RelayTeam::DNF, RelayTeam::DNF]
    @no_result_reason_options << [RelayTeam::DQ, RelayTeam::DQ]
  end

  def handle_time_parameters
    handle_time_parameter params[:relay], "start_time"
  end

  def handle_penalty_method
    @penalty_method = params[:penalty_method]
    if @penalty_method == 'run'
      @relay.estimate_penalty_seconds = nil
      @relay.shooting_penalty_seconds = nil
    else
      @relay.estimate_penalty_distance = nil
      @relay.shooting_penalty_distance = nil
    end
  end

  def create_relay_params
    params.require(:relay).permit(accepted_create_params)
  end

  def update_relay_params
    accepted = accepted_create_params
    accepted.delete :legs_count
    accepted << { relay_correct_estimates_attributes: accepted_correct_estimates_params }
    accepted << { relay_teams_attributes: [:name, :number, :no_result_reason, :id, :_destroy,
                                          relay_competitors_attributes: accepted_competitor_params] }
    params.require(:relay).permit(accepted)
  end

  def accepted_create_params
    [ :name, :legs_count, :start_day, :leg_distance, :estimate_penalty_distance, :shooting_penalty_distance,
      :estimate_penalty_seconds, :shooting_penalty_seconds,
      'start_time(1i)', 'start_time(2i)', 'start_time(3i)', 'start_time(4i)', 'start_time(5i)' ]
  end

  def accepted_correct_estimates_params
    correct_est_params = []
    @relay.legs_count.times do |i|
      correct_est_params << { "new_#{i}_relay_correct_estimates" => [:leg, :distance] }
    end
    correct_est_params << [:leg, :distance, :id]
    correct_est_params
  end

  def accepted_competitor_params
    competitor_params = []
    @relay.legs_count.times do |i|
      competitor_params << { "new_#{i}_relay_competitors" => [:leg, :first_name, :last_name, :misses, :estimate] }
    end
    competitor_params << [:leg, :first_name, :last_name, :misses, :estimate, :id]
    competitor_params
  end
end
