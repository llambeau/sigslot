require 'sigslot'

module SigSlot

    module Tests

        class LCDInteger
            include SigSlot

            attr_reader :value
            slot :set_value, :increment, :decrement

            def initialize
                @value = 0
            end

            def set_value(value)
                @value = value
            end

            def increment
                @value += 1
            end

            def decrement
                @value = @value - 1
            end

        end

        class RangeControl
            include SigSlot

            signal :plus_clicked
            signal :minus_clicked

            def plus
                emit :plus_clicked
            end

            def minus
                emit :minus_clicked
            end
        end

        class SigSlotGUIScenario < Test::Unit::TestCase

            def test_scenario
                lcd = LCDInteger.new
                control = RangeControl.new

                assert_equal(0, lcd.value)
                control.plus
                assert_equal(0, lcd.value)

                control.connect :plus_clicked, lcd.slot(:increment)
                control.connect :minus_clicked, lcd.slot(:decrement)

                assert_equal(0, lcd.value)
                control.plus
                assert_equal(1, lcd.value)
                control.plus
                assert_equal(2, lcd.value)
                control.minus
                assert_equal(1, lcd.value)
                control.minus
                assert_equal(0, lcd.value)
            end

            def test_rewriting
                lcd = LCDInteger.new
                control = RangeControl.new

                SigSlot.connect_and_rewrite(control.signal(:plus_clicked), lcd.slot(:set_value)) { |params|
                    [20]
                }
                assert_equal(0, lcd.value)
                control.plus
                assert_equal(20, lcd.value)
            end

        end #SigSlotTestScenario

    end #Tests

end #SigSlot
