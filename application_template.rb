# gems
# ==================================================
run "echo Added gem file"

if yes?("Whould you like to use carrierwave ?")
  gem 'carrierwave'
  gem 'rmagick', :require => false
end

gem 'settingslogic'

if yes?('Would you like to use nokogiri?')
  gem 'nokogiri'
end

if yes?('Would you like to use cron?')
  gem 'whenever'
  run "bundle exec wheneverize"
end

if yes?("This app will be following up on both the smartphone and PC?")
  gem 'jpmobile'
end

gem_group :development do
  gem "rspec-rails"
  gem "rails-erd"
end

gem_group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end

# Install spec_helper.rb
# ==================================================
run "./bin/rails g rspec:install"
run "rm -rf test"

# Setup settingslogic config
# ==================================================
run "cat << EOF >> config/settings.yml
defaults: &defaults

development:
  <<: *defaults
  neat_setting: 800

test:
  <<: *defaults

production:
  <<: *defaults
EOF"

run "cat << EOF >> config/initializers/settings.rb
class Settings < Settingslogic
  source \"\#{Rails.root\}/config/settings.yml\"
  namespace Rails.env
end
EOF"

# DB config
# ==================================================
run "cp config/database.yml config/database.yml.sample"

# Seeting seed
# ==================================================
run "ehco db/seeds.rb"

run "mkdir -p db/seeds/production"
run "mkdir -p db/seeds/development"
run "mkdir -p db/seeds/test"

run "cat << EOF > db/seeds.rb
table_names = %w()

table_names.each do |table_name|
  p table_name
  path = \"\#{Rails.root\}/db/seeds/\#{Rails.env\}/\#{table_name\}.rb\"
  require(path) if File.exist?(path)
end
EOF"


if yes?('Do you want to upload to Amazon S3 in the file?')
  gem 'fog'

  # Setting carrierwave using fog
  # ==================================================
  run "echo Set carrierwave config"

  run "cat << EOF >> config/initializers/carrierwave.rb
if Rails.env.production? || Rails.env.staging?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      :provider              => 'AWS',
      :aws_access_key_id     => Settings.aws.access_key,
      :aws_secret_access_key => Settings.aws.secret_key,
      :region                => 'ap-northeast-1',
    }
    config.fog_directory = Settings.aws.resource.bucket
    config.asset_host = Settings.aws.resource.host
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.asset_host = Settings.host
  end
end
EOF"

end

# Set .gitignore
# ==================================================
run "ehco Set .gitignore"
run "cat << EOF >> .gitignore
config/database.yml
db/schema.rb
vendor/bundle
tmp
coverage
EOF"

# bundle install
# ==================================================
run "./bin/bundle install"

# First Commit
# ==================================================

git :init
git add: "."
git commit: %Q{ -m 'first commit' }
