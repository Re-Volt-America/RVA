class TournamentBannerUploader < Shrine
  Attacher.validate do
    validate_mime_type %w(image/jpeg image/png)
    validate_max_size 5 * 1024 * 1024  # 5 Mb
  end
end
