module MissionsHelper
  def missions_index_links(missions)
    [can?(:create, Mission) ? link_to("Add new Mission", new_mission_path) : nil]
  end
  
  def missions_index_fields
    %w[name created actions]
  end
  
  def format_missions_field(mission, field)
    case field
    when "created"
      mission.created_at.to_s(:std_date)
    when "actions"
      action_links(mission, :exclude => [:show], :destroy_warning => "Are you sure you want to delete Mission '#{mission.name}'?")
    else mission.send(field)
    end
  end
end
