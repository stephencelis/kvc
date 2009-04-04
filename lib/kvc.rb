# KVC (Key-Value Configuration) provides a powerful, transparent way to
# maintain mutable app settings in the database.
#
#   KVC.key = "value" # Saves key-value pairing to a database record.
#   KVC.key           # Retrieves the record and returns the "value".
#
# Use the index syntax to avoid conflicts with Module methods:
#
#   KVC.name = "Ruby Inside"
#   KVC.name    # => "KVC" (Whoops.)
#   KVC["name"] # => "Ruby Inside"
#
# Or set boolean methods (values are serialized, so booleans are fair game):
#
#   KVC["display_warning?"] = true
#   KVC.display_warning? # => true
#
# Or get creative:
#
#   KVC["Chad's expensive guitar"] = Fender::Stratocaster.new(1957)
# 
# By default, nonexistent keys return +nil+ values, but you can be stricter if
# you want to avoid typo-based bugs:
#
#   KVC.a_typo_could_occur?            # => nil
#   KVC::Settings.strict_keys = true   #
#   KVC.a_typo_could_occur?            # Raises NoMethodError.
#
# If you really need validations, define them in an initializer. E.g.:
#
#   # config/initializers/kvc_config.rb
#   KVC::Settings.config do
#     validates("password") { |value| value =~ /\d+/ }
#   end
#
# Failed validations will raise <tt>ActiveRecord::RecordInvalid</tt>.
module KVC
  VERSION = "0.0.2"

  class << self
    private

    # Handles the key-value magic.
    def method_missing(method, *args, &block)
      key = method.to_s
      key.sub!(/^\[\](=?)$/) { "#{args.shift}#{$1}" }
    
      if key.sub!(/=$/) {} # Is it a writer method?
        returning args.shift do |value|
          setting = KVC::Settings.find_or_initialize_by_key(key)
          setting.update_attributes!(:value => value)
        end
      elsif setting = KVC::Settings.find_by_key(key) # Is it a reader?
        if args.present?
          error_message = "wrong number of arguments (#{args.length} for 0)"
          raise ArgumentError, error_message
        end
    
        KVC::SettingsProxy.new(setting)
      elsif args.present? || KVC::Settings.strict_keys?
        raise NoMethodError
      end
    end
  end
end
