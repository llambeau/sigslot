require 'sigslot'

module SigSlot
    
    module Tests

		class Counter
			include SigSlot
			
			signal :value_changed, [:new_value, :old_value]
			slot :value=
			
			attr_reader :value
			def initialize
				@value = 2
			end
			
			def value=(value)
				if @value != value then
					oldvalue, @value = @value, value
					emit :value_changed, @value, oldvalue
				end
			end
		end
        
		class CounterExample < Test::Unit::TestCase
			
			include SigSlot
			
			slot :value_of_counter_changed
			
			def value_of_counter_changed(value)
				@value = value
			end
			
			def test_propagation_from_counter
				c = Counter.new
				c.connect :value_changed, self.slot(:value_of_counter_changed)
				c.value = 13
				assert_equal(13, @value)
			end
			
        end #CounterExample

    end #Tests

end #SigSlot
