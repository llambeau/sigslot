require 'sigslot'

module SigSlot
    
    module Tests

        class Baby
            include SigSlot

            signal :cry, [:baby]
            signal :burp
            
            attr_reader :hungry_count, :suckle_count
            
            def initialize()
                @hungry_count = 0
                @suckle_count = 0
            end

            def set_hungry
                @hungry_count += 1
                emit :cry, [self]
            end
            
            def suckle
                @suckle_count += 1
                emit :burp
            end
            
        end
        
        class Mom
            include SigSlot

            attr_reader :feed_count
            
            slot :feed_baby
            
            def initialize()
                @feed_count = 0
            end
            
            def gives_birth
                baby = Baby.new
                baby.connect(:cry, self.slot(:feed_baby))
                return baby
            end
    
            def feed_baby(baby)
                @feed_count += 1
                baby.suckle
            end
        end

        class SigSlotBabyAndMomTestScenario < Test::Unit::TestCase
        
            def test_scenario
                mom = Mom.new
                baby = mom.gives_birth
                
                assert_equal(0, mom.feed_count)
                assert_equal(0, baby.suckle_count)
                assert_equal(0, baby.hungry_count)
                
                baby.set_hungry

                assert_equal(1, mom.feed_count)
                assert_equal(1, baby.suckle_count)
                assert_equal(1, baby.hungry_count)

                baby.set_hungry

                assert_equal(2, mom.feed_count)
                assert_equal(2, baby.suckle_count)
                assert_equal(2, baby.hungry_count)
            end
        
        end #SigSlotBabyAndMomTestScenario

    end #Tests

end #SigSlot
