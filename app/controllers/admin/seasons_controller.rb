module Admin
  class SeasonsController < BaseController
    include SeasonCarUsage

    def stats
      @seasons = Season.all.reverse
      @season = resolve_season

      @season_stats_filters = season_stats_filter_params(:default_category => SYS::CATEGORY::ROOKIE)
      @season_car_category_options = SYS::CATEGORY::RVGL_NUMBERS_MAP.map { |name, value| [name.to_s, value] }
      @season_cars_by_name = season_cars_by_name(@season)
      @season_car_usage = @season.nil? ? {} : build_season_car_usage(@season, @season_stats_filters)
    end

    # Full-season car usage as a multi-sheet .xlsx (one sheet per car class).
    # Ignores the on-page date/class filters on purpose so the download is the
    # complete picture for the season.
    def stats_export
      season = resolve_season

      if season.nil?
        redirect_to(admin_season_stats_path, :alert => 'There is no season to export.') and return
      end

      usage = build_season_car_usage(season, :from_date => nil, :to_date => nil, :car_category => nil)
      workbook = build_car_usage_workbook(season, usage)

      send_data workbook.to_bytes,
                :filename => car_usage_filename(season),
                :type => SimpleXlsx::MIME_TYPE
    end

    private

    def resolve_season
      if params[:season_id].present?
        Season.where(:id => params[:season_id]).first || current_season
      else
        current_season
      end
    end

    # Groups the season's usage into one worksheet per car class, plus an
    # "Uncategorised" sheet for names that no longer resolve to a Car record.
    def build_car_usage_workbook(season, usage)
      cars_by_name = season_cars_by_name(season)
      by_category = Hash.new { |hash, key| hash[key] = [] }
      uncategorised = []

      usage.each do |car_name, uses|
        category = cars_by_name[car_name.downcase]&.category
        (category.nil? ? uncategorised : by_category[category]) << [car_name, uses]
      end

      xlsx = SimpleXlsx.new
      SYS::CATEGORY::RVGL_NUMBERS_MAP.each do |label, value|
        rows = by_category[value]
        next if rows.empty?

        xlsx.add_sheet(label.to_s, [['Car', 'Times used']] + rows)
      end
      xlsx.add_sheet('Uncategorised', [['Car', 'Times used']] + uncategorised) if uncategorised.any?

      xlsx
    end

    def car_usage_filename(season)
      slug = season.name.to_s.parameterize.presence || 'season'
      "car-usage-#{slug}-#{Date.current.iso8601}.xlsx"
    end
  end
end
