# Wrapper class for Package objects so we can generate RIF-CS from them.
# This defines the mapping from DC21 domain concepts to fields in the RIF-CS xml.
# This is used by the RIF-CS generator to actually output RIF-CS.

class PackageRifCsWrapper < RifCsWrapper

  attr_accessor :options, :files, :date_range

  def initialize(collection_object, files, options)
    super(collection_object)
    self.options = options
    raise "Files cannot be nil" unless files
    self.files = files
  end

  def collection_type
    'dataset'
  end

  def group
    'University of Western Sydney'
  end

  def originating_source
    options[:root_url]
  end

  def key
    external_id
  end

  def electronic_location
    options[:zip_url]
  end

  def change_submitter(submitter)
    options[:submitter] = submitter
  end

  # returns an array of strings, each item being the text for a local subject
  def local_subjects
    subjects = experiments.collect(&:subject).uniq.sort
    subjects.select { |s| !s.blank? }
  end

  def access_rights
    experiments.collect(&:access_rights).uniq.sort
  end

  # returns an array of strings, each item being an FOR code in its PURL format
  def for_codes
    codes = experiments.collect(&:experiment_for_codes).flatten
    codes_with_urls = codes.collect(&:url).uniq.sort
    codes_with_urls.collect do |code|
      last_slash = code.rindex('/')
      chop_from = last_slash ? last_slash + 1 : 0
      code[chop_from..-1]
    end
  end

  # returns the start of the temporal coverage period as a date object
  # start is considered to be the the earliest start date found in the matching files, or nil if no files have dates
  def start_date
    earliest_from_files = files.collect(&:start_time).compact.sort.first
    return nil unless earliest_from_files
    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    earliest_from_files.utc.to_date
  end

  # returns the end of the temporal coverage period as a date object
  # end is considered to be the earlier of either the latest end date in the files OR the end of the date range being searched
  def end_date
    latest_from_files = files.collect(&:end_time).compact.sort.last
    return nil unless latest_from_files
    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    latest_from_files.utc.to_date
  end

  # Returns an array of locations for the collection. Each element in the array is also an array, containing the point(s) for that specific location
  #TODO: this is a bit cumbersome, could be improved
  def locations
    locations = []
    facilities.each do |f|
      locations << f.location_as_points unless f.location_as_points.empty?
    end
    locations
  end

  def notes
    notes = []
    notes << "Published by #{options[:submitter].full_name} (#{options[:submitter].email})"
    notes << "Unique ID: #{collection_object[:external_id]}" unless collection_object[:external_id].blank?

    facilities.each do |facility|
      contact = facility.primary_contact
      notes << "Primary contact for #{facility.name} is #{contact.full_name} (#{contact.email})" if contact
    end

    notes
  end

  private
  def experiments
    files.collect(&:experiment).compact.uniq
  end

  def facilities
    experiments.collect(&:facility).compact.uniq
  end
end
