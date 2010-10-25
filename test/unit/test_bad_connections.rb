require 'sigslot'
require 'test/unit/example_sig_slot_object'

module SigSlot
    
    module Tests
    
        class SigSlotBadConnectTest < Test::Unit::TestCase

            def testobj
                @test ||= SimpleSigSlotObject.new
            end
            
            def test_object_connect_raises_for_invalid_signals
                assert_raise ArgumentError do
                    testobj.connect "invalid", testobj.slot(:slot_0_params)
                end
                assert_raise SignalNotFound do
                    testobj.connect :invalid, testobj.slot(:slot_0_params)
                end
                assert_raise ArgumentError do
                    testobj.connect testobj.signal(:signal), testobj.slot(:slot_0_params)
                end
                assert_raise ArgumentError do
                    testobj.connect testobj.signal(:invalid), testobj.slot(:slot_0_params)
                end
                # :signal_emitted can't be connected as receiver
                assert_raise ArgumentError do
                    testobj.connect :signal_0_params, testobj.signal(:signal_emitted)
                end
                # :signal_emitted can't be connected to another signal of the same object (infinite loop)
                assert_raise InvalidSignalBinding do
                    testobj.connect :signal_emitted, testobj.signal(:signal_0_params)
                end
            end
        
            def test_sigslot_connect_raises_for_invalid_signals
                assert_raise ArgumentError do
                    SigSlot.connect "invalid", testobj.slot(:slot_0_params)
                end
                assert_raise ArgumentError do
                    SigSlot.connect :invalid, testobj.slot(:slot_0_params)
                end
                assert_raise SignalNotFound do
                    SigSlot.connect testobj.signal(:invalid), testobj.slot(:slot_0_params)
                end
                # :signal_emitted can't be connected as receiver
                assert_raise ArgumentError do
                    SigSlot.connect testobj.signal(:signal_0_params), testobj.signal(:signal_emitted)
                end
                # :signal_emitted can't be connected to another signal of the same object (infinite loop)
                assert_raise InvalidSignalBinding do
                    SigSlot.connect testobj.signal(:signal_emitted), testobj.signal(:signal_0_params)
                end
            end
        
            def test_object_connect_raises_for_invalid_slots
                assert_raise ArgumentError do
                    testobj.connect :signal_0_params, "slot"
                end
                assert_raise ArgumentError do
                    testobj.connect :signal_0_params, :slot_0_params
                end
                assert_raise SlotNotFound do
                    testobj.connect :signal_0_params, testobj.slot(:invalid)
                end
            end
        
            def test_sigslot_connect_raises_for_invalid_slots
                assert_raise ArgumentError do
                    SigSlot.connect testobj.signal(:signal_0_params), "slot"
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.slot(:signal_0_params), :slot_0_params
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.slot(:signal_0_params), testobj.slot(:invalid)
                end
            end
        
        end #SigSlotTestScenario

    end #Tests

end #SigSlot
