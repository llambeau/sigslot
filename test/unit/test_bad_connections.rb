require 'sigslot'

module SigSlot
    
    module Tests
    
        class SimpleSigSlotObject
            include SigSlot
            
            signal :signal
            slot :slot
            
            def slot 
            end
        end

        class SigSlotConnectTest < Test::Unit::TestCase

            def testobj
                @test ||= SimpleSigSlotObject.new
            end
            
            def test_object_connect_raises_for_invalid_signals
                assert_raise ArgumentError do
                    testobj.connect "invalid", testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    testobj.connect :invalid, testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    testobj.connect testobj.signal(:signal), testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    testobj.connect testobj.signal(:invalid), testobj.slot(:slot)
                end
            end
        
            def test_sigslot_connect_raises_for_invalid_signals
                assert_raise ArgumentError do
                    SigSlot.connect "invalid", testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    SigSlot.connect :invalid, testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.signal(:invalid), testobj.slot(:slot)
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.signal(:signal), testobj.signal(:signal_emitted)
                end
            end
        
            def test_object_connect_raises_for_invalid_slots
                assert_raise ArgumentError do
                    testobj.connect :signal, "slot"
                end
                assert_raise ArgumentError do
                    testobj.connect :signal, :slot
                end
                assert_raise ArgumentError do
                    testobj.connect :signal, testobj.slot(:invalid)
                end
            end
        
            def test_sigslot_connect_raises_for_invalid_slots
                assert_raise ArgumentError do
                    SigSlot.connect testobj.signal(:signal), "slot"
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.slot(:signal), :slot
                end
                assert_raise ArgumentError do
                    SigSlot.connect testobj.slot(:signal), testobj.slot(:invalid)
                end
            end
        
        end #SigSlotTestScenario

    end #Tests

end #SigSlot
