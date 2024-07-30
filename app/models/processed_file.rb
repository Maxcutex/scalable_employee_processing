# frozen_string_literal: true

class ProcessedFile < ApplicationRecord
  belongs_to :employer

  validates :file_key, presence: true
end
