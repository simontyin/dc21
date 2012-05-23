class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    file_paths = DataFile.find(ids).collect(&:path)
    file_paths.concat(build_metadata(ids))

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, file_paths)

    block.yield(zip_file)
    zip_file.close
    zip_file.unlink
  end

  def self.build_metadata(ids)
    filepath = []
    datafiles = DataFile.find(ids, :select => 'DISTINCT experiment_id')
    experiment_metadata_path = build_experiment_metadata(datafiles)

    experiments = []
    datafiles.each do |df|
      experiments << Experiment.find(df.experiment_id)
    end

    facility_metadata_path = build_facility_metadata(experiments)
    filepath.concat(experiment_metadata_path)
    filepath.concat(facility_metadata_path)
    return filepath
  end

  def self.build_experiment_metadata(datafiles, &block)
    metadata_files = []
    datafiles.each do |df|
      exp = Experiment.find(df.experiment_id)
      file_path = exp.write_metadata_to_file(Rails.root.to_s + '/tmp/')
      metadata_files << file_path
    end
    metadata_files
  end

  def self.build_facility_metadata(experiments, &block)
    metadata_files = []
    experiments.each do |exp|
      fc = Facility.find(exp.facility_id)
        file_path = fc.write_metadata_to_file(Rails.root.to_s + '/tmp')
      metadata_files << file_path
    end
    metadata_files
  end

  def self.subsetted_zip_for_files(files, date_range, from_date_string, to_date_string, &block)
    temp_dir = Dir.mktmpdir
    paths = []
    files.each do |file|
      if file.has_data_in_range?(date_range.from_date, date_range.to_date)
        if file.format == FileTypeDeterminer::TOA5
          paths << Toa5Subsetter.extract_matching_rows_to(file, temp_dir, from_date_string, to_date_string)
        else
          paths << file.path
        end
      end
    end

    return false if paths.empty?

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, paths)

    block.yield(zip_file)

    zip_file.close
    zip_file.unlink

    true
  end
end