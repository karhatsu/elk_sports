class Official::RelayQuickSavesController < Official::OfficialController
  before_action :assign_relay_by_relay_id, :check_assigned_relay, :set_relays, :set_relay_quick_save

  def index
    @race = @relay.race
  end

  def estimate
    @name = 'estimate'
    do_quick_save(RelayQuickSave::Estimate.new(@relay.id, params[:string])) do
      @result = "arvio: #{@competitor.estimate}"
    end
  end

  def misses
    @name = 'misses'
    do_quick_save(RelayQuickSave::Misses.new(@relay.id, params[:string])) do
      @result = "ohilaukaukset: #{@competitor.misses}"
    end
  end

  def time
    @name = 'time'
    do_quick_save(RelayQuickSave::Time.new(@relay.id, params[:string])) do
      @result = "saapumisaika: #{@competitor.arrival_time.strftime('%H:%M:%S')}"
    end
  end

  def adjustment
    @name = 'adjustment'
    do_quick_save(RelayQuickSave::UnfinishedCompetitor.new(@relay.id, params[:string])) do
      @result = "korjaukset: #{"%+d" % @competitor.adjustment}"
    end
  end

  def estimate_penalties_adjustment
    @name = 'estimate_penalties_adjustment'
    do_quick_save(RelayQuickSave::EstimatePenaltiesAdjustment.new(@relay.id, params[:string])) do
      @result = "arviosakkojen korjaukset: #{"%+d" % @competitor.estimate_penalties_adjustment}"
    end
  end

  def shooting_penalties_adjustment
    @name = 'shooting_penalties_adjustment'
    do_quick_save(RelayQuickSave::ShootingPenaltiesAdjustment.new(@relay.id, params[:string])) do
      @result = "ammuntasakkojen korjaukset: #{"%+d" % @competitor.shooting_penalties_adjustment}"
    end
  end

  private

  def set_relay_quick_save
    @relay_quick_save = true
  end

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
