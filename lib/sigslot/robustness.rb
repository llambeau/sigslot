module SigSlot

    module Robustness
        
        def valid_signal_name!(signal)
            case signal
            when Symbol
                signal
            else
                if signal.respond_to?(:name)
                    signal.name
                else
                    raise ArgumentError, "Invalid signal argument #{signal}", caller[1]
                end
            end
        end
        alias :valid_slot_name! :valid_signal_name!
        alias :valid_endpoint_name! :valid_signal_name!
  
        def valid_signal_def!(signal)
            unless signal.respond_to?(:name) && signal.respond_to?(:object) then
                raise ArgumentError, "Invalid signal/slot definition #{signal}", caller[1]
            end
            signal
        end
        alias :valid_slot_def! :valid_signal_def!
        alias :valid_endpoint_def! :valid_signal_def!
  
        def valid_signal!(signal)
            signal = valid_signal_def!(signal)
            raise SignalNotFound, "Signal '#{signal.name}' not found on object '#{signal.object}'", caller[1] unless signal.object.has_signal? signal
            signal
        end
  
        def valid_slot!(slot)
            slot = valid_slot_def!(slot)
            raise SlotNotFound, "Slot '#{slot.name}' not found on object '#{slot.object}'", caller[1] unless slot.object.has_slot? slot
            slot
        end
  
        def valid_endpoint!(endpoint)
            case endpoint
            when SignalDefinition
                valid_signal!(endpoint)
                raise ArgumentError, "You cannot use the special ':signal_emitted' as endpoint of a connection", caller[1] if endpoint.name == :signal_emitted
            when SlotDefinition
                valid_slot!(endpoint)
            else
                raise ArgumentError, "Endpoint of connect must be a valid Signal or Slot definition", caller[1]
            end
            endpoint
        end
    
    end #Robustness

end #SigSlot
