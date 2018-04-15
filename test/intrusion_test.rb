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
  end

  test 'new record should return empty array on load' do
    assert_equal Array, @record.ids_load.class
  end

  test 'block object after 10 attempts' do
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

  test 'load should rescue to array' do
    assert @record.update_attributes(ids: 'strange content')
    assert_equal Array, @record.ids_load.class
    assert_equal false, @record.ids_load.any?
  end

  test 'reload' do
    assert @record.ids_report!(@object, true)
    assert_equal 10, Record.last.ids_counter(@object)
  end
end
