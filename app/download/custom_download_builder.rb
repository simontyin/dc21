class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    data_files = DataFile.find(ids)
    file_paths = data_files.collect(&:path)
    file_paths << generate_metadata_for(data_files)

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, file_paths)

    block.yield(zip_file)
    zip_file.close
    zip_file.unlink
  end

  def self.subsetted_zip_for_files(all_files, date_range, from_date_string, to_date_string, &block)

    files = all_files.select do |file|
      file.has_data_in_range?(date_range.from_date, date_range.to_date)
    end

    return false if files.empty?

    temp_dir = Dir.mktmpdir
    paths = []

    files.each do |file|
      if file.format == FileTypeDeterminer::TOA5
        paths << Toa5Subsetter.extract_matching_rows_to(file, temp_dir, from_date_string, to_date_string)
      else
        paths << file.path
      end
    end

    paths << generate_metadata_for(files)

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, paths)

    block.yield(zip_file)

    zip_file.close
    zip_file.unlink

    true
  end

  def self.generate_metadata_for(data_files)
    temp_dir = Dir.mktmpdir
    metadata_dir = File.join(temp_dir, "metadata")
    Dir.mkdir(metadata_dir, 0700)
    m_w = MetadataWriter.new(data_files, metadata_dir)
    m_w.generate_metadata
    metadata_dir
  end
end
