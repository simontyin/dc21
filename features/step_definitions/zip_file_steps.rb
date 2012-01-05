Then /^I should receive a zip file matching "([^"]*)"$/ do |directory|
  tempfile = Tempfile.new(["temp_file", ".zip"])
  tempfile.close
  zip = File.open(tempfile.path, "wb")
  zip.write(page.source)

  temp_dir = Dir.mktmpdir

  downloaded_files = {}
  Zip::ZipFile.foreach(zip.path) do |file|
    path = File.join(temp_dir, file.name)
    file.extract(path)
    downloaded_files[file.name] = path
  end

  expected_files = Dir.glob(File.join(Rails.root, directory, "/*"))

  downloaded_files.size.should eq(expected_files.size)
  expected_files.each do |path_to_expected_file|
    downloaded_file_path = downloaded_files[File.basename(path_to_expected_file)]
    if downloaded_file_path.nil?
      raise "Expected downloaded zip to include file #{File.basename(path_to_expected_file)} but did not find it. Found #{downloaded_files.keys}."
    else
      downloaded_file_path.should be_same_file_as(path_to_expected_file)
    end
  end

end