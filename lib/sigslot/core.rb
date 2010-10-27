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
    def self.connect(signal, endpoint)
        case signal
        when :signal_emitted
            @@signal_emitted_connections << endpoint
        else
            raise ArgumentError, "Bad signal definition #{signal.inspect}" unless SignalDefinition === signal
            signal.object.connect(signal.name, endpoint)
        end
    end
    
    # Connect a signal to a slot
    def connect(signal, endpoint)
        raise ArgumentError, "Only signal names must be given as first argument to object.connect" unless Symbol === signal
        signal = valid_signal!(SignalDefinition.new(self, signal))
        endpoint = valid_endpoint!(endpoint)
        
        if signal.name == :signal_emitted && endpoint.object == self then
            raise InvalidSignalBinding, ":signal_emitted can't be bound to a signal of the same object (infinite loop)"
        end
        
        connections[signal.name] << endpoint
    end
    
    # Disconnect a slot/signal from a signal
    def self.disconnect(signal, endpoint=nil)
        signal = valid_signal!(signal)
        signal.object.disconnect(signal.name, endpoint)
    end
    
    # Disconnect a slot/signal from a signal
    def disconnect(signal=nil, endpoint=nil)
        purge_connections(connections, signal, endpoint)
    end
    
    # Access connections
    def connections
        @connections ||=  Hash.new{|h,k| h[k] = [] }
    end
    
    # Access signals
    def signals
        self.class.signals
    end

    # Access slots
    def slots
        self.class.slots
    end
    
    # Returns a specific signal
    def signal(name)
        valid_signal_def! SignalDefinition.new(self, name)
    end
    
    # Returns a specific slot
    def slot(name)
        valid_slot_def! SlotDefinition.new(self, name)
    end

    # Emit a signal
    def emit(signal, *params)
		signal_def = SignalDefinition.new(self, signal)
        valid_signal!(signal_def)
        valid_signal_parameters!(signal, params)

		push_sender(signal_def)
        
        # Trigger all signals or slots bound to the emitted signal
        connections[signal].each do |con|
            trigger(signal, con, params)
        end
        
        # Emit the special signal :signal_emitted 
        unless signal == :signal_emitted then
            emit :signal_emitted, signal, params
        end
        
        # Trigger all endpoints connected to the global special signal :signal_emitted
        @@signal_emitted_connections.each do |con|
            trigger(:signal_emitted, con, [self, signal, params])
        end
		pop_sender
    end
    
	def self.sender
		self.signals_senders[Thread.current.object_id].last
	end
	
	def push_sender(sender)
		SigSlot.signals_senders[Thread.current.object_id] << sender
	end

	def pop_sender
		SigSlot.signals_senders[Thread.current.object_id].pop
	end
	
	private
	def self.signals_senders
		@@signals_senders ||= Hash.new {|h,k| h[k] = []}
	end
	
    # Used to trigger and endpoint
    # signal is the name of the signal which triggers these endpoints
    # con is the endpoint definition
    # params is the params to pass to the endpoint 
    private
    def trigger(signal, endpoint, params)
        recipient = endpoint.object
        # Propagate signals to bound signals
        case endpoint
        when SignalDefinition 
            recipient.emit(endpoint.name, *params) # Emit bound signal
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
                    raise ex
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
    
    # Purges desired connection
    def purge_connections(connections, signal, endpoint)
        if signal.nil? then
            connections.clear
        else
            name = valid_signal_name!(signal)        
            if endpoint.nil? then
                connections[name].clear
            else
                connections[name].delete_if { |item| item == endpoint }
            end
        end
    end
    
end #SigSlot