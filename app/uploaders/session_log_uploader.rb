class SessionLogUploader < Shrine
  Attacher.validate do
    validate_max_size 1024 * 1024  # 1 Mb
  end
end
