module SigSlot

    # Connect a signal to a slot, but provides a block to rewrite parameters before to propagate
    def self.connect_and_rewrite(signal, endpoint, &block)
        raise ArgumentError, "Block missing for connect_and_rewrite" unless block
        rewriter = Rewriter.new(&block)
        SigSlot.connect signal, rewriter.slot(:rewrite)
        rewriter.connect :rewrited, endpoint
    end

    # Instancied by connect_and_rewrite to provide a mechanism
    # of parameters rewriting between a signal and an endpoint
    class Rewriter

        include SigSlot

        signal :rewrited, [:params]
        slot :rewrite

        def initialize(&block)
            @block = block
        end

        def rewrite(*params)
            params = @block.call(params)
            emit :rewrited, *params
        end

    end

end #SigSlot
