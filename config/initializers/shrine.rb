require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/memory'
require 'shrine/storage/s3'

if Rails.env.test?
  Shrine.storages = {
    :cache => Shrine::Storage::Memory.new, # temporary
    :store => Shrine::Storage::Memory.new # permanent
  }
else
  Shrine.storages = {
    :cache => Shrine::Storage::FileSystem.new('public', :prefix => 'uploads/cache'), # temporary
    :store => Shrine::Storage::FileSystem.new('public', :prefix => 'uploads') # permanent
  }
end

Shrine.plugin :mongoid, :validations => false
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data    # extracts metadata for assigned cached files
