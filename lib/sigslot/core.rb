module SigSlot

    include Robustness

    # Decorates the including class with the definition helpers
    def self.included(base)
        @@signal_emitted_connections = [] 
        base.class_eval do
            @signals = {
                :signal_emitted => [:signal, :params]
            }
            @slots = []
        end
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
        signal_name = valid_signal_name!(signal)
        raise SignalNotFound, "Signal '#{signal_name}' not found on object '#{self}'" unless has_signal? signal

        if endpoint.is_a? SignalDefinition then
            raise SignalNotFound, "Signal '#{endpoint.name}' not found on object '#{recipient}'" unless recipient.has_signal? endpoint
            raise ArgumentError, "You cannot use the special ':signal_emitted' as endpoint of a connection" if endpoint.name == :signal_emitted
        
            connections[signal_name] << {:recipient => recipient, :endpoint => endpoint}
        elsif endpoint.is_a? SlotDefinition then
            raise SlotNotFound, "Slot '#{endpoint.name}' not found on object '#{recipient}'" unless recipient.has_slot? endpoint
            connections[signal_name] << {:recipient => recipient, :endpoint => endpoint}
        else
            raise ArgumentError, "Endpoint of connect must be a valid Signal or Slot definition. Please use SLOT(:name) or SIGNAL(:name) helpers"
        end
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
        raise ArgumentError, "Signal names must be Symbols" unless signal.is_a? Symbol
        raise ArgumentError, "Parameters must be an array" unless params.is_a? Array
        raise SignalNotFound, "Signal '#{signal}' not found" unless signals.has_key? signal
        
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
        if con[:endpoint].is_a? SignalDefinition then
            unless con[:recipient].has_signal? con[:endpoint] then
                raise SlotNotFound, "Signal '#{con[:endpoint].name}' not found on object '#{con[:recipient]}'" 
            end
            recipient.emit(con[:endpoint].name, params) # Emit bound signal
        # Propagate signals to bound slots
        elsif con[:endpoint].is_a? SlotDefinition then
            unless con[:recipient].has_slot? con[:endpoint] then
                raise SlotNotFound, "Slot '#{con[:endpoint].name}' not found on object '#{con[:recipient]}'" 
            end
            
            slot_name = con[:endpoint].name
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
        else
            # This should never happend
            raise ArgumentError, "Invalid endpoint given to connection while emitting signal: #{con[:endpoint]}"
        end
    end
    
end #SigSlot