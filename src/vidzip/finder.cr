require "file"

module VidZip
  class Finder
    class FileNotFoundError < Exception; end

    ZIP_SIGNATURE = Bytes[0x50, 0x4B, 0x03, 0x04]
    MDAT_ATOM_TYPE = "mdat"
    BUFFER_SIZE = 8192

    @path : String

    def initialize(@path)
      raise FileNotFoundError.new("File not found: #{@path}") unless File.exists?(@path)
    end

    def find_zip_offset
      File.open(@path) do |file|
        if mdat_info = find_mdat_info(file)
          search_for_zip(file, mdat_info[:offset] + mdat_info[:size])
        end
      end
    end

    private def find_mdat_info(file)
      file.rewind
      until file.pos >= file.size
        start_pos = file.pos
        return nil if file.size - start_pos < 8 
        size = file.read_bytes(UInt32, IO::ByteFormat::BigEndian)
        type = file.read_string(4)
        
        if size == 1
          return nil if file.size - file.pos < 8
          size = file.read_bytes(UInt64, IO::ByteFormat::BigEndian)
        end

        return {offset: start_pos, size: size} if type == MDAT_ATOM_TYPE
        
        next_pos = start_pos + size
        break if next_pos > file.size || next_pos <= start_pos
        file.seek(next_pos)
      end
      nil
    end

    private def search_for_zip(file, start_offset)
      return nil if start_offset >= file.size
      file.seek(start_offset)
      
      buffer = Bytes.new(BUFFER_SIZE)
      overlap_size = ZIP_SIGNATURE.size - 1
      
      until file.pos >= file.size
        read_start_pos = file.pos
        bytes_read = file.read(buffer)
        break if bytes_read == 0

        search_slice = buffer.to_slice[0, bytes_read]
        
        if index = index_of_subslice(search_slice, ZIP_SIGNATURE)
          return read_start_pos + index
        end

        next_pos = read_start_pos + bytes_read
        if bytes_read == BUFFER_SIZE
          next_pos -= overlap_size
        end

        break if next_pos <= read_start_pos

        file.seek(next_pos)
      end
      nil
    end

    private def index_of_subslice(slice : Bytes, subslice : Bytes) : Int32?
      return nil if subslice.empty? || subslice.size > slice.size

      (slice.size - subslice.size + 1).times do |i|
        if slice[i, subslice.size] == subslice
          return i
        end
      end

      nil
    end
  end
end