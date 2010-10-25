module SigSlot

    # Used to represent a signal
    class SignalDefinition
        attr_reader :name
        def initialize(name)
            @name = name
        end
        
        def ==(obj)
            SignalDefinition === obj && obj.name == @name
        end
    end

    # Used to represent a slot
    class SlotDefinition
        attr_reader :name
        def initialize(name)
            @name = name
        end

        def ==(obj)
            SlotDefinition === obj && obj.name == @name
        end
    end

end #SigSlot

require 'sigslot/robustness'
require 'sigslot/core'
require 'sigslot/exceptions'
require 'sigslot/object_helpers'
require 'sigslot/class_helpers'
require 'sigslot/rewriter'