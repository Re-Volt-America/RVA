// This script initializes MongoDB with the necessary databases and users

// Connect to MongoDB as the root user
db = db.getSiblingDB('admin');

const appUsername = _getEnv('MONGO_INITDB_ROOT_USERNAME');
const appPassword = _getEnv('MONGO_INITDB_ROOT_PASSWORD');

// Define mappings between databases and their collections
const databaseCollectionMap = [
    { database: 'rv_cars', collection: 'cars' },
    { database: 'rv_rankings', collection: 'rankings' },
    { database: 'rv_repos', collection: 'repositories' },
    { database: 'rv_seasons', collection: 'seasons' },
    { database: 'rv_sessions', collection: 'sessions' },
    { database: 'rv_teams', collection: 'teams' },
    { database: 'rv_tracks', collection: 'tracks' },
    { database: 'rv_users', collection: 'users' },
    { database: 'rv_weekly_schedules', collection: 'weekly_schedules' }
];

// Create databases, collections, and set up indexes
databaseCollectionMap.forEach(({ database, collection }) => {
    db = db.getSiblingDB(database);

    // Create database by creating the collection
    db.createCollection(collection);

    // Create user for this specific database with appropriate permissions
    db.createUser({
        user: appUsername,
        pwd: appPassword,
        roles: [
            { role: 'readWrite', db: database },
            { role: 'dbAdmin', db: database }
        ]
    });

    print(`Created database ${database} with collection ${collection} and assigned user 'aukko' to it`);
});

print('MongoDB initialization completed successfully');
