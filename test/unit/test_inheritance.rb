require 'sigslot'

module SigSlot

    module Tests

        class ParentClass
            include SigSlot
        end

        class ChildClass < ParentClass
            signal :my_signal
            slot :my_slot

            attr_reader :called
            def initialize
                @called = 0
            end

            def emit_my_signal
                emit :my_signal
            end

            def my_slot
                @called += 1
            end
        end

        class InheritanceTest < Test::Unit::TestCase

            def test_inheritance_works
                t = ChildClass.new
                t.connect :my_signal, t.slot(:my_slot)
                assert_equal(0, t.called)
                t.emit_my_signal
                assert_equal(1, t.called)
            end

        end #InheritanceTest

    end #Tests

end #SigSlot
