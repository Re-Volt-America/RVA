require 'fileutils'

module Api
  class ExportsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_bot!

    # GET /api/weekly-schedule.json
    def weekly_schedule
      weekly = WeeklySchedule.desc(:created_at).first
      return render json:({ error: 'no_weekly_schedule' }), status: :not_found if weekly.nil?

      base = ENV['RVA_BASE_URL'].presence || request.base_url

      payload = {
        id: weekly.id.to_s,
        start_date: weekly.start_date,
        generated_at: Time.now,
        tracklists_count: weekly.track_lists.size,
        # provide URL template and first-index example
        image_url_template: "#{base}/api/tracklist/{weekly_id}/{index}.png",
        example_image_url: "#{base}/api/tracklist/#{weekly.id}/0.png"
      }

      write_public_file('weekly-schedule.json', payload)

      render json: payload
    end

    # GET /api/today-track-list.json
    def today_track_list
      weekly = WeeklySchedule.desc(:created_at).first
      return render json:({ error: 'no_weekly_schedule' }), status: :not_found if weekly.nil?

      base = ENV['RVA_BASE_URL'].presence || request.base_url

      start_date = weekly.start_date || Date.today
      index = (Date.today - start_date).to_i

      payload = {
        date: Date.today,
        weekly_schedule_id: weekly.id.to_s,
        tracklist_index: index,
        image_url: "#{base}/api/tracklist/#{weekly.id}/#{index}.png"
      }

      write_public_file('today-track-list.json', payload)

      render json: payload
    end

    private

    def authenticate_bot!
      token = request.headers['X-Bot-Token'] || params[:token]
      expected = ENV['RVA_BOT_API_TOKEN']
      if expected.blank? || token.blank? || !ActiveSupport::SecurityUtils.secure_compare(expected.to_s, token.to_s)
        render json:({ error: 'unauthorized' }), status: :unauthorized
      end
    end

    def write_public_file(filename, payload)
      dir = Rails.root.join('public', 'api')
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      path = dir.join(filename)
      File.open(path, 'w') do |f|
        f.write(JSON.pretty_generate(payload.as_json))
      end
    rescue => e
      Rails.logger.error("Failed to write public API file "+ path.to_s + ": " + e.message)
    end
  end
end
