# config/initializers/rabl.rb

Rabl.configure do |config|
  # Include JSON root keys by default
  config.include_json_root = false
  
  # Include child root in JSON responses
  config.include_child_root = false
  
  # Exclude nil values from responses
  config.exclude_nil_values = false
  
  # Enable PrettyJSON
  config.enable_json_callbacks = false
  
  # Cache all output using cache_key on the object
  config.cache_all_output = false
  
  # Cache individual sources using cache_key
  config.cache_sources = Rails.env.production?
  
  # Escape HTML output
  config.escape_all_output = false
  
  # Set default view path
  config.view_paths = [Rails.root.join('app', 'views')]
  
  # Raise on missing attributes - IMPORTANT for debugging NoMethodError
  # Set to false in production to prevent errors from breaking API
  config.raise_on_missing_attribute = Rails.env.development? || Rails.env.test?
  
  # Replace nil values with empty strings
  config.replace_nil_values_with_empty_strings = false
  
  # Replace empty string values with nil
  config.replace_empty_string_values_with_nil_values = false
  
  # Exclude empty values in JSON output
  config.exclude_empty_values_in_collections = false
  
  # Use ISO8601 format for Time and DateTime
  #config.use_custom_responder = false
end

# Custom helper to safely access nested attributes
module RablHelper
  def safe_call(object, *methods)
    methods.inject(object) do |obj, method|
      obj.respond_to?(method) ? obj.send(method) : nil
    end
  end
end

Rabl::Engine.send(:include, RablHelper)