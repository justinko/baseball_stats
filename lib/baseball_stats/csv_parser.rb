require 'csv'

module BaseballStats
  module CSVParser
    def self.parse(file_name)
      CSV.read(file_name).to_a.drop(1)
    end
  end
end
