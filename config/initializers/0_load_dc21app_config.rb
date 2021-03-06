APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/dc21app_config.yml")[Rails.env]

if File.exists?("#{APP_CONFIG['extra_config_file_root']}/dc21app_extra_config.yml")
  extra_config = YAML.load_file("#{APP_CONFIG['extra_config_file_root']}/dc21app_extra_config.yml")[Rails.env]
  APP_CONFIG.merge!(extra_config)
else
  puts "#{APP_CONFIG['extra_config_file_root']}/dc21app_extra_config.yml doesn't exist yet. This is ok in a local dev environment but should not be the case in production".yellow
end

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144 # 4 times the default size
end