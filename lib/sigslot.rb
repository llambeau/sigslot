module SigSlot

    VERSION = "0.0.1".freeze

    # Used to represent a signal
    class SignalDefinition
        attr_reader :name, :object
        def initialize(object, name)
            @object, @name = object, name
        end

        def ==(obj)
            SignalDefinition === obj &&
                obj.name == @name &&
                obj.object == @object
        end
    end

    # Used to represent a slot
    class SlotDefinition
        attr_reader :name, :object
        def initialize(object, name)
            @object, @name = object, name
        end

        def ==(obj)
            SlotDefinition === obj &&
                obj.name == @name &&
                obj.object == @object
        end
    end

end #SigSlot

require 'sigslot/robustness'
require 'sigslot/core'
require 'sigslot/exceptions'
require 'sigslot/class_helpers'
require 'sigslot/rewriter'
