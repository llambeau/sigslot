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
                    raise ArgumentError, "Invalid signal argument #{signal}. Please use SIGNAL(:name) and SLOT(:name) helpers", caller[1]
                end
            end
        end
        alias :valid_slot_name! :valid_signal_name!
        alias :valid_endpoint_name! :valid_signal_name!
  
        def valid_signal!(object, signal)
            signal = valid_signal_name!(signal)
            raise SignalNotFound, "Signal '#{signal}' not found on object '#{object}'", caller[1] unless object.has_signal? signal
            signal
        end
  
        def valid_slot!(object, slot)
            slot = valid_slot_name!(slot)
            raise SlotNotFound, "Slot '#{slot}' not found on object '#{object}'", caller[1] unless object.has_slot? slot
            slot
        end
  
        def valid_endpoint!(object, endpoint)
            case endpoint
            when SignalDefinition
                valid_signal!(object, endpoint)
                raise ArgumentError, "You cannot use the special ':signal_emitted' as endpoint of a connection" if endpoint.name == :signal_emitted
            when SlotDefinition
                valid_slot!(object, endpoint)
            else
                raise ArgumentError, "Endpoint of connect must be a valid Signal or Slot definition. Please use SLOT(:name) and SIGNAL(:name) helpers", caller[1]
            end
            endpoint
        end
    
    end #Robustness

end #SigSlot
