module TracksHelper
  # @param track [Track]
  # @return [String] DOM id for the track's rating summary element, shared between the tracks views and the
  # track_ratings turbo_stream response so the latter can target and replace the former.
  def track_rating_summary_dom_id(track)
    dom_id(track, :rating_summary)
  end
end
