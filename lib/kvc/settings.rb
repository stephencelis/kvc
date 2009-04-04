# KVC::Settings is a model rarely accessed like other Active Record models.
# You can still fetch records from the database as in other models, but you
# will more likely read and write records through the KVC namespace directly:
#
#   KVC.key = "value"
#   # Creates #<KVC::Settings id: 1, key: "key", value: "---\n\"value\"">
#   # Values are serialized to accommodate complex object storage.
#
#   KVC.key # => "value"
#   # Fetches #<KVC::Settings id: 1, key: "key", value: "---\n\"value\"">
class KVC::Settings < ActiveRecord::Base
  # Do not raise exceptions on keys that don't exist.
  @@strict_keys = false
  cattr_accessor :strict_keys

  @@validations = HashWithIndifferentAccess.new []
  cattr_reader :validations
  class << self
    alias strict_keys? strict_keys

    # Config takes a block for configuration. For now, this provides
    # rudimentary validation. E.g.:
    #
    #   KVC::Settings.config do
    #     validates("username") { |value| value.is_a? String }
    #     validates("username") { |value| (2..16).include? value.to_s.length }
    #   end
    def config(&block)
      Object.new.instance_eval do
        def validates(*args, &proc)
          @@validations[args] << proc
        end
        self
      end.instance_eval(&block)
    end
  end

  # Active Record does not automatically namespace tables.
  set_table_name :kvc_settings

  # Validate in case the unique index isn't enough.
  validates_uniqueness_of :key

  # Deserializes value from database.
  def value
    @value ||= YAML.load(read_attribute(:value))
  end

  # Serializes value for database.
  def value=(input)
    returning @value = input do
      write_attribute :value, input.to_yaml
    end
  end

  private

  def validate
    unless @@validations[key].map { |validation| validation.call(value) }.all?
      errors.add_to_base "#{key} cannot be set to #{value}"
    end
  end

  if !table_exists?
    ActiveRecord::Schema.define do
      create_table :kvc_settings do |t|
        t.string :key
        t.text :value

        t.timestamps
      end

      add_index :kvc_settings, :key, :unique => true
    end
  end
end
