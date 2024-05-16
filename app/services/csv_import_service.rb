require 'csv'

class CsvImportService
  BATCH_SIZE = 1000

  def initialize(employer, csv_data)
    @employer = employer
    @csv_data = csv_data
    @layout = load_header_mappings
  end

  def import
    CSV.parse(@csv_data, headers: true).each_slice(BATCH_SIZE) do |batch|
      CsvImportWorker.perform_async(@employer.id, batch.map(&:to_h))
    end
  end

  private

  def load_header_mappings
    @employer.header_mappings.each_with_object({}) do |mapping, hash|
      hash[mapping.key] = mapping.value
    end
  end
end
