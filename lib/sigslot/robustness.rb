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
      
      def valid_signal_def!(signal)
        case signal
            when SignalDefinition
                signal
            else
                raise ArgumentError, "Invalid signal definition. Please use SIGNAL(:name) helper", caller[1]
        end
      end
    
    end #Robustness
    
end #SigSlot
