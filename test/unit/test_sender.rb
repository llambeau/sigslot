require 'sigslot'
require 'test/unit/example_sig_slot_object'

module SigSlot
    
    module Tests
    
		class SenderCatcher
			attr_reader :my_sender
			include SigSlot

			signal :signal_connected_to_catch_sender
			slot :catch_sender
			
			def initialize
				connect :signal_connected_to_catch_sender, slot(:catch_sender)
			end
			
			def catch_sender()
				@my_sender = SigSlot.sender.object
			end
		end
	
        class SigSlotEmitTest < Test::Unit::TestCase
            
            include SigSlot
            
            signal :signal1
			
            def test_sender_in_direct_connection
				
				catch = SenderCatcher.new
				connect :signal1, catch.slot(:catch_sender)
				
				emit :signal1
				assert_equal self, catch.my_sender
            end
            
            def test_sender_in_cascade
				
				catch = SenderCatcher.new
				connect :signal1, catch.signal(:signal_connected_to_catch_sender)
				
				emit :signal1
				assert_equal catch, catch.my_sender
            end
            
        end #SigSlotTestScenario

    end #Tests

end #SigSlot