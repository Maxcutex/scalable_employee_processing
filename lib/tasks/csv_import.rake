# how to run this
# EMPLOYER_ID=1 CSV_FILE_PATH=path/to/file.csv rake csv_import:import

namespace :csv_import do
    desc "Import earnings from CSV file"
    task import: :environment do
      employer_id = ENV['EMPLOYER_ID']
      csv_file_path = ENV['CSV_FILE_PATH']
  
      employer = Employer.find(employer_id)
      csv_data = File.read(csv_file_path)
  
      CsvImportService.new(employer, csv_data).import
      puts "Earnings import initiated for employer #{employer.name}."
    rescue StandardError => e
      puts "Error initiating earnings import: #{e.message}"
    end
  end
  