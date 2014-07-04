include Chef::Cookbook::RVM::EnvironmentFactory
use_inline_resources

def whyrun_supported?
  true
end
[:create, :delete, :update, :pristine, :prune].each do |action_name|
  action action_name do
    raise "Cant #{action_name} for gemset #{new_resource._gemset} because ruby #{new_resource._version} is not installed by user #{new_resource.user}" if action_name != :create && env.use(new_resource._version)

    if action_name == :create && env.gemset_list.include?(new_resource._gemset)
      Chef::Log.debug("Skip action #{action_name} for gemset #{new_resource._gemset} because gemset exist")
      next
    end

    unless action_name == :create || env.gemset_list.include?(new_resource._gemset)
      Chef::Log.debug("Skip action #{action_name} for gemset #{new_resource._gemset} because gemset does not exist")
      next
    end

    converge_by "#{action_name.to_s.capitalize} gemset #{new_resource._gemset}." do
      new_resource.updated_by_last_action(env.send("gemset_#{action_name}".to_sym, new_resource._gemset))
    end
  end
end