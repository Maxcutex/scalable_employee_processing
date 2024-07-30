# frozen_string_literal: true

# CsvProcessingWorker is a Sidekiq worker responsible for processing CSV files
# from S3 for a given employer. It fetches the latest CSV file that hasn't been
# processed yet, and then delegates the processing to the CsvProcessingService.
class CsvProcessingWorker
  include Sidekiq::Worker

  # The name of the S3 bucket used to store employer CSV files.
  BUCKET_NAME = 'employer_payroll'

  # Processes CSV data for a given employer.
  #
  # @param employer_id [Integer] the ID of the employer whose CSV data will be processed
  def perform(employer_id)
    employer = Employer.find(employer_id)
    csv_data = fetch_csv_data(employer)

    if csv_data
      service = CsvProcessingService.new(employer, csv_data)
      service.process_csv
    else
      puts "No new file to process for employer #{employer.id}"
    end
  end

  private

  # Fetches CSV data from S3 for the given employer.
  #
  # @param employer [Employer] the employer whose CSV data will be fetched
  # @return [String, nil] the content of the latest CSV file or nil if no file is found
  def fetch_csv_data(employer)
    s3_client = Aws::S3::Client.new
    files = list_files_from_s3(s3_client, employer.id)

    recent_file = find_unprocessed_file(files, employer.id)
    return nil unless recent_file

    download_file_from_s3(s3_client, recent_file.key)
  end

  # Lists all files in the employer's subfolder from S3.
  #
  # @param s3_client [Aws::S3::Client] the S3 client
  # @param employer_id [Integer] the ID of the employer
  # @return [Array<Aws::S3::Types::Object>] list of S3 files
  def list_files_from_s3(s3_client, employer_id)
    response = s3_client.list_objects_v2(
      bucket: BUCKET_NAME,
      prefix: "#{employer_id}/"
    )
    response.contents.sort_by(&:last_modified).reverse
  end

  # Finds the latest unprocessed file.
  #
  # @param files [Array<Aws::S3::Types::Object>] list of S3 files
  # @param employer_id [Integer] the ID of the employer
  # @return [Aws::S3::Types::Object, nil] the unprocessed file or nil if not found
  def find_unprocessed_file(files, employer_id)
    files.find do |file|
      !ProcessedFile.exists?(employer_id: employer_id, file_key: file.key)
    end
  end

  # Downloads the file content from S3.
  #
  # @param s3_client [Aws::S3::Client] the S3 client
  # @param key [String] the S3 object key
  # @return [String] the content of the file
  def download_file_from_s3(s3_client, key)
    s3_client.get_object(bucket: BUCKET_NAME, key: key).body.read
  end
end
