require 'sigslot'
require 'test/unit/example_sig_slot_object'

module SigSlot
    
    module Tests
    
        class SigSlotCorrectConnectTest < Test::Unit::TestCase

            def testobj
                @test ||= SimpleSigSlotObject.new
            end
            
            def test_object_connect
                testobj.connect :signal_0_params, testobj.slot(:slot_0_params)
                testobj.connect :signal_emitted, SimpleSigSlotObject.new.slot(:slot_0_params)
            end
        
            def test_sigslot_connect
            end

        end #SigSlotTestScenario

    end #Tests

end #SigSlot
