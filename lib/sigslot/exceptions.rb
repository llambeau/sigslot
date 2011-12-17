module SigSlot

    class SignalNotFound < StandardError
    end

    class SlotNotFound < StandardError
    end

    class InvalidSignalBinding < StandardError
    end

    class InvalidSignalParameters < StandardError
    end

end #SigSlot
