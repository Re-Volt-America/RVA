require 'rails_helper'

RSpec.describe '/cars/import', :type => :request do
  after(:each) do
    Car.delete_all
    Season.delete_all
    User.delete_all
  end

  def build_cars_csv(car_name = 'Toyeca')
    Tempfile.new(['cars', '.csv']).tap do |file|
      file.write <<~CSV
        name,speed,accel,weight,multiplier,folder_name,author,stock
        #{car_name},36,2.1,1.6,1.0,toyeca,Acclaim,true
      CSV
      file.rewind
    end
  end

  def import_cars(csv_file, season)
    post import_cars_path, :params => { :file => Rack::Test::UploadedFile.new(csv_file.path, 'text/csv'),
                                        :season => season.id.to_s, :category => '0' }
  end

  it 'imports the cars for an admin and keeps accented letters in names' do
    season = create(:season)
    sign_in create(:user, :admin => true)
    csv_file = build_cars_csv('Toyéca')

    expect { import_cars(csv_file, season) }.to change(Car, :count).by(1)
    expect(Car.where(:name => 'Toyéca', :season_id => season.id).exists?).to be(true)

    csv_file.close
    csv_file.unlink
  end

  it 'sends a signed out visitor to the sign in page and imports nothing' do
    season = create(:season)
    csv_file = build_cars_csv

    expect { import_cars(csv_file, season) }.not_to change(Car, :count)
    expect(response).to redirect_to(new_user_session_path)

    csv_file.close
    csv_file.unlink
  end

  it 'does not let a regular user import cars' do
    season = create(:season)
    sign_in create(:user)
    csv_file = build_cars_csv

    expect { import_cars(csv_file, season) }.not_to change(Car, :count)
    expect(response).to redirect_to(root_path)

    csv_file.close
    csv_file.unlink
  end
end
