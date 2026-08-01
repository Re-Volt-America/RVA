# Builds the "car usage in a season" breakdown used by the season stats pages.
#
# This logic used to be duplicated verbatim between Admin::SeasonsController and
# SeasonsController. It now lives here in one place so both (and any future
# controller) can share it by simply `include SeasonCarUsage`.
#
# All methods are private instance methods on the including controller and read
# the request `params` for the filter values, so nothing needs to be passed in.
module SeasonCarUsage
  extend ActiveSupport::Concern

  private

  # Returns an ordered { car_name => times_used } hash for the given season,
  # honouring the date-range and car-class filters.
  def build_season_car_usage(season, filters)
    usage = Hash.new(0)

    # Load the season's cars ONCE. Cars are always season-scoped (see
    # CsvImportSessionsService#find_car_by_name), so every racer_entry.car_id
    # points to a car in here. Resolving from these hashes avoids a per-entry
    # Car query (the N+1 that made this page slow).
    season_cars = season.cars.to_a
    cars_by_id = season_cars.index_by(&:id)
    season_cars_by_name = season_cars.group_by { |car| car.name.to_s.downcase }

    sessions_for_season(season, filters).each do |session|
      next unless include_session_by_date?(session, filters)

      merge_session_car_usage!(usage, session, filters, cars_by_id, season_cars_by_name)
    end

    usage.sort_by { |_, count| -count }.to_h
  end

  # Maps a season's cars by their (downcased) name so a usage entry, which is
  # keyed by car name, can be resolved back to a Car record for its thumbnail
  # and link. Uses the same normalisation as the usage counting above.
  def season_cars_by_name(season)
    return {} if season.nil?

    season.cars.to_a
          .group_by { |car| car.name.to_s.downcase }
          .transform_values(&:first)
  end

  # All sessions in the season, fetched in a single query instead of one query
  # per ranking. The date range is pushed into Mongo so filtered views also
  # transfer fewer documents.
  def sessions_for_season(season, filters)
    ranking_ids = season.rankings.pluck(:id)
    return Session.none if ranking_ids.empty?

    scope = Session.where(:ranking_id.in => ranking_ids)
    scope = scope.where(:date.gte => filters[:from_date]) if filters[:from_date]
    scope = scope.where(:date.lte => filters[:to_date]) if filters[:to_date]
    scope
  end

  def merge_session_car_usage!(usage, session, filters, cars_by_id, season_cars_by_name)
    session.races.each do |race|
      race.racer_entries.each do |entry|
        # Read car_id (a raw embedded field, no query) and resolve from the
        # preloaded hash rather than calling entry.car / entry.car_name.
        car = entry.car_id && cars_by_id[entry.car_id]
        car_name = (car&.name || entry.legacy_car_name).to_s.strip
        next if car_name.blank?
        next if car_name.start_with?('!')
        next if car_name.match?(/\Ax+\z/i)
        next unless include_car_by_category?(car, car_name, filters, season_cars_by_name)

        usage[car_name] += 1
      end
    end
  end

  # `default_category` is used only when the request carries no `car_category`
  # param at all (i.e. the very first, unfiltered page load). Once the filter
  # form has been submitted the param is always present, so an explicit
  # "All classes" (blank) choice is preserved rather than being overridden.
  def season_stats_filter_params(default_category: nil)
    from_date = parse_filter_date(params[:from_date])
    to_date = parse_filter_date(params[:to_date])

    if from_date && to_date && from_date > to_date
      from_date, to_date = to_date, from_date
    end

    category_param = params.key?(:car_category) ? params[:car_category] : default_category

    {
      :from_date => from_date,
      :to_date => to_date,
      :car_category => parse_filter_category(category_param),
      :from_date_value => from_date&.strftime('%Y-%m-%d') || params[:from_date].to_s,
      :to_date_value => to_date&.strftime('%Y-%m-%d') || params[:to_date].to_s,
      :car_category_value => category_param.to_s
    }
  end

  def parse_filter_date(date_param)
    return nil if date_param.blank?

    Date.parse(date_param.to_s)
  rescue ArgumentError
    nil
  end

  def parse_filter_category(category_param)
    return nil if category_param.blank?

    category = Integer(category_param)
    SYS::CATEGORY::RVGL_NUMBERS_MAP.values.include?(category) ? category : nil
  rescue ArgumentError, TypeError
    nil
  end

  def include_session_by_date?(session, filters)
    session_date = session.date&.to_date
    return false if session_date.nil?
    return false if filters[:from_date] && session_date < filters[:from_date]
    return false if filters[:to_date] && session_date > filters[:to_date]

    true
  end

  def include_car_by_category?(car, car_name, filters, season_cars_by_name)
    return true if filters[:car_category].nil?

    car_category = car&.category
    return car_category == filters[:car_category] unless car_category.nil?

    candidates = season_cars_by_name[car_name.downcase] || []
    candidates.any? { |candidate| candidate.category == filters[:car_category] }
  end
end
