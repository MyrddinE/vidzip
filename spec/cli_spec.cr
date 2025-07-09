require "./spec_helper"

# Helper to capture stdout and stderr
def run_cli(args)
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  exit_code = Vidzip.run(args, stdout, stderr)
  {stdout: stdout.to_s, stderr: stderr.to_s, exit_code: exit_code}
end

describe "VidZip CLI" do
  describe "--extract flag" do
    it "extracts a zip when found" do
      video_with_zip = create_test_file("video_with_zip", 1024, true, 50)
      output_zip = File.basename(video_with_zip, File.extname(video_with_zip)) + ".zip"
      
      begin
        result = run_cli(["--extract", video_with_zip])
        
        result[:exit_code].should eq(0)
        result[:stdout].should contain("ZIP file found at offset: 1082")
        result[:stdout].should contain("Extracted to #{output_zip}")
        
        File.exists?(output_zip).should be_true
        
        # Verify the extracted file starts with the ZIP signature
        File.open(output_zip) do |file|
          signature = file.read_string(4)
          signature.should eq("PK\x03\x04")
        end
      ensure
        File.delete(video_with_zip) if File.exists?(video_with_zip)
        File.delete(output_zip) if File.exists?(output_zip)
      end
    end

    it "does not create a file if no zip is found" do
      video_no_zip = create_test_file("video_no_zip", 1024, false)
      output_zip = File.basename(video_no_zip, File.extname(video_no_zip)) + ".zip"

      begin
        result = run_cli(["--extract", video_no_zip])
        
        result[:exit_code].should eq(0)
        result[:stdout].should contain("No ZIP file found.")
        File.exists?(output_zip).should be_false
      ensure
        File.delete(video_no_zip) if File.exists?(video_no_zip)
        File.delete(output_zip) if File.exists?(output_zip)
      end
    end

    it "does not extract if the flag is not present" do
      video_with_zip = create_test_file("video_with_zip_no_flag", 1024, true)
      output_zip = File.basename(video_with_zip, File.extname(video_with_zip)) + ".zip"

      begin
        result = run_cli([video_with_zip])

        result[:exit_code].should eq(0)
        result[:stdout].should contain("ZIP file found at offset: 1032")
        result[:stdout].should_not contain("Extracted to")
        File.exists?(output_zip).should be_false
      ensure
        File.delete(video_with_zip) if File.exists?(video_with_zip)
        File.delete(output_zip) if File.exists?(output_zip)
      end
    end
  end
end
