require 'test/unit'
require 'test/unit/example_sig_slot_object'

module SigSlot

    module Tests

        class RewriteTestScenario < Test::Unit::TestCase

            def obj
                @obj ||= SimpleSigSlotObject.new
            end

            def test_rewrite_as_simple_propagator
                SigSlot.connect_and_rewrite(obj.signal(:signal_1_param), obj.slot(:slot_1_param)) { |params|
                    params
                }
                obj.emit :signal_1_param, "hi!"
                assert_equal 1, obj.calls[:slot_1_param][:count]
                assert_equal ["hi!"], obj.calls[:slot_1_param][:last_params]
            end

            def test_simple_rewrite
                SigSlot.connect_and_rewrite(obj.signal(:signal_1_param), obj.slot(:slot_1_param)) { |params|
                    ["Hello #{params[0]}!"]
                }
                obj.emit :signal_1_param, "World"
                assert_equal 1, obj.calls[:slot_1_param][:count]
                assert_equal ["Hello World!"], obj.calls[:slot_1_param][:last_params]
            end

            def test_rewrite_works_for_source_signals_without_parameters
                SigSlot.connect_and_rewrite(obj.signal(:signal_0_params), obj.slot(:slot_1_param)) { |params|
                    ["Hello !"]
                }
                obj.emit :signal_0_params
                assert_equal 1, obj.calls[:slot_1_param][:count]
                assert_equal ["Hello !"], obj.calls[:slot_1_param][:last_params]
            end

            def emit_in_a_different_scope(object)
                object.emit :signal_0_params
            end

            def test_rewrite_block_scope
                values = ["My Value"]
                SigSlot.connect_and_rewrite(obj.signal(:signal_0_params), obj.slot(:slot_1_param)) { |params|
                    values[0]
                }
                obj.emit :signal_0_params
                assert_equal 1, obj.calls[:slot_1_param][:count]
                assert_equal ["My Value"], obj.calls[:slot_1_param][:last_params]
                emit_in_a_different_scope(obj)
                assert_equal 2, obj.calls[:slot_1_param][:count]
                assert_equal ["My Value"], obj.calls[:slot_1_param][:last_params]
            end

            def bind_in_a_different_scope(object)
                values = ["My Value"]
                SigSlot.connect_and_rewrite(object.signal(:signal_0_params), object.slot(:slot_1_param)) { |params|
                    values[0]
                }
            end

            def test_rewrite_block_scope2
                bind_in_a_different_scope(obj)

                obj.emit :signal_0_params
                assert_equal 1, obj.calls[:slot_1_param][:count]
                assert_equal ["My Value"], obj.calls[:slot_1_param][:last_params]
            end

        end #SigSlotTestScenario

    end #Tests

end #SigSlot
