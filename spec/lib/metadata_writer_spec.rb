require 'spec_helper'

describe MetadataWriter do

  # set up fully populated example entities
  before(:each) do
    @primary_contact = Factory(:user, first_name: 'Prim', last_name: 'Contact', email: 'prim@intersect.org.au')
    @facility = Factory(:facility,
                        name: 'Whole Tree Chambers',
                        id: 1,
                        code: 'WTC',
                        description: 'The Whole Tree Chambers (WTC) facility was installed',
                        a_lat: 20, a_long: 30,
                        primary_contact: @primary_contact)
    @experiment = Factory(:experiment,
                          id: 1,
                          name: 'High CO2 and Drought',
                          facility: @facility,
                          start_date: '2011-12-25',
                          end_date: '2012-01-01',
                          subject: 'Drought',
                          description: 'Experiment desc',
                          access_rights: 'http://creativecommons.org/licenses/by/3.0/au')
    @experiment.set_for_codes({'1' => {'name' => '0101 - Mathematics', 'url' => 'someurl'}, '2' => {'name' => '0202 - Science', 'url' => 'someotherurl'}})

    cat1 = Factory(:parameter_category, name: 'Cat1')
    cat2 = Factory(:parameter_category, name: 'Cat2')
    subcat1 = Factory(:parameter_sub_category, name: 'Subcat1', parameter_category: cat1)
    subcat2 = Factory(:parameter_sub_category, name: 'Subcat2', parameter_category: cat2)
    mod1 = Factory(:parameter_modification, name: 'Excluded')
    mod2 = Factory(:parameter_modification, name: 'Added')
    mg = Factory(:parameter_unit, name: 'mg')
    @experiment.experiment_parameters.create!(parameter_category: cat1, parameter_sub_category: subcat1, parameter_modification: mod1)
    @experiment.experiment_parameters.create!(parameter_category: cat2, parameter_sub_category: subcat2, parameter_modification: mod2, parameter_unit: mg, amount: 10, comments: 'my comment')

    # TOA5 file with full metadata
    @data_file1 = Factory(:data_file,
                          id: 1,
                          filename: "datafile.jpg",
                          experiment: @experiment,
                          file_processing_status: DataFile::STATUS_RAW,
                          format: FileTypeDeterminer::TOA5,
                          created_at: "2012-06-27 06:49:08",
                          file_processing_description: 'My file desc',
                          created_by: Factory(:user, first_name: 'Fred', last_name: 'Bloggs'))
    photo = Tag.create!(name: 'Photo')
    video = Tag.create!(name: 'Video')
    @data_file1.tag_ids = [photo.id, video.id]
    @data_file1.save!
    Factory(:column_detail, :name => "Rnfll", :data_file => @data_file1)
    Factory(:column_detail, :name => "SoilTemp", :data_file => @data_file1)
    Factory(:column_detail, :name => "Humi", :data_file => @data_file1)
    #TODO: TOA5 metadata

    # Minimal metadata
    @data_file2 = Factory(:data_file,
                          filename: 'myfile.txt',
                          id: 2,
                          experiment: @experiment,
                          file_processing_status: 'PROCESSED',
                          format: nil,
                          created_at: "2012-12-27 14:09:24",
                          file_processing_description: nil,
                          created_by: Factory(:user, first_name: 'Fred', last_name: 'Bloggs'))
  end


  describe 'Basic metadata generation' do
    it 'should produce HTML with file, facility and experiment metadata (without duplication of facilities and experiments)' do
      output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
      diff_html(output_html, 'spec/samples/simple_readme.html')
    end

    it 'should handle a variety of experiments and facilities' do
      pending
    end
  end

  describe 'Handling cases with incomplete data (only minimal fields filled in)' do
    context 'Facilities' do
      it 'should handle missing primary contact' do
        @facility.aggregated_contactables.each { |contactable| contactable.delete }
        @facility.reload
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_no_facility_contact.html')
      end

      it 'should handle missing non-mandatory values' do
        @facility.a_lat = nil
        @facility.a_long = nil
        @facility.b_lat = nil
        @facility.b_long = nil
        @facility.description = nil
        @facility.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_minimal_facility.html')
      end
    end

    context 'Experiments' do
      it 'should handle missing non-mandatory values on experiments' do
        @experiment.description = nil
        @experiment.end_date = nil
        @experiment.experiment_for_codes.delete_all
        @experiment.save!

        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_minimal_experiment.html')
      end

      it 'should handle experiment with no parameters' do
        @experiment.experiment_parameters.delete_all
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_no_experiment_parameters.html')
      end
    end
    context 'Files' do
      it 'should handle non TOA5 files that have start/end times' do
        @data_file1.start_time = '2012-10-23 07:56:45 utc'
        @data_file1.end_time = '2012-12-01 22:04:23 utc'
        @data_file1.format = nil
        @data_file1.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_non_toa5_with_start_end.html')
      end

      it 'should handle non TOA5 files that have no start/end times' do
        @data_file1.start_time = nil
        @data_file1.end_time = nil
        @data_file1.format = nil
        @data_file1.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_non_toa5_with_no_start_end.html')
      end

      it 'should handle files with the "Other" experiment' do
        @data_file1.experiment_id = -1
        @data_file1.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2])
        diff_html(output_html, 'spec/samples/readme_file_with_other_experiment.html')
      end

    end
  end
end

def diff_html(output_html, expected_file)
  expected_html = File.read(File.join(Rails.root, expected_file))

  # parse the html as XML convert to a hash for comparison, so we don't have to worry about spacing/line ending differences
  actual_hash = Hash.from_xml(output_html)
  expected_hash = Hash.from_xml(expected_html)

  diff = expected_hash.diff(actual_hash)
  unless diff == {}
    puts "HTML did not match"
    puts "Expected:"
    puts expected_html
    puts "Actual:"
    puts output_html
  end

  diff.should == {}

end


