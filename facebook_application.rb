# gems
# ==================================================
run "echo Added gem file"

gem 'carrierwave'
gem 'koala'
gem 'settingslogic'

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

# Added settings for koala
# ===================================================
run "cat << EOF >> config/sns.yml.sample
production:
  facebook:
    app_id: <APP ID>
    app_secret: <APP SECRET>
    callback: <APP CALLBACK>
development:
  facebook:
    app_id: <APP ID>
    app_secret: <APP SECRET>
    callback: <APP CALLBACK>
test:
  facebook:
    app_id: <APP ID>
    app_secret: <APP SECRET>
    callback: <APP CALLBACK>
EOF"

run "cat << EOF >> config/initializers/koala.rb
module Facebook
  CONFIG = YAML.load_file(Rails.root.to_s + \"/config/sns.yml\")[Rails.env]['facebook']

  APP_ID     = CONFIG[\"app_id\"]
  APP_SECRET = CONFIG[\"app_secret\"]
  CALLBACK   = CONFIG[\"callback\"]
end
EOF"

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
