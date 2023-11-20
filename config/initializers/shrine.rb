require 'shrine'
require 'shrine/storage/file_system'

Shrine.storages = {
  :cache => Shrine::Storage::FileSystem.new('public', :prefix => 'uploads/cache'), # temporary
  :store => Shrine::Storage::FileSystem.new('public', :prefix => 'uploads') # permanent
}

Shrine.plugin :mongoid, :validations => false
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data    # extracts metadata for assigned cached files
