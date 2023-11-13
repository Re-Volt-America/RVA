class CsvImportUsersService
  include ApplicationHelper

  require 'csv'

  def initialize(file)
    @file = file
  end

  def call
    csv = CSV.parse(File.open(@file))

    users = []
    csv.each do |user|

      user_hash = {
        :email => user[2],
        :password => user[4],
        :encrypted_password => user[3],
        :sign_in_count => 0,
        :failed_attempts => 0,
        :locale => "en_us",
        :username => user[1],
        :admin => false,
        :mod => false,
        :organizer => false,
        :country => user[0]
      }

      user = User.new(user_hash)
      user.build_profile
      user.build_stats
      user.confirm

      users << user
    end

    users
  end
end
