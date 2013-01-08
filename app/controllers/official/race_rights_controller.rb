# encoding: UTF-8
class Official::RaceRightsController < Official::OfficialController
  before_filter :assign_race_by_race_id, :check_assigned_race, :set_race_rights

  def index
  end

  def create
    user = User.find_by_email(params[:email])
    if user
      if user.races.include?(@race)
        flash[:error] = "Henkilö on jo tämän kilpailun toimitsija"
        render :index
      else
        race_right = @race.race_rights.build(params[:race_right])
        race_right.user = user
        race_right.save!
        send_invitation_mail race_right
        set_invitation_success_message race_right
        redirect_to official_race_race_rights_path(@race)
      end
    else
      flash[:error] = "Tietokannasta ei löytynyt syöttämääsi sähköpostiosoitetta"
      render :index
    end
  end

  private
  def set_race_rights
    @is_race_rights = true
  end
  
  def send_invitation_mail(race_right)
    user = race_right.user
    url = official_race_url(@race)
    if race_right.only_add_competitors
      InviteOfficialMailer.invite_only_competitor_adding(@race, current_user, user, url).deliver
    else
      InviteOfficialMailer.invite(@race, current_user, user, url).deliver
    end
  end
  
  def set_invitation_success_message(race_right)
    user = race_right.user
    message = "Toimitsija #{user.first_name} #{user.
      last_name} lisätty kilpailun #{@race.name} toimitsijaksi"
    message += " rajoitetuin oikeuksin" if race_right.only_add_competitors
    flash[:success] = message
  end
end