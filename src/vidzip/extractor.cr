class VidZip::Extractor
  @input_path : String
  @output_path : String

  BUFFER_SIZE = 8192

  def initialize(@input_path, @output_path)
  end

  def extract(offset : Int64)
    File.open(@input_path) do |input|
      File.open(@output_path, "w") do |output|
        input.seek(offset)
        buffer = Bytes.new(BUFFER_SIZE)
        while (bytes_read = input.read(buffer)) > 0
          output.write(buffer.to_slice[0, bytes_read])
        end
      end
    end
  end
end
