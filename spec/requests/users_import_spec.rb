require 'rails_helper'

RSpec.describe '/users/import', :type => :request do
  after(:each) do
    User.delete_all
  end

  # Rows are country, username, email, password (no header row).
  def build_users_csv
    Tempfile.new(['users', '.csv']).tap do |file|
      file.write <<~CSV
        US,importeduser,imported@example.test,pässword123
      CSV
      file.rewind
    end
  end

  def import_users(csv_file)
    post '/users/import', :params => { :file => Rack::Test::UploadedFile.new(csv_file.path, 'text/csv') }
  end

  it 'imports the users for an admin' do
    sign_in create(:user, :admin => true)
    csv_file = build_users_csv

    expect { import_users(csv_file) }.to change(User, :count).by(1)

    imported = User.where(:email => 'imported@example.test').first
    expect(imported.username).to eq('IMPORTEDUSER')
    expect(imported.valid_password?('pässword123')).to be(true)

    csv_file.close
    csv_file.unlink
  end

  it 'does not let a regular user import users' do
    sign_in create(:user)
    csv_file = build_users_csv

    expect { import_users(csv_file) }.not_to change(User, :count)
    expect(response).to redirect_to(root_path)

    csv_file.close
    csv_file.unlink
  end
end
