module SigSlot

    module ClassMethods
    
        include Robustness

        attr_accessor :connections, :signals, :slots
        
        # Access signals
        def signals
            @signals ||= {
                :signal_emitted => [:signal, :params] # Special signal to monitor all emissions of an object
            }
        end

        # Access slots
        def slots
            @slots ||= []
        end
        
        # Define a new signal
        # 
        # A signal has a name (represented by symbol) and an optional list of parameters
        # 
        # signal :value_changed, [:new_value]
        def signal(name, params=[])
            name = valid_signal_name!(name)
            unless params.is_a? Array
                raise ArgumentError, "Signal parameters must be an array of Symbols" 
            end
               params.each do |sym| 
                raise ArgumentError, "Signal parameters must be an array of Symbols" unless sym.is_a? Symbol
            end
            signals[name] = params
        end
        
        # Define a new slot
        # 
        # A slot has a name (represented by symbol) and an optional list of parameters
        # The purpose of this helper is to define methods as slots, so this helper creates a real
        # method of the same name with the same number of arguments
        # The parameters are given to the block in a Hash
        # 
        # So the following example also creates a method as: 'change_value(new_value)'
        #
        # slot :change_value, [:new_value] do |params|
        #         @value = params[:new_value]
        # end
        def slot(*names)
            names = [names].flatten
            names.each do |name|
                name = valid_signal_name!(name)
                slots << name
            end
        end            
        
    end #ClassMethods
    
end #SigSlot
