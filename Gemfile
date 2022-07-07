source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'rails', '7.0.3'
gem 'puma', '~> 5.0'
gem 'bootsnap', require: false
gem 'faraday', '2.3'
gem 'telegram-bot', '0.15.6'
gem 'nokogiri', '~> 1.13', '>= 1.13.6'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "byebug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end