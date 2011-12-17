require 'sigslot'

class SimpleSigSlotObject
    include SigSlot

    signal :signal_0_params
    signal :signal_1_param, [:one]
    signal :signal_3_params, [:one, :two, :three]

    slot :slot_0_params, :slot_1_param, :slot_var_arg, :slot_1_param_and_var_arg, :slot_2_params, :slot_3_params

    attr_reader :calls, :last_call
    def initialize
        @calls = Hash.new {|h,k| h[k] = {:count => 0}}
    end

    def log_call(who, params=nil)
        @calls[:last] = who
        @calls[who][:last_params] = params
        @calls[who][:count] += 1
    end

    def slot_0_params
        log_call(:slot_0_params)
    end

    def slot_1_param(one)
        log_call(:slot_1_param, [one])
    end

    def slot_var_arg(*params)
        log_call(:slot_var_arg, params)
    end

    def slot_1_param_and_var_arg(one, *params)
        log_call(:slot_1_param_and_var_arg, [one, params].flatten)
    end

    def slot_2_params(one, two)
        log_call(:slot_2_params, [one, two])
    end

    def slot_3_params(one, two, three)
        log_call(:slot_3_params, [one, two, three])
    end

    def emit_signal(signal, params)
        emit signal, params
    end

    def reset
        @calls.clear
        @last_call = nil
        disconnect
    end
end