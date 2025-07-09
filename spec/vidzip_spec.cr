require "./spec_helper"
require "../src/vidzip/finder"
require "file_utils"

describe VidZip::Finder do
  it "returns the zip offset when a zip is appended" do
    file_path = create_test_file("test_with_zip", 32, true, 10)
    begin
      finder = VidZip::Finder.new(file_path)
      offset = finder.find_zip_offset
      offset.should eq(8 + 32 + 10)
    ensure
      File.delete(file_path)
    end
  end

  it "returns nil when no zip is appended" do
    file_path = create_test_file("test_no_zip", 32, false)
    begin
      finder = VidZip::Finder.new(file_path)
      offset = finder.find_zip_offset
      offset.should be_nil
    ensure
      File.delete(file_path)
    end
  end

  it "raises an error if the file does not exist" do
    expect_raises(VidZip::Finder::FileNotFoundError, "File not found: non_existent_file.mp4") do
      VidZip::Finder.new("non_existent_file.mp4")
    end
  end
end