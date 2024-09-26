require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ImageProcessor
  class Application < Rails::Application
    config.load_defaults 7.1

    config.eager_load_paths << Rails.root.join('app/consumers')

    config.autoload_lib(ignore: %w(assets tasks))

    config.api_only = true
  end
end
