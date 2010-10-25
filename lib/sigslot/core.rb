module SigSlot

    include Robustness

    # Decorates the including class with the definition helpers
    def self.included(base)
        @@signal_emitted_connections = [] 
        base.extend ClassMethods
    end
    
    # Tests if an object has a specific signal
    def has_signal?(signal)
        signals.has_key? valid_signal_name!(signal)
    end
    
    # Tests if object has a specific slot
    def has_slot?(slot)
        slots.include? valid_slot_name!(slot)
    end

    # Connect a signal to a slot 
    def self.connect(sender, signal, recipient, endpoint)
        if sender == SigSlot then
            unless signal.is_a? SignalDefinition and signal.name == :signal_emitted then
                raise ArgumentError, "Only special signal :signal_emitted can be bound on SigSlot module"
            else
                @@signal_emitted_connections << {:recipient => recipient, :endpoint => endpoint}
            end
        else
            sender.connect(signal, recipient, endpoint)
        end
    end
    
    # Connect a signal to a slot
    def connect(signal, recipient, endpoint)
        signal = valid_signal!(self, signal)
        valid_endpoint!(recipient, endpoint)
        connections[signal] << {:recipient => recipient, :endpoint => endpoint}
    end
    
    # Access connections
    def connections
        @connections ||=  Hash.new{|h,k| h[k] = []}
    end
    
    # Access signals
    def signals
        self.class.signals
    end

    # Access slots
    def slots
        self.class.slots
    end

    # Emit a signal
    def emit(signal, params=[])
        valid_signal!(self, signal)
        raise ArgumentError, "Parameters must be an array" unless params.is_a? Array
        
        # Trigger all signals or slots bound to the emitted signal
        connections[signal].each do |con|
            trigger(signal, con, params)
        end
        
        # Emit the special signal :signal_emitted 
        unless signal == :signal_emitted then
            emit :signal_emitted, [signal, params]
        end
        
        # Trigger all endpoints connected to the global special signal :signal_emitted
        @@signal_emitted_connections.each do |con|
            trigger(:signal_emitted, con, [self, signal, params])
        end
    end
    
    # Used to trigger and endpoint
    # signal is the name of the signal which triggers these endpoints
    # con is the endpoint definition
    # params is the params to pass to the endpoint 
    private
    def trigger(signal, con, params)
        recipient = con[:recipient]
        # Propagate signals to bound signals
        endpoint = con[:endpoint]
        case endpoint
        when SignalDefinition 
            recipient.emit(endpoint.name, params) # Emit bound signal
        # Propagate signals to bound slots
        when SlotDefinition then
            slot_name = endpoint.name
            slot_arity = recipient.method(slot_name).arity
            #
            # TODO: Because of strange values reported by #arity, there are sleeping bugs here
            #
            if slot_arity < 0 then
                begin
                    recipient.send slot_name, *params
                rescue => ex
                    raise InvalidSignalBinding, "Invalid binding between signal '#{signal}' and slot '#{slot_name}'. Bad arity"
                end
            elsif slot_arity > params.size then
                raise InvalidSignalBinding, "Invalid binding between signal '#{signal}' and slot '#{slot_name}'. Bad arity"
            else
                if slot_arity == 0 then
                    recipient.send slot_name
                else
                    recipient.send slot_name, *params[0..slot_arity-1]
                end
            end
        end
    end
    
end #SigSlot