class Official::RelayTeamsController < Official::OfficialController
  before_action :assign_relay_by_relay_id, :check_assigned_relay, :set_relays
end
