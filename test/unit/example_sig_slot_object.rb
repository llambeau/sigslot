require 'sigslot'

class SimpleSigSlotObject
    include SigSlot
    
    signal :signal_0_params
    signal :sig_with_1_param, [:one]
    signal :sig_with_3_params, [:one, :two, :three]
    
    slot :slot_0_params, :slot_1_param, :slot_var_arg, :slot_1_param_and_var_arg, :slot_2_params, :slot_3_params

    def initialize
    end
    
    def slot_0_params
    end
    
    def slot_1_param(one)
    end

    def slot_var_arg(*params)
    end

    def slot_1_param_and_var_arg(one, *params)
    end

    def slot_2_params(one, two)
    end

    def slot_3_params(one, two, three)
    end
    
    def reset
        @counters.clear
        disconnect
    end
end