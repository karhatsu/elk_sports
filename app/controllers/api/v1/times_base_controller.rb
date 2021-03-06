class Api::V1::TimesBaseController < Api::V1::ApiBaseController
  def update
    return render status: 404, body: nil unless race && competitor
    return render status: 500, json: {errors: ['Race not configured for API usage']} if race.api_secret.blank?
    return render status: 400, json: {errors: ['ms_since_midnight missing']} unless ms_since_midnight
    competitor[time_field] = resolve_competitor_time
    if !validate_checksum
      render status: 400, json: {errors: ['Invalid checksum']}
    elsif competitor.save
      render status: 201, body: nil
    else
      render status: 400, json: {errors: competitor.errors.full_messages}
    end
  end

  private

  def race
    @race ||= Race.where(id: params[:race_id]).first
  end

  def competitor
    @competitor ||= @race.competitors.where(number: params[:competitor_id]).first
  end

  def validate_checksum
    params[:checksum] == Digest::MD5.hexdigest("#{ms_since_midnight}#{race.api_secret}")
  end

  def resolve_competitor_time
    secs_since_midnight = ms_since_midnight / 1000
    race_advance = {hours: -@race.start_time.hour, minutes: -@race.start_time.min}
    ((Time.now.beginning_of_day + secs_since_midnight.seconds).advance(race_advance)).strftime('%H:%M:%S')
  end

  def ms_since_midnight
    params[:ms_since_midnight]
  end
end
