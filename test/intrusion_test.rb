require 'test/unit'
require './lib/intrusion.rb'
require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.create_table :records do |t|
  t.string :ids
end

class Record < ActiveRecord::Base
  include Intrusion
end


class IntrusionTest < ActiveSupport::TestCase #< Test::Unit::TestCase 
  
   def setup
     @record = Record.new
     @object = "some ip"
   end  
     
   test "new record should return empty array on load" do
     assert_equal(Array, @record.ids_load.class)
   end
   
   test "block object after 10 attempts" do
     assert(@record.ids_report!(@object))
     assert(! @record.ids_is_blocked?(@object))
     
     8.times.each { assert(@record.ids_report!(@object)) }
     assert(! @record.ids_is_blocked?(@object))
     
     # 10th time: block
     assert(@record.ids_report!(@object))
     assert(@record.ids_is_blocked?(@object))
   end
   
   test "block immediately" do
     assert(@record.ids_report!(@object, true))     
     assert(@record.ids_is_blocked?(@object))
   end
   
   test "unblock" do
      assert(@record.ids_report!(@object, true))
      
      assert(@record.ids_unblock!(@object))
      assert(! @record.ids_is_blocked?(@object))
    end
    
    test "counter working" do
      assert_equal(0, @record.ids_counter(@object))
      
      assert(@record.ids_report!(@object))
      assert_equal(1, @record.ids_counter(@object))
      
      assert(@record.ids_report!(@object, true))
      assert_equal(10, @record.ids_counter(@object))
      
      assert(@record.ids_unblock!(@object))
      assert_equal(0, @record.ids_counter(@object))
      
    end
    
    test "reload" do
      assert(@record.ids_report!(@object, true))
      assert_equal(10, Record.last.ids_counter(@object))
    end
        
 end