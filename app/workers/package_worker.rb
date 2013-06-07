class PackageWorker
  include Resque::Plugins::Status

  @queue = :package_queue

  PACKAGE_QUEUED = 'QUEUED'
  PACKAGE_WORKING = 'PACKAGING'
  PACKAGE_COMPLETE = 'COMPLETE'

  def perform
    package_id = options['package_id']
    data_file_ids = options['data_file_ids']
    user_id = options['user_id']

    user = User.find(user_id)
    pkg = DataFile.find(package_id)

    pkg.transfer_status = PACKAGE_QUEUED
    pkg.save!

    CustomDownloadBuilder.bagit_for_files_with_ids(data_file_ids, pkg) do |zip_file|
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], user, FileTypeDeterminer.new, MetadataExtractor.new)
      files = attachment_builder.build_package(pkg, zip_file)
      build_rif_cs(files, pkg, user) unless files.nil?
    end

    pkg.transfer_status = PACKAGE_COMPLETE
    pkg.save!
  end

  private

  # Build the rif-cs and place in the unpublished_rif_cs folder, where it will stay until published in DC21
  def build_rif_cs(files, package, user)
    dir = APP_CONFIG['unpublished_rif_cs_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{package.id}.xml")

    file = File.new(output_location, 'w')

    options = {:root_url => Rails.application.routes.url_helpers.root_path,
               :collection_url => Rails.application.routes.url_helpers.data_file_path(package),
               :zip_url => Rails.application.routes.url_helpers.download_data_file_path(package),
               :submitter => user}
    RifCsGenerator.new(PackageRifCsWrapper.new(package, files, options), file).build_rif_cs
    file.close
  end

end