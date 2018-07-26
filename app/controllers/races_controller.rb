class RacesController < ApplicationController
  before_action :set_races
  before_action :assign_race_by_id, :only => :show
  before_action :set_variant

  def index
    where = []
    where_params = Hash.new
    district_id = params[:district_id]
    search_text = params[:search_text]
    unless district_id.blank?
      where << 'district_id=:district_id'
      where_params[:district_id] = [district_id]
    end
    unless search_text.blank?
      where << "(name ILIKE :search_text OR location ILIKE :search_text)"
      where_params[:search_text] = "%#{search_text}%"
    end
    @competitions = Race.where(where.join(' AND '), where_params).order('start_date DESC').page(params[:page])
  end

  def show
    @is_race = true
    respond_to do |format|
      format.html
      format.pdf do
        @page_breaks = params[:page_breaks]
        render :pdf => "#{@race.name} - tulokset", :layout => true,
          :margin => pdf_margin, :header => pdf_header("#{@race.name} - Tuloskooste"), :footer => pdf_footer,
          :orientation => 'Landscape', disable_smart_shrinking: true
      end
    end
  end

end
