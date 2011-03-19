class Race < ActiveRecord::Base
  DEFAULT_START_INTERVAL = 60
  DEFAULT_BATCH_INTERVAL = 180

  belongs_to :sport
  has_many :series, :order => 'name'
  has_many :age_groups, :through => :series
  has_many :competitors, :through => :series
  has_many :clubs
  has_many :correct_estimates, :order => 'min_number'
  has_many :relays, :order => 'name'
  has_many :team_competitions, :order => 'name'
  has_and_belongs_to_many :users, :join_table => :race_officials

  accepts_nested_attributes_for :series, :allow_destroy => true
  accepts_nested_attributes_for :correct_estimates, :allow_destroy => true
  accepts_nested_attributes_for :clubs
  accepts_nested_attributes_for :relays

  before_validation :set_end_date

  validates :sport, :presence => true
  validates :name, :presence => true
  validates :location, :presence => true
  validates :start_date, :presence => true
  validates :start_interval_seconds, :numericality => { :only_integer => true,
    :greater_than => 0 }
  validates :batch_size, :numericality => { :only_integer => true,
    :greater_than_or_equal_to => 0 }
  validates :batch_interval_seconds, :numericality => { :only_integer => true,
    :greater_than => 0 }
  validates :team_competitor_count, :numericality => { :allow_nil => true,
    :only_integer => true, :greater_than => 1 }
  validate :end_date_not_before_start_date
  validate :check_duplicate_name_location_start_date, :on => :create

  before_destroy :prevent_destroy_if_series

  scope :past, :conditions => ['end_date<?', Time.zone.today], :order => 'end_date DESC'
  scope :ongoing, :conditions => ['start_date<=? and end_date>=?',
    Time.zone.today, Time.zone.today]
  scope :future, :conditions => ['start_date>?', Time.zone.today], :order => 'start_date'

  attr_accessor :email, :password # for publishing

  def add_default_series
    DefaultSeries.all.each do |ds|
      s = Series.new(:name => ds.name)
      ds.default_age_groups.each do |dag|
        s.age_groups << AgeGroup.new(:name => dag.name,
          :min_competitors => dag.min_competitors)
      end
      series << s
    end
  end

  def finish
    unless each_competitor_has_correct_estimates?
      errors.add(:base, "Osalta kilpailijoista puuttuu oikea arviomatka.")
      return false
    end
    competitors.each do |c|
      unless c.finished?
        name = "#{c.first_name} #{c.last_name}"
        errors.add(:base, "Ainakin yhdeltä kilpailijalta " +
          "(#{name}, #{c.series.name}) puuttuu tulos. " +
          "Jos kilpailija ei ole lähtenyt matkaan tai on keskeyttänyt, " +
          "merkitse tieto tuloslomakkeen 'Ei tulosta' kohtaan.")
        return false
      end
    end
    self.finished = true
    save!
    true
  end

  def finish!
    finish || raise(errors.full_messages.to_s)
  end

  def days_count
    return 1 if end_date.nil?
    (end_date - start_date).to_i + 1
  end

  def set_correct_estimates_for_competitors
    reload
    return if correct_estimates.empty?

    number_to_corrects_hash = Hash.new
    max_range_low_limit = nil
    correct_estimates.each do |ce|
      if ce.max_number.nil?
        max_range_low_limit = ce.min_number
        number_to_corrects_hash[max_range_low_limit] =
          [ce.distance1, ce.distance2, ce.distance3, ce.distance4]
      else
        (ce.min_number..ce.max_number).to_a.each do |nro|
          number_to_corrects_hash[nro] =
            [ce.distance1, ce.distance2, ce.distance3, ce.distance4]
        end
      end
    end

    competitors.each do |c|
      if c.number
        if max_range_low_limit and c.number >= max_range_low_limit
          set_correct_estimates_for_competitor(c, number_to_corrects_hash, max_range_low_limit)
        elsif number_to_corrects_hash[c.number]
          set_correct_estimates_for_competitor(c, number_to_corrects_hash, c.number)
        else
          c.reset_correct_estimates
        end
        c.save!
      end
    end
  end

  def each_competitor_has_correct_estimates?
    competitors.where('competitors.correct_estimate1 is null or ' +
        'competitors.correct_estimate2 is null').empty?
  end

  def estimates_at_most
    series.each do |s|
      return 4 if s.estimates == 4
    end
    2
  end

  def has_team_competition?
    team_competitor_count
  end

  def team_results
    return nil unless has_team_competition?
    hash = create_team_results_hash
    sorted_teams = sorted_teams_from_team_results_hash(hash)
    remove_teams_without_enough_competitors(sorted_teams)
    sorted_teams
  end

  private
  def end_date_not_before_start_date
    if end_date and end_date < start_date
      errors.add(:end_date, "ei voi olla ennen alkupäivää")
    end
  end

  def check_duplicate_name_location_start_date
    if name and location and start_date and
        Race.exists?(:name => name, :location => location, :start_date => start_date)
      errors.add(:base, 'Järjestelmästä löytyy jo kilpailu, jolla on sama nimi, sijainti ja päivämäärä')
    end
  end

  def set_end_date
    self.end_date = start_date unless end_date
  end

  def prevent_destroy_if_series
    if series.count > 0
      errors.add(:base, "Kilpailun voi poistaa vain jos siinä ei ole sarjoja")
      return false
    end
  end

  def set_correct_estimates_for_competitor(competitor, number_to_corrects_hash, key)
    competitor.correct_estimate1 = number_to_corrects_hash[key][0]
    competitor.correct_estimate2 = number_to_corrects_hash[key][1]
    if competitor.series.estimates == 4
      competitor.correct_estimate3 = number_to_corrects_hash[key][2]
      competitor.correct_estimate4 = number_to_corrects_hash[key][3]
    else
      competitor.correct_estimate3 = nil
      competitor.correct_estimate4 = nil
    end
  end

  def create_team_results_hash
    # { team1 => {:club => club1, :points => 0, :best_points => 0,
    #             :best_shot_points => 0, :fastest_time => 9999999,
    #             :competitors => []},
    #   team2 => {...} }
    team_results_hash = Hash.new
    competitor_counter = Hash.new

    Competitor.sort(competitors.
        where(['series.estimates=2 and series.no_time_points=?', false]).
        includes([:series, :club, :age_group, :shots])).each do |competitor|
      break if competitor.points.nil? or competitor.unofficial
      competitor_count = competitor_counter[competitor.club] || 0
      if competitor_count < team_competitor_count
        competitor_counter[competitor.club] = competitor_count + 1
        if team_results_hash[competitor.club]
          team_hash = team_results_hash[competitor.club]
          update_team_hash(team_hash, competitor)
        else
          team_results_hash[competitor.club] = create_team_hash(competitor)
        end
      end
    end

    team_results_hash
  end

  def update_team_hash(team_hash, competitor)
    team_hash[:points] += competitor.points
    team_hash[:best_points] = competitor.points if competitor.
      points > team_hash[:points]
    team_hash[:best_shot_points] = competitor.shot_points if competitor.
      points > team_hash[:best_shot_points]
    team_hash[:fastest_time] = competitor.time_in_seconds if competitor.
      time_in_seconds < team_hash[:fastest_time]
    team_hash[:competitors] << competitor
  end

  def create_team_hash(competitor)
    team_hash = Hash.new(:club => competitor.club, :points => 0, :competitors => [])
    team_hash[:club] = competitor.club
    team_hash[:points] = competitor.points
    team_hash[:best_points] = competitor.points
    team_hash[:best_shot_points] = competitor.shot_points
    team_hash[:fastest_time] = competitor.time_in_seconds
    team_hash[:competitors] = [competitor]
    team_hash
  end

  def sorted_teams_from_team_results_hash(hash)
    hash.values.sort do |a, b|
      [b[:points], b[:best_points], b[:best_shot_points], a[:fastest_time]] <=>
        [a[:points], a[:best_points], a[:best_shot_points], b[:fastest_time]]
    end
  end

  def remove_teams_without_enough_competitors(sorted_teams)
    sorted_teams.delete_if { |club| club[:competitors].length < team_competitor_count }
  end
end
