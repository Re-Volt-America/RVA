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
        :username => user[1],
        :email => user[2],
        :password => user[3],
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
