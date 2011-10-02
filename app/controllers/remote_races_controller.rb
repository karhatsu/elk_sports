# encoding: UTF-8
class RemoteRacesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_user, :prepare_clubs_for_competitors
  after_filter :set_series_for_team_competitions,
    :set_age_groups_for_team_competitions, :set_age_groups_for_competitors

  def create
    if @race.save
      @user.races << @race
      unless offline_or_fake_offline?
        PublishMailer.publish_mail(@race, @user).deliver
      end
      redirect_to_success
    else
      redirect_to_error @race.errors.full_messages.join('. ') + '.'
    end
  end

  private
  def check_user
    if offline_or_fake_offline?
      @user = User.first
    else
      @user = User.find_by_email(params[:email])
      unless @user and @user.valid_password?(params[:password])
        redirect_to_error "Virheelliset tunnukset. " +
          "Varmista että olet syöttänyt palvelun #{params[:server]} tunnukset."
      end
    end
  end

  def offline_or_fake_offline?
    # this hack is for cucumber features
    (offline? and Rails.env != 'test') or (online? and Rails.env == 'test')
  end

  def prepare_clubs_for_competitors
    if save_race_without_children # in order to get an id for the race
      include_children_to_saved_race
      club_names_ids = save_clubs
      set_club_ids_for_competitors(club_names_ids)
    end
  end

  def save_race_without_children
    @race = Race.new(params[:race])
    @race = Race.new(@race.attributes) # no children in @race
    unless @race.save
      redirect_to_error @race.errors.full_messages.join('. ') + '.'
      return false
    end
    true
  end

  def include_children_to_saved_race
    @race.attributes = params[:race]
  end

  def save_clubs
    club_names_ids = Hash.new
    @race.clubs.each do |club|
      unless club_names_ids.has_key?(club.name)
        club.race_id = @race.id
        club.save!
        club_names_ids[club.name] = club.id
      end
    end
    club_names_ids
  end

  def set_club_ids_for_competitors(club_names_ids)
    @race.series.each do |series|
      series.competitors.each do |competitor|
        competitor.club_id = club_names_ids[competitor.club_name]
      end
    end
  end

  def set_age_groups_for_competitors
    @race.series.each do |series|
      series.competitors.each do |competitor|
        if competitor.age_group_name
          competitor.age_group = series.age_groups.find_by_name(competitor.age_group_name)
          competitor.save!
        end
      end
    end
  end

  def set_series_for_team_competitions
    @race.team_competitions.each do |tc|
      tc.attach_series_by_names tc.temp_series_names
    end
  end

  def set_age_groups_for_team_competitions
    @race.team_competitions.each do |tc|
      tc.attach_age_groups_by_names tc.temp_age_groups_names
    end
  end

  def redirect_to_success
    redirect_to "#{params[:source]}/official/races/#{params[:source_race_id]}/export/success"
  end

  def redirect_to_error(message)
    path = "#{params[:source]}/official/races/#{params[:source_race_id]}/export/error?" +
        "message=#{CGI::escape(message)}"
    path << "&server=#{CGI::escape(params[:server])}" if params[:server]
    path << "&email=#{CGI::escape(params[:email])}" if params[:email]
    redirect_to path
  end
end
