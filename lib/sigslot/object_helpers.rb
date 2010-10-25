# Decorates Object with some helpers
class ::Object

    def SIGNAL(name)
        raise ArgumentError, "Signal names must be Symbols" unless name.is_a? Symbol
        SigSlot::SignalDefinition.new(name)
    end

    def SLOT(name)
        raise ArgumentError, "Slot names must be Symbols" unless name.is_a? Symbol
        SigSlot::SlotDefinition.new(name)
    end
    
end
