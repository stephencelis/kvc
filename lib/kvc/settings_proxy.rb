# The KVC::SettingsProxy proxies to a KVC::Settings object's value. The proxy
# ensures that when a value is modified, the Settings object is immediately
# updated in the database.
#
# These proxies also provide access to the Settings object's timestamp
# attributes.
class KVC::SettingsProxy
  undef_method *instance_methods.grep(/^(?!__|nil\?|send)/)

  attr_reader :setting

  def initialize(setting)
    @setting = setting
  end

  private

  def method_missing(method, *args, &block)
    return setting.send(method) if [:created_at, :updated_at].include? method

    return_value = setting.value.send(method, *args, &block)
    stored_value = KVC::Settings.deserialize YAML.load(setting[:value])

    if setting.value != stored_value
      setting.update_attribute :value, setting.value
      return self # Allow for chaining.
    end

    return_value
  end
end
