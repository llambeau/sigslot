require 'test/unit'
require 'sigslot/mapper'

module SigSlot

    module Tests
			
		class SimpleButton
			include SigSlot
			signal :clicked
			def click()
				emit :clicked
			end
		end
		
		class FileEditor
			include SigSlot
			slot :open_file
			
			attr_reader :current_file
			
			def open_file(filename)
				@current_file = filename
			end
		end

		class SignalMapperTest < Test::Unit::TestCase
		
			def test_signal_mapper
				tax_button = SimpleButton.new
				accounts_button  = SimpleButton.new
				report_button = SimpleButton.new
				file_editor = FileEditor.new
				
				mapper = SignalMapper.new(
					tax_button.signal(:clicked) => ["taxfile.txt"],
					accounts_button.signal(:clicked) => ["accountsfile.txt"],
					report_button.signal(:clicked) => ["reportfile.txt"]
				)
				
				mapper.connect :mapped, file_editor.slot(:open_file)
				
				assert_equal nil, file_editor.current_file
				tax_button.click
				assert_equal "taxfile.txt", file_editor.current_file
				accounts_button.click
				assert_equal "accountsfile.txt", file_editor.current_file
				report_button.click
				assert_equal "reportfile.txt", file_editor.current_file
			end
			
		end		
		
    end #Tests

end #SigSlot
