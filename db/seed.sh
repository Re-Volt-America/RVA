mongoimport --host mongo:27017 --db rv_cars --collection cars --file rv_cars.cars.json --jsonArray && \
  mongoimport --host mongo:27017 --db rv_rankings --collection rankings --file rv_rankings.rankings.json --jsonArray && \
  mongoimport --host mongo:27017 --db rv_seasons --collection seasons --file rv_seasons.seasons.json --jsonArray && \
  mongoimport --host mongo:27017 --db rv_tracks --collection tracks --file rv_tracks.tracks.json --jsonArray && \
  mongoimport --host mongo:27017 --db rv_users --collection users --file rv_users.users.json --jsonArray
