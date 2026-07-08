# Development-only diagnostic reports for the legacy -> model conversion.
namespace :rva do
  # Exports every track that could NOT be resolved to a Track model within its
  # Session's Season during conversion.
  #
  # Detection: read each session's persisted results_data. A
  # tracks[] entry whose track_id is null is an unresolved track; the race at the
  # same index carries the original legacy_track_name, which is the name we want.
  #
  # Output: an .xlsx (tmp/unresolved_tracks_<timestamp>.xlsx) with one row per
  # unique (Season name, track name) pair plus how many times it occurred.
  #
  # Development only.
  desc 'DEV ONLY: Export unresolved (Season, track name) pairs to an xlsx'
  task unresolved_tracks_report: :environment do
    abort 'This task is for development only.' unless Rails.env.development?

    require 'zip'
    require 'fileutils'

    $stdout.sync = true

    counts = Hash.new(0) # [season_name, track_name] => occurrences

    session_ids = Session.all.pluck(:id)
    total = session_ids.size
    scanned = 0

    puts "Scanning #{total} sessions for unresolved tracks..."

    started = Time.now
    fmt = lambda do |secs|
      secs = secs.to_i
      h, rem = secs.divmod(3600)
      m, s = rem.divmod(60)
      if h.positive?
        "#{h}h#{m}m#{s}s"
      elsif m.positive?
        "#{m}m#{s}s"
      else
        "#{s}s"
      end
    end

    session_ids.each do |id|
      session = Session.find(id)
      scanned += 1

      data = session.results_data
      tracks = data.is_a?(Hash) ? data['tracks'] : nil

      if tracks.is_a?(Array)
        season_name = session.ranking&.season&.name || '(unknown season)'

        tracks.each_with_index do |cell, i|
          next unless cell.is_a?(Hash)
          next unless cell['track_id'].nil? # unresolved track cell

          race = session.races[i]
          name = race&.legacy_track_name
          name = cell['track_name'] if name.to_s.strip.empty?
          name = '(unknown track)' if name.to_s.strip.empty?

          counts[[season_name, name]] += 1
        end
      end

      if (scanned % 50).zero? || scanned == total
        elapsed = Time.now - started
        rate = elapsed.positive? ? scanned / elapsed : 0.0
        eta = rate.positive? ? (total - scanned) / rate : 0
        pct = (100.0 * scanned / total).round
        puts "  [#{scanned}/#{total}] #{pct}%  elapsed #{fmt.call(elapsed)}  ETA #{fmt.call(eta)}  (#{rate.round(1)}/s, unresolved: #{counts.size})"
      end
    end

    rows = counts.map { |(season, name), count| [season, name, count] }
                 .sort_by { |season, name, _count| [season.to_s.downcase, name.to_s.downcase] }

    header = ['Season', 'Track Name', 'Occurrences']

    # --- Build a minimal .xlsx (a zip of XML parts) using rubyzip ---
    esc = lambda do |v|
      v.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;').gsub("'", '&apos;')
    end

    cell_xml = lambda do |col, rownum, val|
      ref = "#{('A'.ord + col).chr}#{rownum}"
      if val.is_a?(Numeric)
        %(<c r="#{ref}"><v>#{val}</v></c>)
      else
        %(<c r="#{ref}" t="inlineStr"><is><t xml:space="preserve">#{esc.call(val)}</t></is></c>)
      end
    end

    sheet_rows = ([header] + rows).each_with_index.map do |row, r|
      rownum = r + 1
      cells = row.each_with_index.map { |val, c| cell_xml.call(c, rownum, val) }.join
      %(<row r="#{rownum}">#{cells}</row>)
    end.join

    sheet_xml = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                %(<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">) +
                %(<sheetData>#{sheet_rows}</sheetData></worksheet>)

    content_types = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                    %(<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">) +
                    %(<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>) +
                    %(<Default Extension="xml" ContentType="application/xml"/>) +
                    %(<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>) +
                    %(<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>) +
                    %(</Types>)

    root_rels = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
                %(<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>) +
                %(</Relationships>)

    workbook = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
               %(<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">) +
               %(<sheets><sheet name="Unresolved Tracks" sheetId="1" r:id="rId1"/></sheets></workbook>)

    workbook_rels = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                    %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
                    %(<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>) +
                    %(</Relationships>)

    path = Rails.root.join('tmp', "unresolved_tracks_#{Time.now.strftime('%Y%m%d_%H%M%S')}.xlsx")
    FileUtils.mkdir_p(File.dirname(path))
    File.delete(path) if File.exist?(path)

    Zip::OutputStream.open(path.to_s) do |zos|
      {
        '[Content_Types].xml' => content_types,
        '_rels/.rels' => root_rels,
        'xl/workbook.xml' => workbook,
        'xl/_rels/workbook.xml.rels' => workbook_rels,
        'xl/worksheets/sheet1.xml' => sheet_xml
      }.each do |name, body|
        zos.put_next_entry(name)
        zos.write(body)
      end
    end

    puts "Done in #{fmt.call(Time.now - started)}. Unresolved (Season, track) pairs: #{rows.size}"
    puts "Report written to: #{path}"
  end

  # Exports every car that could NOT be resolved to a Car model within its
  # Session's Season during conversion.
  #
  # Detection: read each session's persisted results_data. In each result row's
  # cars[] array an unresolved car is stored as a "value" cell like "?CarName"
  # ("??" is the same unresolved car reused in the next race); we strip the
  # leading "?" to recover the name.
  #
  # Output: an .xlsx (tmp/unresolved_cars_<timestamp>.xlsx) with one row per
  # unique (Season name, car name) pair plus how many times it occurred.
  #
  # Development only.
  desc 'DEV ONLY: Export unresolved (Season, car name) pairs to an xlsx'
  task unresolved_cars_report: :environment do
    abort 'This task is for development only.' unless Rails.env.development?

    require 'zip'
    require 'fileutils'

    $stdout.sync = true

    counts = Hash.new(0) # [season_name, car_name] => occurrences

    session_ids = Session.all.pluck(:id)
    total = session_ids.size
    scanned = 0

    puts "Scanning #{total} sessions for unresolved cars..."

    started = Time.now
    fmt = lambda do |secs|
      secs = secs.to_i
      h, rem = secs.divmod(3600)
      m, s = rem.divmod(60)
      if h.positive?
        "#{h}h#{m}m#{s}s"
      elsif m.positive?
        "#{m}m#{s}s"
      else
        "#{s}s"
      end
    end

    session_ids.each do |id|
      session = Session.find(id)
      scanned += 1

      data = session.results_data
      session_rows = data.is_a?(Hash) ? data['rows'] : nil

      if session_rows.is_a?(Array)
        season_name = session.ranking&.season&.name || '(unknown season)'

        session_rows.each do |row|
          cells = row.is_a?(Hash) ? row['cars'] : nil
          next unless cells.is_a?(Array)

          last_unresolved = nil
          cells.each do |cell|
            next unless cell.is_a?(Hash)

            if cell['type'] == 'car'
              last_unresolved = nil
              next
            end

            value = cell['value']
            next unless value.is_a?(String)

            if value == '??'
              counts[[season_name, last_unresolved]] += 1 if last_unresolved
            elsif value.start_with?('?') && value.length > 1
              name = value[1..-1]
              counts[[season_name, name]] += 1
              last_unresolved = name
            else
              last_unresolved = nil
            end
          end
        end
      end

      if (scanned % 50).zero? || scanned == total
        elapsed = Time.now - started
        rate = elapsed.positive? ? scanned / elapsed : 0.0
        eta = rate.positive? ? (total - scanned) / rate : 0
        pct = (100.0 * scanned / total).round
        puts "  [#{scanned}/#{total}] #{pct}%  elapsed #{fmt.call(elapsed)}  ETA #{fmt.call(eta)}  (#{rate.round(1)}/s, unresolved: #{counts.size})"
      end
    end

    rows = counts.map { |(season, name), count| [season, name, count] }
                 .sort_by { |season, name, _count| [season.to_s.downcase, name.to_s.downcase] }

    header = ['Season', 'Car Name', 'Occurrences']

    # --- Build a minimal .xlsx (a zip of XML parts) using rubyzip ---
    esc = lambda do |v|
      v.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;').gsub("'", '&apos;')
    end

    cell_xml = lambda do |col, rownum, val|
      ref = "#{('A'.ord + col).chr}#{rownum}"
      if val.is_a?(Numeric)
        %(<c r="#{ref}"><v>#{val}</v></c>)
      else
        %(<c r="#{ref}" t="inlineStr"><is><t xml:space="preserve">#{esc.call(val)}</t></is></c>)
      end
    end

    sheet_rows = ([header] + rows).each_with_index.map do |row, r|
      rownum = r + 1
      cells = row.each_with_index.map { |val, c| cell_xml.call(c, rownum, val) }.join
      %(<row r="#{rownum}">#{cells}</row>)
    end.join

    sheet_xml = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                %(<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">) +
                %(<sheetData>#{sheet_rows}</sheetData></worksheet>)

    content_types = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                    %(<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">) +
                    %(<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>) +
                    %(<Default Extension="xml" ContentType="application/xml"/>) +
                    %(<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>) +
                    %(<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>) +
                    %(</Types>)

    root_rels = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
                %(<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>) +
                %(</Relationships>)

    workbook = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
               %(<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">) +
               %(<sheets><sheet name="Unresolved Cars" sheetId="1" r:id="rId1"/></sheets></workbook>)

    workbook_rels = %(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>) +
                    %(<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">) +
                    %(<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>) +
                    %(</Relationships>)

    path = Rails.root.join('tmp', "unresolved_cars_#{Time.now.strftime('%Y%m%d_%H%M%S')}.xlsx")
    FileUtils.mkdir_p(File.dirname(path))
    File.delete(path) if File.exist?(path)

    Zip::OutputStream.open(path.to_s) do |zos|
      {
        '[Content_Types].xml' => content_types,
        '_rels/.rels' => root_rels,
        'xl/workbook.xml' => workbook,
        'xl/_rels/workbook.xml.rels' => workbook_rels,
        'xl/worksheets/sheet1.xml' => sheet_xml
      }.each do |name, body|
        zos.put_next_entry(name)
        zos.write(body)
      end
    end

    puts "Done in #{fmt.call(Time.now - started)}. Unresolved (Season, car) pairs: #{rows.size}"
    puts "Report written to: #{path}"
  end
end
