# require 'test/unit'
require 'minitest/autorun'
require './lib/intrusion.rb'
require 'active_record'
require 'byebug'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  create_table :records do |table|
    table.column :ids, :string
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Record < ApplicationRecord
  include Intrusion
end

class IntrusionTest < ActiveSupport::TestCase
  def setup
    @record = Record.new
    @object = 'some ip'
    @tmpfile = 'test.tmp.yml'
  end

  def teardown
    Intrusion.reset
    File.delete(@tmpfile) if File.exist?(@tmpfile)
  end

  test 'new record should return empty array on load' do
    assert_equal '', Intrusion.config.file
    assert_equal Array, @record.ids_load.class

    # test file mode with nonexisting file
    assert_equal false, File.exist?(@tmpfile)
    Intrusion.configure do |config|
      config.file = @tmpfile
    end
    assert_equal Array, @record.ids_load.class
  end

  test 'block object after 10 attempts by default' do
    assert @record.ids_report!(@object)
    assert_equal false, @record.ids_is_blocked?(@object)

    8.times.each { assert(@record.ids_report!(@object)) }
    assert_equal false, @record.ids_is_blocked?(@object)

    # 10th time should block
    assert @record.ids_report!(@object)
    assert @record.ids_is_blocked?(@object)
  end

  test 'block immediately' do
    assert @record.ids.nil?
    assert @record.ids_report!(@object, true)
    assert @record.ids.is_a?(String)
    assert @record.ids_is_blocked?(@object)
  end

  test 'unblock' do
    assert @record.ids_report!(@object, true)
    assert @record.ids_is_blocked?(@object)

    assert @record.ids_unblock!(@object)
    assert_equal false, @record.ids_is_blocked?(@object)
  end

  test 'counter working' do
    assert_equal 0, @record.ids_counter(@object)

    assert @record.ids_report!(@object)
    assert_equal 1, @record.ids_counter(@object)

    assert @record.ids_report!(@object, true)
    assert_equal 10, @record.ids_counter(@object)

    assert @record.ids_unblock!(@object)
    assert_equal 0, @record.ids_counter(@object)
  end

  test 'configurable counter working' do
    Intrusion.configure do |config|
      config.threshold = 2
    end
    assert_equal 0, @record.ids_counter(@object)

    assert @record.ids_report!(@object, true)
    assert_equal 2, @record.ids_counter(@object)

    assert @record.ids_unblock!(@object)
    assert_equal 0, @record.ids_counter(@object)
  end

  test 'load should rescue to array' do
    assert @record.update(ids: 'strange content')
    assert_equal Array, @record.ids_load.class
    assert_equal false, @record.ids_load.any?
  end

  test 'reload' do
    assert @record.ids_report!(@object, true)
    assert_equal 10, Record.last.ids_counter(@object)
  end

  test 'configure block' do
    Intrusion.configure do |config|
      config.file = @tmpfile
      config.threshold = 2
    end

    assert_equal @tmpfile, Intrusion.config.file
    assert_equal 2, Intrusion.config.threshold

    assert_equal @tmpfile, Intrusion.config[:file]
    assert_equal 2, Intrusion.config[:threshold]
  end

  test 'set_not_exists_attribute' do
    assert_raises NoMethodError do
      Intrusion.configure do |config|
        config.unknown_attribute = 'some value'
      end
    end
  end

  test 'get_not_exists_attribute' do
    assert_raises NoMethodError do
      Intrusion.config.unknown_attribute
    end
  end

  test 'default config values' do
    assert_equal 10, Intrusion.config.threshold
    assert_equal '', Intrusion.config.file
  end

  test 'partial configure' do
    threshold = rand(1..100)
    Intrusion.configure do |config|
      config.threshold = threshold
    end

    assert_equal threshold, Intrusion.config.threshold
    assert_equal '', Intrusion.config.file
  end

  test 'file mode write and read' do
    threshold = 5
    Intrusion.configure do |config|
      config.file = @tmpfile
      config.threshold = threshold
    end
    assert_equal 0, @record.ids_counter(@object)
    assert @record.ids_report!(@object, true)
    assert_equal threshold, @record.ids_counter(@object)
  end

  test 'file mode without a model' do
    class MyGlobalIDS
      include Intrusion
      Intrusion.configure do |config|
        config.file = 'test.tmp.yml'
        config.threshold = 6
      end
    end

    global = MyGlobalIDS.new

    
    assert_equal 0,  global.ids_counter(@object)

    assert global.ids_report!(@object, true)
    global = MyGlobalIDS.new

    assert_equal 6, global.ids_counter(@object)
  end

end
