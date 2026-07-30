require 'zlib'

# Minimal, dependency-free writer for .xlsx (Office Open XML) workbooks.
#
# The app doesn't bundle caxlsx/axlsx, and this is only used to hand admins a
# tidy multi-sheet download, so rather than pull in a gem we assemble the small
# set of XML parts an .xlsx needs and pack them into the ZIP container by hand
# using only Ruby's stdlib (Zlib for CRC-32). Entries are stored uncompressed,
# valid ZIP, and fine for the handful of rows involved here.
#
# Supports tabular data only: each cell value is written as a number (for
# Numeric) or an inline string (for everything else). No styles or formulas.
#
#   xlsx = SimpleXlsx.new
#   xlsx.add_sheet("Rookie", [["Car", "Times used"], ["Toyeca", 42]])
#   send_data xlsx.to_bytes, filename: "usage.xlsx", type: SimpleXlsx::MIME_TYPE
class SimpleXlsx
  MIME_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.freeze

  def initialize
    @sheets = []
  end

  # name: worksheet tab title. rows: Array of rows, each an Array of cell values.
  def add_sheet(name, rows)
    @sheets << { :name => sanitize_name(name), :rows => rows || [] }
    self
  end

  def any?
    @sheets.any?
  end

  # Returns the whole workbook as a binary (ASCII-8BIT) String.
  def to_bytes
    add_sheet('Sheet1', []) if @sheets.empty?
    zip(package_files)
  end

  private

  # Ordered list of [path, content] parts that make up the package.
  def package_files
    files = []
    files << ['[Content_Types].xml', content_types_xml]
    files << ['_rels/.rels', root_rels_xml]
    files << ['xl/workbook.xml', workbook_xml]
    files << ['xl/_rels/workbook.xml.rels', workbook_rels_xml]
    @sheets.each_with_index do |sheet, i|
      files << ["xl/worksheets/sheet#{i + 1}.xml", worksheet_xml(sheet[:rows])]
    end
    files
  end

  def content_types_xml
    overrides = @sheets.each_index.map do |i|
      %(<Override PartName="/xl/worksheets/sheet#{i + 1}.xml" ) +
        %(ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>)
    end.join

    %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
      %(<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">) +
      %(<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>) +
      %(<Default Extension="xml" ContentType="application/xml"/>) +
      %(<Override PartName="/xl/workbook.xml" ) +
      %(ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>) +
      overrides +
      %(</Types>)
  end

  def root_rels_xml
    %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
      %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
      %(<Relationship Id="rId1" ) +
      %(Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" ) +
      %(Target="xl/workbook.xml"/>) +
      %(</Relationships>)
  end

  def workbook_xml
    sheet_tags = @sheets.each_with_index.map do |sheet, i|
      %(<sheet name="#{escape(sheet[:name])}" sheetId="#{i + 1}" r:id="rId#{i + 1}"/>)
    end.join

    %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
      %(<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ) +
      %(xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">) +
      %(<sheets>#{sheet_tags}</sheets>) +
      %(</workbook>)
  end

  def workbook_rels_xml
    rels = @sheets.each_index.map do |i|
      %(<Relationship Id="rId#{i + 1}" ) +
        %(Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" ) +
        %(Target="worksheets/sheet#{i + 1}.xml"/>)
    end.join

    %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
      %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
      rels +
      %(</Relationships>)
  end

  def worksheet_xml(rows)
    body = rows.each_with_index.map do |cells, r|
      row_number = r + 1
      cell_tags = Array(cells).each_with_index.map do |value, c|
        cell_xml("#{column_letter(c)}#{row_number}", value)
      end.join
      %(<row r="#{row_number}">#{cell_tags}</row>)
    end.join

    %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
      %(<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">) +
      %(<sheetData>#{body}</sheetData>) +
      %(</worksheet>)
  end

  def cell_xml(ref, value)
    if value.is_a?(Numeric)
      %(<c r="#{ref}"><v>#{value}</v></c>)
    else
      %(<c r="#{ref}" t="inlineStr"><is><t xml:space="preserve">#{escape(value)}</t></is></c>)
    end
  end

  # 0-based column index -> spreadsheet column letters (0 => A, 26 => AA).
  def column_letter(index)
    letters = +''
    n = index
    loop do
      letters.prepend(((n % 26) + 65).chr)
      n = n / 26 - 1
      break if n.negative?
    end
    letters
  end

  def escape(value)
    value.to_s
         .gsub('&', '&amp;')
         .gsub('<', '&lt;')
         .gsub('>', '&gt;')
         .gsub('"', '&quot;')
         .gsub("'", '&apos;')
         .gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F]/, '')
  end

  def sanitize_name(name)
    cleaned = name.to_s.gsub(%r{[\[\]:*?/\\]}, ' ').strip
    cleaned = 'Sheet' if cleaned.empty?
    cleaned[0, 31]
  end

  # Assemble the ZIP (all entries stored, no compression).
  def zip(files)
    buffer = ''.b
    central = ''.b
    dos_date = 0x0021 # 1980-01-01; a valid, fixed timestamp

    files.each do |name, content|
      data = content.to_s.b
      name_bytes = name.b
      crc = Zlib.crc32(data)
      size = data.bytesize
      offset = buffer.bytesize

      buffer << [0x04034b50, 20, 0, 0, 0, dos_date, crc, size, size,
                 name_bytes.bytesize, 0].pack('VvvvvvVVVvv')
      buffer << name_bytes
      buffer << data

      central << [0x02014b50, 20, 20, 0, 0, 0, dos_date, crc, size, size,
                  name_bytes.bytesize, 0, 0, 0, 0, 0, offset].pack('VvvvvvvVVVvvvvvVV')
      central << name_bytes
    end

    cd_offset = buffer.bytesize
    cd_size = central.bytesize
    eocd = [0x06054b50, 0, 0, files.size, files.size, cd_size, cd_offset, 0].pack('VvvvvVVv')

    buffer << central << eocd
    buffer
  end
end
