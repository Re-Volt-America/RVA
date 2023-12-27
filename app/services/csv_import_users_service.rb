class CsvImportUsersService
  include ApplicationHelper

  require 'csv'

  def initialize(file)
    @file = file
  end

  def call
    csv = CSV.parse(File.open(@file))

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
