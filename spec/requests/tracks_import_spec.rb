require 'rails_helper'

RSpec.describe '/tracks/import', :type => :request do
  after(:each) do
    TrackRating.delete_all
    Track.delete_all
    Season.delete_all
    User.delete_all
  end

  def build_tracks_csv
    Tempfile.new(['tracks', '.csv']).tap do |file|
      file.write <<~CSV
        name,short_name,difficulty,length,folder_name,author,stock,lego,average_lap_time
        Airport 1,AP1,0,612,airport1,Xarc,true,false,45
      CSV
      file.rewind
    end
  end

  it 'carries ratings forward when importing a repeated track into a new season' do
    previous_season = create(:season, :name => 'Season 1', :start_date => Date.new(2025, 1, 1), :current => false)
    current_season = create(:season, :name => 'Season 2', :start_date => Date.new(2026, 1, 1), :current => true)
    previous_track = create(:track, :season => previous_season, :name => 'Airport 1')

    create(:track_rating, :track => previous_track, :user => create(:user),
                          :gameplay_rating => 5, :visuals_rating => 4, :audio_rating => 3, :fun_rating => 4)
    create(:track_rating, :track => previous_track, :user => create(:user),
                          :gameplay_rating => 2, :visuals_rating => 2, :audio_rating => 3, :fun_rating => 2)

    csv_file = build_tracks_csv

    expect do
      post import_tracks_path, :params => { :file => Rack::Test::UploadedFile.new(csv_file.path, 'text/csv'),
                                            :season => current_season.id.to_s }
    end.to change(Track, :count).by(1).and change(TrackRating, :count).by(2)

    csv_file.close
    csv_file.unlink

    imported_track = Track.where(:season_id => current_season.id, :name => 'Airport 1').first

    expect(imported_track).not_to be_nil
    expect(imported_track.rating_count).to eq(2)
    expect(imported_track.display_rating).to eq(3.0)
  end
end
