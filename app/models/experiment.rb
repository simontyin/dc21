class Experiment < ActiveRecord::Base
  #include ActionView::Helpers::TextHelper

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"
  has_many :experiment_parameters

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  validates_presence_of :facility_id
  validates_presence_of :access_rights

  validates_length_of :name, :subject, {:maximum => 255}
  validates_length_of :description, :maximum => 8192

  validate :validate_start_before_end

  def validate_start_before_end
    if end_date && start_date
      errors.add(:end_date, "cannot be before start date") if end_date < start_date
    end
  end

  def name_with_prefix
    "Experiment - #{name}"
  end

  def parent_name
    if parent_experiment
      parent_experiment.name_with_prefix
    else
      "Facility - #{facility.name}"
    end
  end

  def set_for_codes(codes)
    experiment_for_codes.destroy_all
    return if codes.nil? || codes.empty?
    urls = []
    codes.each_value do |code_attrs|
      url = code_attrs["url"]
      unless urls.include?(url)
        experiment_for_codes.build(code_attrs)
        urls << url
      end
    end
  end

  def access_rights_description
    AccessRightsLookup.new.get_name(self.access_rights)
  end

  def write_metadata_to_file(directory_path)
    #ExperimentForCode.find_all_by_experiment_id(ids)
    file_path = File.join(directory_path, "#{name.parameterize}-metadata.txt")
    File.open(file_path, 'w') do |file|
      format_metadata(file)
    end
    file_path
  end

  def format_metadata(file)
    f_d = word_wrap(description.to_s)
    file.puts "Parent: \t#{parent_name}\r\n"
    file.puts "Name: \t\t#{name}\r\n"
    file.puts "Description: \t#{f_d}\r\n"
    if !start_date.nil?
      file.puts("Start date: \t#{start_date.to_s(:date_only)}\r\n")
    else
      file.puts("Start date: \r\n")
    end
    if !end_date.nil?
      file.puts("End date: \t#{end_date.to_s(:date_only)}\r\n")
    else
      file.puts("End date: \r\n")
    end
    file.puts "Subject: \t#{subject.to_s}\r\n"
  end

  def word_wrap(text, *args)
    options = args.extract_options!
    unless args.blank?
      options[:line_width] = args[0] || 80
    end
    options.reverse_merge!(:line_width => 80)

    text.split("\r").collect do |line|
      line.length > options[:line_width] ? line.gsub(/(.{1,#{options[:line_width]}})(\s+|$)/, "\\1\r\n\t\t").strip : line
    end * "\r"
  end
end
