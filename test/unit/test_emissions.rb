require 'sigslot'
require 'test/unit/example_sig_slot_object'

module SigSlot
    
    module Tests
    
        class SigSlotEmitTest < Test::Unit::TestCase
            
            include SigSlot
            
            signal :signal1
            signal :signal2, [:one]
            signal :signal3, [:one, :two]
			
            def test_emit_checks_signal_existence_and_parameters
				assert_raise SignalNotFound do 
                    emit :signal4
                end
                assert_raise InvalidSignalParameters do
                    emit :signal1, 1
                end
                assert_raise InvalidSignalParameters do
                    emit :signal2
                end
                assert_raise InvalidSignalParameters do
                    emit :signal2, 1, 2
                end
                assert_raise InvalidSignalParameters do
                    emit :signal3, 1
                end
				# Nothing raised for correct use
                assert_nothing_raised do 
                    emit :signal1
                    emit :signal2, 1
                    emit :signal3, 1, 2
                end
            end
            
        end #SigSlotTestScenario

    end #Tests

end #SigSlot
