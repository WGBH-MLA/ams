class CsvBuilder
  ROW_SEPARATOR = "\n"
  COLUMN_SEPARATOR = ','

  attr_reader :path, :rows, :headers

  def initialize(path:, rows: [], headers: [])
    @path, @rows, @headers = path, rows, headers
  end

  def save!
    File.write(path, csv)
  end

  def csv
    @csv ||= CSV.generate(headers: headers, col_sep: COLUMN_SEPARATOR, row_sep: ROW_SEPARATOR, write_headers: true) do |csv|
      rows.each { |row| csv << row }
    end
  end
end
