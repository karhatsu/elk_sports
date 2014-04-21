class Official::RelayQuickSavesController < Official::OfficialController
  before_action :assign_relay_by_relay_id, :check_assigned_relay, :set_relays

  def index
  end

  def estimate
    @name = 'estimate'
    do_quick_save(RelayEstimateQuickSave.new(@relay.id, params[:string])) do
      @result = "arvio: #{@competitor.estimate}"
    end
  end

  def misses
    @name = 'misses'
    do_quick_save(RelayMissesQuickSave.new(@relay.id, params[:string])) do
      @result = "ohilaukaukset: #{@competitor.misses}"
    end
  end

  def time
    @name = 'time'
    do_quick_save(RelayTimeQuickSave.new(@relay.id, params[:string])) do
      @result = "saapumisaika: #{@competitor.arrival_time.strftime('%H:%M:%S')}"
    end
  end

  def adjustment
    @name = 'adjustment'
    do_quick_save(RelayAdjustmentQuickSave.new(@relay.id, params[:string])) do
      @result = "korjaukset: #{@competitor.adjustment}"
    end
  end

  private
  def do_quick_save(quick_save, &block)
    if quick_save.save
      @competitor = quick_save.competitor
      block.call
      respond_to do |format|
        format.js { render :success, :layout => false }
      end
    else
      @error = quick_save.error
      respond_to do |format|
        format.js { render :error, :layout => false }
      end
    end
  end
end
