class CsvImportUsersService
  include ApplicationHelper

  require 'csv'

  def initialize(file)
    @file = file
  end

  def call
    # Read the uploaded file itself instead of opening a path from the request (CodeQL rb/path-injection)
    csv = CSV.parse(@file.read.force_encoding(Encoding::UTF_8))

    users = []
    csv.each do |row|
      next if row.empty?
      next if row.include?(nil)

      user_hash = {
        :username => row[1],
        :email => row[2],
        :password => row[3],
        :country => row[0]
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
