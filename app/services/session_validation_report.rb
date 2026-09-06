# Turns a failed model validation somewhere in the Session import pipeline into
# a human-readable, per-field breakdown that points at the offending race,
# racer and field - instead of Mongoid's generic "Races is invalid" roll-up.
#
# Mongoid only surfaces "is invalid" on the parent because the real errors live
# on the embedded documents, so we walk them explicitly.
#
# Example output:
#
#   Session could not be saved, 3 validation problems found:
#     * Race "Museum 2": Laps can't be blank
#     * Race "Toy World 1", racer "SPEEDY": Best lap can't be blank
#     * Race "Toy World 1", racer "SPEEDY": Time can't be blank
#
#   These almost always mean a row in the uploaded log is missing a value or
#   has an unexpected column.
class SessionValidationReport
  HINT = 'These almost always mean a row in the uploaded log is missing a ' \
         'value or has an unexpected column.'.freeze

  # Build the full breakdown for a Session.
  def self.call(session)
    new(session).message
  end

  # Build a report for whatever document Mongoid reports as invalid. A Session
  # gets the full race/racer breakdown; any other document (Ranking, Season,
  # User, ...) falls back to its own field-level messages, which is still far
  # more useful than the generic roll-up.
  def self.for_document(document)
    return call(document) if document.is_a?(Session)

    generic_document_message(document)
  end

  def self.generic_document_message(document)
    return 'Validation failed for an unknown record.' if document.nil?

    document.valid?
    label = document.class.name
    messages = document.errors.full_messages
    return "#{label} validation failed." if messages.empty?

    header = "#{label} could not be saved — #{count_phrase(messages.size)}:"
    ([header] + messages.map { |message| "  • #{message}" }).join("\n")
  end

  def self.count_phrase(count)
    "#{count} validation #{count == 1 ? 'problem' : 'problems'} found"
  end

  def initialize(session)
    @session = session
  end

  def message
    details = problems
    return fallback if details.empty?

    header = "Session could not be saved — #{self.class.count_phrase(details.size)}:"
    ([header] + details.map { |detail| "  • #{detail}" } + ['', HINT]).join("\n")
  end

  # Collects specific, field-level messages from the session, its embedded races
  # and their racer entries, plus any result rows added during stats. The
  # generic "is invalid" roll-ups on the associations themselves are skipped in
  # favour of the underlying causes.
  def problems
    @session.valid?

    messages = []
    messages.concat(session_level_problems)

    @session.races.each_with_index do |race, index|
      messages.concat(race_problems(race, index))
    end

    @session.racer_result_entries.each_with_index do |result, index|
      messages.concat(result_problems(result, index))
    end

    messages
  end

  private

  def session_level_problems
    @session.errors.filter_map do |error|
      next if %w(races racer_result_entries team_result_entries).include?(error.attribute.to_s)

      "Session: #{error.full_message}"
    end
  end

  def race_problems(race, index)
    label = race.track_name.present? ? %(Race "#{race.track_name}") : "Race ##{index + 1}"
    messages = []

    race.valid?
    race.errors.each do |error|
      next if error.attribute.to_s == 'racer_entries'

      messages << "#{label}: #{error.full_message}"
    end

    race.racer_entries.each_with_index do |entry, entry_index|
      entry.valid?
      next if entry.errors.empty?

      racer = entry.username.present? ? %("#{entry.username}") : "##{entry_index + 1}"
      entry.errors.each do |error|
        messages << "#{label}, racer #{racer}: #{error.full_message}"
      end
    end

    messages
  end

  def result_problems(result, index)
    result.valid?
    return [] if result.errors.empty?

    label = result.username.present? ? %("#{result.username}") : "##{index + 1}"
    result.errors.map { |error| "Result #{label}: #{error.full_message}" }
  end

  def fallback
    "Session could not be saved: #{@session.errors.full_messages.join(', ')}"
  end
end
