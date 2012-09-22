require 'test/unit'
require './lib/intrusion.rb'
require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.create_table :records do |t|
  t.string :name
  t.string :ids
  t.timestamps
end

class Record < ActiveRecord::Base
  include Intrusion
end


class IntrusionTest < ActiveSupport::TestCase #< Test::Unit::TestCase 
  
     
   test "new record should return empty array on load" do
     assert_equal(Array, Record.new.ids_load.class)
   end
   
   test "block object after 10 attempts" do
     record = Record.new
     object = "some ip"
     assert(record.ids_report!(object))
     assert(! record.ids_is_blocked?(object))
     
     8.times.each { assert(record.ids_report!(object)) }
     assert(! record.ids_is_blocked?(object))
     
     # 10th time: block
     assert(record.ids_report!(object))
     assert(record.ids_is_blocked?(object))
   end
   
   test "block immediately" do
     record = Record.new
     object = "some ip"
     assert(record.ids_report!(object, true))
     
     assert(record.ids_is_blocked?(object))
   end
   
   test "unblock" do
      record = Record.new
      object = "some ip"
      assert(record.ids_report!(object, true))
      
      assert(record.ids_unblock!(object))
      assert(! record.ids_is_blocked?(object))
    end
    
    test "counter working" do
      record = Record.new
      object = "some ip"
      
      assert_equal(0, record.ids_counter(object))
      
      assert(record.ids_report!(object))
      assert_equal(1, record.ids_counter(object))
      
      assert(record.ids_report!(object, true))
      assert_equal(10, record.ids_counter(object))
      
      assert(record.ids_unblock!(object))
      assert_equal(0, record.ids_counter(object))
      
    end
    
    test "reload" do
      record = Record.new
      object = "some ip"
      assert(record.ids_report!(object, true))
      
      record = Record.last
      assert_equal(10, record.ids_counter(object))
      
    end
    
  
    
 end