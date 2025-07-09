require "spec"
require "../src/vidzip"

# Helper to create a dummy video file for testing
def create_test_file(prefix : String, mdat_size : Int32, append_zip : Bool, zip_offset : Int32 = 0)
  tempfile = File.tempfile(prefix)
  
  # moov atom
  tempfile.write_bytes(UInt32.new(8), IO::ByteFormat::BigEndian)
  tempfile.print "moov"

  # mdat atom
  tempfile.write_bytes(UInt32.new(mdat_size), IO::ByteFormat::BigEndian)
  tempfile.print "mdat"
  tempfile.write(Bytes.new(mdat_size - 8))

  tempfile.write(Bytes.new(zip_offset))

  if append_zip
    tempfile.print "PK\x03\x04"
  end

  tempfile.close
  tempfile.path
end