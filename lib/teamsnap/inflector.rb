require "dry/inflector"

module TeamSnap
  Inflector = Dry::Inflector.new do |inflections|
    inflections.plural "broadcast_sms", "broadcast_smses"
    inflections.plural "division_member_preferences", "division_members_preferences"
    inflections.plural "division_preferences", "divisions_preferences"
    inflections.plural "member_preferences", "member_preferences"
    inflections.plural "member_preferences", "members_preferences"
    inflections.plural "opponent_results", "opponent_results"
    inflections.plural "opponent_results", "opponents_results"
    inflections.plural "team_preferences", "team_preferences"
    inflections.plural "team_preferences", "teams_preferences"
    inflections.plural "team_results", "team_results"
    inflections.plural "team_results", "teams_results"
    inflections.plural "partner_preferences", "partner_preferences"
    inflections.plural "partner_preferences", "partners_preferences"
  end
end
