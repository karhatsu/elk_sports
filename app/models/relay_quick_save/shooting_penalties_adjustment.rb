class RelayQuickSave::ShootingPenaltiesAdjustment < RelayQuickSave::RelayQuickSaveBase
  def initialize(relay_id, string)
    super(relay_id, string, /^(\+\+)?\d+,\d+,(\+|-|)\d+$/)
  end

  private
  def competitor_has_attrs?
    !@competitor.shooting_penalties_adjustment.nil?
  end

  def set_competitor_attrs
    @competitor.shooting_penalties_adjustment = @string.split(',')[2]
  end
end
