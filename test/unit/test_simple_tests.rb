module SigSlot

    module Tests

        class SimpleSigSlotTest
            include SigSlot

            # Some signals
            signal :signal_without_parameters
            signal :another_signal_without_parameters
            signal :signal_with_parameters, [:param1, :param2]
            signal :another_signal_with_parameters, [:param1, :param2]

            # Slots
            slot :slot_without_parameters, :slot_with_parameters, :slot_that_returns_first_parameter

            attr_reader :calls
            def initialize
                @calls = Hash.new{|h,k| h[k] = {:count => 0}}
            end

            # Some test slots
            def slot_without_parameters
                @calls[:slot_without_parameters][:count] += 1
                "slot_without_parameters"
            end

            def slot_with_parameters(param1, param2)
                @calls[:slot_with_parameters][:count] += 1
                @calls[:slot_with_parameters][:params] = [param1, param2]
                "slot_with_parameters(#{param1}, #{param2})"
            end

            def slot_that_returns_first_parameter(param1)
                @calls[:slot_that_returns_first_parameter][:count] += 1
                param1
            end

            def emit_signal(signal, *parameters)
                emit signal, *parameters
            end
        end

        class SigSlotTestScenario < Test::Unit::TestCase

            def test_instances_dont_share_connections
                test1 = SimpleSigSlotObject.new
                test2 = SimpleSigSlotObject.new
                assert_not_equal(test1.connections.object_id, test2.connections.object_id)
            end

            def test_slots_are_normal_methods
                test = SimpleSigSlotTest.new

                assert(test.respond_to?(:slot_without_parameters))
                assert(test.respond_to?(:slot_with_parameters))
                assert(test.respond_to?(:slot_that_returns_first_parameter))

                assert_equal("slot_without_parameters", test.slot_without_parameters)
                assert_equal("slot_with_parameters(1, 2)", test.slot_with_parameters(1,2))

                # Works also with objects
                assert_equal(test, test.slot_that_returns_first_parameter(test))
            end

            def test_slot_without_parameters_can_be_bound_to_signals_with_parameters
                test = SimpleSigSlotTest.new
                assert_nothing_raised do
                    test.connect :signal_with_parameters, test.slot(:slot_without_parameters)
                    test.emit_signal :signal_with_parameters, 1, 2
                end
            end

            def test_slot_with_parameters_cannot_be_bound_to_signals_without_parameters
                test = SimpleSigSlotTest.new
                assert_raise InvalidSignalBinding do
                    test.connect :signal_without_parameters, test.slot(:slot_with_parameters)
                    test.emit_signal :signal_without_parameters
                end
            end

            def test_signals_with_parameters_can_be_propagated_to_signals_without_parameters
                test = SimpleSigSlotTest.new
                assert_nothing_raised do
                    test.connect :signal_with_parameters, test.slot(:slot_without_parameters)
                    test.emit_signal :signal_with_parameters, 1, 2
                end
            end

            def test_signals_without_parameters_cannot_be_propagated_to_signals_with_parameters
                test = SimpleSigSlotTest.new
                assert_nothing_raised do
                    test.connect :signal_with_parameters, test.slot(:slot_without_parameters)
                    test.emit_signal :signal_with_parameters, 1, 2
                end
            end

            def test_connect_works_between_signals_and_slots
                test = SimpleSigSlotTest.new

                assert_nothing_raised do
                    # Connect ...
                    test.connect :signal_without_parameters, test.slot(:slot_without_parameters)
                    # ... and emit the signal
                    test.emit_signal :signal_without_parameters
                end
                assert_equal(1, test.calls.size)
                assert_equal(1, test.calls[:slot_without_parameters][:count])

                # And now with parameters
                assert_nothing_raised do
                    # Connect ...
                    test.connect :signal_with_parameters, test.slot(:slot_with_parameters)
                    # ... and emit the signal
                    test.emit_signal :signal_with_parameters, 1, 2
                end
                assert_equal(2, test.calls.size)
                assert_equal(1, test.calls[:slot_with_parameters][:count])
                assert_equal([1, 2], test.calls[:slot_with_parameters][:params])
            end

            def test_connect_works_between_signals_and_signals
                test = SimpleSigSlotTest.new

                assert_nothing_raised do
                    # Connect a signal to another signal
                    test.connect :signal_without_parameters, test.signal(:another_signal_without_parameters)
                    # Connect the second signal to a slot
                    test.connect :another_signal_without_parameters, test.slot(:slot_without_parameters)
                    # ... and emit the first signal
                    test.emit_signal :signal_without_parameters
                end
                assert_equal(1, test.calls.size)
                assert_equal(1, test.calls[:slot_without_parameters][:count])

                # And now with parameters
                assert_nothing_raised do
                    # Connect a signal to another signal
                    test.connect :signal_with_parameters, test.signal(:another_signal_with_parameters)
                    # Connect the second signal to a slot
                    test.connect :another_signal_with_parameters, test.slot(:slot_with_parameters)
                    # ... and emit the signal
                    test.emit_signal :signal_with_parameters, 1, 2
                end
                assert_equal(2, test.calls.size)
                assert_equal(1, test.calls[:slot_with_parameters][:count])
            end

            # Test the special signal :signal_emitted
            def test_signal_emitted
                test = SimpleSigSlotTest.new
                test2 = SimpleSigSlotTest.new

                # Assert it exists
                assert test.has_signal?(:signal_emitted)

                # Assert we can't use this signal as endpoint of a connection
                assert_raise ArgumentError do
                    test.connect :signal_without_parameters, test.signal(:signal_emitted)
                end

                # Assert we can observe all signal emitted by connecting something to :signal_emitted
                assert_nothing_raised do
                    test.connect :signal_emitted, test2.slot(:slot_without_parameters)
                end
                test.emit_signal(:signal_without_parameters)
                assert_equal(1, test2.calls[:slot_without_parameters][:count])

                # Assert signal_emitted pass correct arguments [:signal_name, :signal_parameters]
                assert_nothing_raised do
                    test.connect :signal_emitted, test2.slot(:slot_with_parameters)
                end
                test.emit_signal :signal_with_parameters, 1, 2
                assert_equal(2, test2.calls[:slot_without_parameters][:count])
                assert_equal(1, test2.calls[:slot_with_parameters][:count])
                assert_equal([:signal_with_parameters, [1,2]], test2.calls[:slot_with_parameters][:params])
            end

            # Test the special global signal :signal_emitted by SigSlot module
            def test_global_signal_emitted
                test = SimpleSigSlotTest.new

                assert_nothing_raised do
                    SigSlot.connect SignalDefinition.new(SigSlot, :signal_emitted), test.slot(:slot_with_parameters)
                end

                test.emit_signal :signal_without_parameters
                assert_equal([test, :signal_without_parameters], test.calls[:slot_with_parameters][:params])
            end

            # Test disonnections
            def test_disconnections
                test = SimpleSigSlotTest.new
                test2 = SimpleSigSlotTest.new

                # Test object.disconnect
                test.connect :signal_without_parameters, test.slot(:slot_without_parameters)
                test.disconnect :signal_without_parameters, test.slot(:slot_without_parameters)
                test.emit_signal :signal_without_parameters
                assert_equal(0, test.calls[:slot_without_parameters][:count])

                # Test object.disconnect to disconnect all connections for specific signal
                test.connect :signal_with_parameters, test.slot(:slot_with_parameters)
                test.connect :signal_with_parameters, test.slot(:slot_without_parameters)
                test.disconnect :signal_with_parameters
                test.emit_signal :signal_with_parameters, 1, 2
                test.calls.each_pair do |signal, infos|
                    assert_equal(0, infos[:count])
                end
            end

        end #SigSlotTestScenario

    end #Tests

end #SigSlot
