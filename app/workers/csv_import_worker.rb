class CsvImportWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'
  
    def perform(employer_id, rows)
      employer = Employer.find(employer_id)
      layout = employer.header_mappings.each_with_object({}) do |mapping, hash|
        hash[mapping.key] = mapping.value
      end
  
      ActiveRecord::Base.transaction do
        rows.each do |row|
          employee = find_employee(employer, row[layout['employee_id']])
          earning_date = parse_date(row[layout['date']], layout['date_format'])
          amount = parse_amount(row[layout['amount']])
  
          create_earning(employee, earning_date, amount)
        end
      end
    end
  
    private
  
    def find_employee(employer, external_ref)
      employer.employees.find_or_create_by!(external_ref: external_ref)
    end
  
    def parse_date(date_str, date_format)
      if date_format
        Date.strptime(date_str, date_format)
      else
        Date.parse(date_str)
      end
    end
  
    def parse_amount(amount_str)
      amount_str.gsub(/[^0-9.]/, '').to_d
    end
  
    def create_earning(employee, earning_date, amount)
      employee.earnings.create!(earning_date: earning_date, amount: amount)
    end
  end
  