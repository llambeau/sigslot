require 'sigslot'

module SigSlot

    module Tests
        
        # DSL Class used to parse LTS definitions
        class LTSVariableDSL
            attr_reader :definition
            
            def initialize
                @definition = Hash.new { |hash,key| hash[key] = {} }
            end
            
            def state(string, hash)
                @definition[string].merge!(hash)
            end
            
        end
        
        # LTS Variable
        class LTSVariable
            def initialize(&block)
                dsl = LTSVariableDSL.new
                dsl.instance_eval(&block)
                @definition = dsl.definition
            end
        end #LTSVariable
        
        # Tests the lts variable mechanisms
        class TestLTSVariable < Test::Unit::TestCase

            def test_simple_initialization
                assert_nothing_raised do
                    LTSVariable.new {
                        state '*', {
                            '/admin/login:logged' => 'value'
                        }
                    }
                end
            end

        end
        
    end #Tests

end #SigSlot
