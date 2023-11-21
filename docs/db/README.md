# db/

This directory contains several MongoDB exported collections with sample data. Using these files, you will be able to
simulate a working environment to parse session results on the site.

Import each file as follows:
```bash
mongoimport --host localhost:27017 --db rv_cars --collection cars --file rv_cars.cars.json --jsonArray &&
mongoimport --host localhost:27017 --db rv_rankings --collection rankings --file rv_rankings.rankings.json --jsonArray &&
mongoimport --host localhost:27017 --db rv_seasons --collection seasons --file rv_seasons.seasons.json --jsonArray &&
mongoimport --host localhost:27017 --db rv_tracks --collection tracks --file rv_tracks.tracks.json --jsonArray &&
mongoimport --host localhost:27017 --db rv_users --collection users --file rv_users.users.json --jsonArray
```

In order for these imports to work from a Docker context, replace "--host localhost:27017" with "--host mongo:27017".
