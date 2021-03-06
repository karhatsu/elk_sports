class Official::CupsController < Official::OfficialController
  before_action :assign_cup_by_id, :check_assigned_cup, :except => [:new, :create]

  def new
    @cup = current_user.cups.build
  end

  def create
    @cup = current_user.cups.build(create_cup_params)
    if @cup.valid? and enough_races?
      @cup.save!
      @cup.create_default_cup_series
      current_user.cups << @cup
      flash[:success] = 'Cup-kilpailu lisätty'
      redirect_to official_cup_path(@cup)
    else
      flash_error_for_too_few_races unless enough_races?
      render :new
    end
  end

  def show
  end

  def update
    @cup.attributes = update_cup_params
    if @cup.valid? and enough_races?
      @cup.save!
      flash[:success] = 'Cup-kilpailu päivitetty'
        redirect_to official_cup_path(@cup)
    else
      flash_error_for_too_few_races unless enough_races?
      render :edit
    end
  end

  def destroy
    @cup.destroy
    redirect_to official_root_path
  end

  private
  def enough_races?
    params[:cup][:race_ids] ||= []
    params[:cup][:race_ids].length >= @cup.top_competitions.to_i
  end

  def flash_error_for_too_few_races
    flash[:error] = 'Sinun täytyy valita vähintään yhtä monta kilpailua kuin on yhteistulokseen laskettavien kilpailuiden määrä'
  end

  def create_cup_params
    params.require(:cup).permit(:name, :top_competitions, :include_always_last_race, :public_message, race_ids: [])
  end

  def update_cup_params
    params.require(:cup).permit(:name, :top_competitions, :include_always_last_race, :public_message, race_ids: [],
                                cup_series_attributes: [:id, :name, :series_names, :_destroy])
  end
end
