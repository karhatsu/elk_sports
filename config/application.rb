require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(:default, :assets, Rails.env)
end

ADMIN_EMAIL = ["com", ".", "karhatsu", "@", "henri"].reverse.join('')

TEST_HOST = "testi.hirviurheilu.com"
TEST_URL = "http://" + TEST_HOST

PRODUCTION_HOST = "www.hirviurheilu.com"
PRODUCTION_URL = "http://" + PRODUCTION_HOST

NATIONAL_RECORD_URL = "http://www.metsastajaliitto.fi/node/35"
YOUTUBE_URL = 'http://www.youtube.com/watch?v=oRNIy1G4qWM'

VAT = 24

OSX_PLATFORM = (RUBY_PLATFORM =~ /darwin/)
WINDOWS_PLATFORM = (RUBY_PLATFORM =~ /mswin|mingw/)

module ElkSports
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Helsinki'

    config.i18n.enforce_available_locales = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:fi, :sv]
    config.i18n.default_locale = :fi

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.1'

    config.assets.precompile += ['pdf.css', 'mobile.css', 'messages.css', 'mobile.js', 'social.js']

    config.assets.initialize_on_precompile = false

    config.generators do |g|
      g.test_framework :rspec
    end

    module ServerStartInfo
      def self.call
        puts ''
        puts 'HIRVIURHEILU OFFLINE ON NYT VALMIS KAYTETTAVAKSI'
        puts 'Jos palomuurisi kysyy erillista lupaa ohjelman kayttoon, salli kaytto.'
        puts ''
        puts 'AVATAAN OHJELMAN ALOITUSSIVU...'
        system('start http://localhost:3000')
      end
    end

    module ServerStopInfo
      def self.call
        puts ''
        puts 'SULJETAAN HIRVIURHEILU OFFLINE, ODOTA HETKI...'
      end
    end
  end
end
