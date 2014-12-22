# encoding: UTF-8
class Official::RacesController < Official::OfficialController
  before_action :assign_race_by_id, :check_assigned_race, :except => [:new, :create]
  before_action :create_time_points_type_options

  def show
    @is_race = true
  end

  def new
    @race = Race.new
    @race.start_time = '00:00'
    @race.start_interval_seconds = Race::DEFAULT_START_INTERVAL
    @race.batch_size = 0
    @race.batch_interval_seconds = Race::DEFAULT_BATCH_INTERVAL
    @race.sport = Sport.default_sport
    @race.start_order = Race::START_ORDER_NOT_SELECTED
  end

  def create
    @race = Race.new(create_race_params)
    if @race.save
      current_user.race_rights.create!(race: @race, primary: true)
      NewCompetitionMailer.new_race(@race, current_user).deliver_now
      flash[:success] = t('official.races.create.race_added') + ". "
      if params[:add_default_series]
        @race.add_default_series
        flash[:success] << t('official.races.create.add_competitors_info')
        redirect_to official_race_path(@race)
      else
        flash[:success] << t('official.races.create.add_series_info')
        redirect_to edit_official_race_path(@race)
      end
    else
      render :new
    end
  end

  def edit
    @is_race_edit = true
  end

  def update
    if @race.update(update_race_params)
      redirect_to official_race_path(@race)
    else
      render :edit
    end
  end

  def destroy
    if @race.destroy
      flash[:success] = t('official.races.destroy.race_removed')
    else
      flash[:error] = t('official.races.destroy.cannot_remove_race') + ": #{@race.errors[:base]}"
    end
    redirect_to official_root_path
  end

  private
  def create_time_points_type_options
    @time_points_type_options = [
      [t(:time_points_normal), Series::TIME_POINTS_TYPE_NORMAL],
      [t(:time_points_none), Series::TIME_POINTS_TYPE_NONE],
      [t(:time_points_300), Series::TIME_POINTS_TYPE_ALL_300]
    ]
  end

  def create_race_params
    params.require(:race).permit(accepted_create_params)
  end

  def update_race_params
    accepted = accepted_create_params
    accepted << { series_attributes: [:id, :name, :national_record, :estimates, :time_points_type, :_destroy,
                                      age_groups_attributes: [:id, :name, :min_competitors, :shorter_trip, :_destroy]] }
    params.require(:race).permit(accepted)
  end

  def accepted_create_params
    [ :sport_id, :name, :location, 'start_date(1i)', 'start_date(2i)', 'start_date(3i)',
      'start_time(1i)', 'start_time(2i)', 'start_time(3i)', 'start_time(4i)', 'start_time(5i)',
      :days_count, :club_level, :organizer, :home_page, :organizer_phone,
      :start_interval_seconds, :start_order, :batch_size, :batch_interval_seconds ]
  end
end
