module MenuHelper
  def menu_cup
    @cup if @cup and not @cup.new_record?
  end

  def menu_race
    if @race and not @race.new_record?
      @race
    elsif @series
      @series.race
    elsif @relay
      @relay.race
    elsif @competitor
      @competitor.series.race
    else
      nil
    end
  end

  def menu_series
    if @series
      @series
    elsif @competitor
      @competitor.series
    else
      nil
    end
  end

  def menu_item(title, link, selected, truncate_length=nil, do_block=false, &block)
    a_title = (truncate_length ? title : nil)
    title = truncate(title, :length => truncate_length) if truncate_length
    item = '<div class="menu__item">'
    if selected
      item << link_to(title, link, :class => 'selected', :title => a_title)
    else
      item << link_to(title, link, :title => a_title)
    end
    item << block.call if do_block and block
    item << '</div>'
    raw(item)
  end

  def dropdown_menu_single(item)
    raw("<div class='menu__dropdown'><div class='dropdown_menu_item'>#{item}</div></div>")
  end

  def races_dropdown_menu(races)
    menu = '<div class="menu__dropdown">'
    races.each do |race|
      menu << "<div class='dropdown_menu_item'>#{link_to race.name, race_path(race)}</div>"
    end
    menu << "<div>#{link_to "- #{t('home.show.all_competitions')} -", races_path}</div>"
    menu << '</div>'
    raw(menu)
  end

  def series_dropdown_menu(race, type)
    return '' if race.series.count <= 1
    menu = '<div class="menu__dropdown">'
    race.series.each do |series|
      next if series.new_record?
      if type == 'results'
        link = race_series_path(locale_for_path, race, series)
      elsif type == 'start_list'
        link = race_series_start_list_path(locale_for_path, race, series)
      elsif type == 'competitors'
        link = official_series_competitors_path(locale_for_path, series)
      elsif type == 'times'
        link = official_series_times_path(locale_for_path, series)
      elsif type == 'estimates'
        link = official_series_estimates_path(locale_for_path, series)
      elsif type == 'shots'
        link = official_series_shots_path(locale_for_path, series)
      end
      menu << "<div class='dropdown_menu_item'>#{link_to series.name, link}</div>"
    end
    menu << '</div>'
    raw(menu)
  end

  def relays_dropdown_menu(race)
    return '' if race.relays.count <= 1
    menu = '<div class="menu__dropdown">'
    race.relays.each do |relay|
      menu << "<div class='dropdown_menu_item'>#{link_to relay.name, race_relay_path(locale_for_path, race, relay)}</div>"
    end
    menu << '</div>'
    raw(menu)
  end

  def team_competitions_dropdown_menu(race)
    return '' if race.team_competitions.count <= 1
    menu = '<div class="menu__dropdown">'
    race.team_competitions.each do |tc|
      menu << "<div class='dropdown_menu_item'>#{link_to tc.name, race_team_competition_path(locale_for_path, race, tc)}</div>"
    end
    menu << '</div>'
    raw(menu)
  end

  def cup_series_dropdown_menu(cup)
    return '' if cup.cup_series.length <= 1
    menu = '<div class="menu__dropdown">'
    cup.cup_series.each do |cs|
      menu << "<div class='dropdown_menu_item'>#{link_to cs.name, cup_cup_series_path(locale_for_path, cup, cs)}</div>"
    end
    menu << '</div>'
    raw(menu)
  end
end
