module SigSlot

    # This class helps you to map specific signals to specific parameters
    # of parameters rewriting between a signal and an endpoint
    class SignalMapper
        include SigSlot

        signal :mapped, [:params]
        slot :map

		# Creates a new signal mapper
		# mapping: a hash containing the mapping to do
		#
		# example
		# SignalMapper.new(button1.signal(:clicked) => ['txtfile1'], :button2.signal(:clicked) => ['txtfile2'])
		# You should not connect the various signals to the signal mapper instance, the constructor does it himself
		# You must connect the signal :mapped to the slot you wan't
        def initialize(mapping)
			raise ArgumentError, "Please give a hash containing the mapping to do" unless Hash === mapping
			@mapping = Hash.new {|h,k| h[k] = {}}

			mapping.each_pair do |signal, params|
				SigSlot.connect signal, self.slot(:map)
				@mapping[signal.object][signal.name] = params
			end

        end

		# The slot used to make the mapping...
		# Emits signal :mapped with the mapped parameters
        def map(*params)
			sender = SigSlot.sender()
			emit :mapped, *@mapping[sender.object][sender.name]
        end

    end

end #SigSlot