require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_support'
require 'active_support/test_case'
ActiveRecord::Migration.verbose = false

$: << File.expand_path(File.dirname(__FILE__) + "/../lib") <<
      File.expand_path(File.dirname(__FILE__) + "/../app/models")

ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
                                        :database => ':memory:'

ActiveRecord::Schema.define(:version => 1) do
  create_table :guitars do |t|
    t.string :make, :model
    t.timestamps
  end

  create_table :keyboards do |t|
    t.string :make, :model
    t.timestamps
  end
end

require "kvc"
require "kvc/settings"
require "kvc/settings_proxy"

logger = Logger.new(STDOUT)

class Guitar < ActiveRecord::Base
end

class Keyboard < ActiveRecord::Base
  validates_presence_of :make
end

class KVCTest < ActiveSupport::TestCase
  teardown do
    KVC::Settings.destroy_all
  end

  test "KVC::Settings table should exist" do
    assert KVC::Settings.table_exists?
  end

  test "method_missing should re-raise if there are arguments" do
    assert_raise ArgumentError do
      KVC.this_should("not_work")
    end
  end

  test "fake attributes should return nil if we're not being strict" do
    assert_nil KVC.nonexistent_key
  end

  test "fake attributes should raise exception if we're being strict" do
    begin
      assert_equal false, KVC::Settings.strict_keys? # Avoid nil-check.
      KVC::Settings.strict_keys = true
      assert KVC::Settings.strict_keys?
      assert_raise(NoMethodError) { KVC.nonexistent_key }
    ensure
      KVC::Settings.strict_keys = false
    end
  end

  test "can set attributes" do
    assert_difference "KVC::Settings.count" do
      assert_nil KVC.favorite_food
      assert_equal "popsicles", KVC.favorite_food = "popsicles"
      assert_equal "popsicles", KVC.favorite_food
    end
  end

  test "attributes should update if the changed" do
    KVC.mutable_array = []
    KVC.mutable_array << 1
    assert_equal [1], KVC::Settings.find_by_key("mutable_array").value

    KVC.mutable_string = ""
    KVC.mutable_string << "change"
    assert_equal "change", KVC::Settings.find_by_key("mutable_string").value
    KVC.mutable_string.sub!(/ch/) { "r" }
    assert_equal "range", KVC::Settings.find_by_key("mutable_string").value
  end

  test "attribute changes should chain" do
    KVC.mutable_array = [1, 2, 3]
    (KVC.mutable_array << 4).shift
    assert_equal [2, 3, 4], KVC.mutable_array
  end

  test "attributes should serialize and deserialize" do
    type = KVC::Settings.columns.find { |column| column.name == "key" }.type
    assert_equal :string, type

    KVC.favorite_year = 1984
    assert_kind_of Integer, KVC.favorite_year
  end

  test "models should serialize and deserialize updated versions" do
    instruments = {
      :guitars => {
        :favorites => [
          Guitar.create(:make => "Gibson", :model => "Melody Maker"),
          Guitar.create(:make => "Epiphone", :model => "Les Paul"),
        ],
        :not_so_good => [
          Guitar.create(:make => "Samick")
        ]
      },
      :keyboard => Keyboard.create(:make => "Yamaha")
    }

    KVC.instruments = Marshal.load Marshal.dump(instruments) # Deep copy.
    instruments[:keyboard].update_attribute(:model, "Privia PX-130")

    assert_equal instruments, KVC.instruments
    assert_equal instruments[:keyboard].model, KVC.instruments[:keyboard].model
  end

  test "should not reload records if record reloading is off" do
    begin
      KVC::Settings.reload_records = false
      KVC.guitar = Guitar.create(:make => "Yamaha")
      guitar = Guitar.last
      guitar.update_attribute :make, "Yamahahaha"
      assert_not_equal guitar.make, KVC.guitar.make
    ensure
      KVC::Settings.reload_records = true
    end
  end

  test "unsaved models should deserialize" do
    keyboard = Keyboard.new :model => "Some kind of synthesizer."
    assert_nil keyboard.id
    KVC["Which make was it again?"] = keyboard.clone # Unsaved copy.
    assert_equal keyboard, KVC["Which make was it again?"]
  end

  test "missing models should raise exceptions" do
    guitar = Guitar.create
    KVC.ghost_guitar = guitar
    guitar.destroy
    assert_raise ActiveRecord::RecordNotFound do
      KVC.ghost_guitar.touch
    end
  end

  test "can set attributes with whitespace and symbols" do
    assert KVC["uses_git?"] = true
    assert KVC.uses_git?

    assert KVC["Nonstandard, but a fine time :)"] = Time.now
    assert_instance_of Time, KVC["Nonstandard, but a fine time :)"]
  end

  test "should have access to created_at and updated_at via proxy" do
    KVC.apples = [:braeburn, :granny_smith, :fuji, :macintosh]
    apples = KVC.apples
    assert_instance_of Time, apples.created_at
    assert_equal apples.created_at, apples.updated_at
  end

  test "brackets and equals should not necessarily clash" do
    KVC["[]=''"] = "upside-down cookie monster"
    assert_equal "upside-down cookie monster", KVC["[]=''"]
  end

  test "cannot create duplicate attributes" do
    KVC.unique = true
    assert_no_difference "KVC::Settings.count" do
      KVC::Settings.create :key => "unique", :value => true

      assert_raise ActiveRecord::StatementInvalid do
        try_again = KVC::Settings.new :key => "unique", :value => true
        try_again.save_without_validation
      end
    end
  end

  test "validations should raise exceptions when invalid" do
    begin
      KVC::Settings.config do
        validates("password") { |value| value =~ /\d+/ }
      end
      assert_raise ActiveRecord::RecordInvalid do
        KVC.password = "password"
      end
      assert_nothing_raised do
        KVC.password = "password1"
      end
    ensure
      KVC::Settings.validations["password"] = []
    end
  end
end
