# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe CsvProcessingWorker, type: :worker do
  let(:employer) { create(:employer) }
  let(:csv_data) { "EmployeeNumber,CheckDate,Amount\nA123,12/14/2021,800.50\n" }
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:file_key) { "#{employer.id}/some_file.csv" }
  let(:s3_file) { instance_double(Aws::S3::Types::Object, key: file_key, last_modified: Time.now) }

  before do
    # Mock S3 client methods
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    allow(s3_client).to receive(:list_objects_v2).and_return(
      instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [s3_file])
    )
    allow(s3_client).to receive(:get_object).and_return(
      instance_double(Aws::S3::Types::GetObjectOutput, body: StringIO.new(csv_data))
    )
  end

  describe '#perform' do
    context 'when file exists' do
      it 'fetches CSV data from S3 and processes it' do
        # Expect CsvProcessingService to be called with the correct parameters
        service = instance_double(CsvProcessingService)
        expect(CsvProcessingService).to receive(:new).with(employer, csv_data).and_return(service)
        expect(service).to receive(:process_csv)

        # Perform the job
        described_class.new.perform(employer.id)
      end
    end

    context 'when no new file is found' do
      it 'logs ' do
        # Set up no files to return
        allow(s3_client).to receive(:list_objects_v2).and_return(
          instance_double(Aws::S3::Types::ListObjectsV2Output, contents: [])
        )

        # Use a spy to check log output
        expect do
          described_class.new.perform(employer.id)
        end.to output("No new file to process for employer #{employer.id}\n").to_stdout
      end
    end
  end
end
