class Official::BatchListsController < Official::OfficialController
  private

  def build_opts
    opts = {}
    opts[:batch_day] = params[:batch_day].to_i unless params[:batch_day].blank?
    opts[:only_track_places] = params[:only_track_places]
    opts[:skip_first_track_place] = params[:skip_first_track_place]
    opts[:skip_last_track_place] = params[:skip_last_track_place]
    opts[:skip_track_places] = params[:skip_track_places].split(',').map(&:strip).map(&:to_i)
    opts
  end
end
