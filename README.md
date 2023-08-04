RVA
===
This is the code that powers the website and backend services for Re-Volt America (RVA), the American community around
the popular RC Cars racing game [Re-Volt](https://en.wikipedia.org/wiki/Re-Volt) from 1999.

In order to play online, we use [RVGL](https://rvgl.org/), a cross-platform rewrite / port of Re-Volt that runs natively
on a wide variety of platforms. This version of the game is also known for extending the original game experience with
support for custom, community-made content such as tracks and cars.

On RVA, we organise a series of online sessions where players from all around the world (primarily from the American
continent) get to race against each other, score points for the races they play, and get indexed into Re-Volt Americas'
official rankings.

RVGL Results               | RVGL Results
:-------------------------:|:-------------------------:
![screenshot_2023-02-07_20-03-15](https://github.com/Re-Volt-America/RVA/assets/26081543/f16e3fcd-3b68-446f-a988-dc2b26f97688)  |  ![screenshot_2023-03-26_13-48-21](https://github.com/Re-Volt-America/RVA/assets/26081543/4184effc-5872-4c9d-8b81-321c3fdae51c)

This project aims to be the main website for RVA, where online session logs will be uploaded and parsed into
RVA's results format to be displayed. The site will also help manage and maintain a wide range of information related to
RVA's internal scoring system.

Architecture
---
This repo contains the following components:
* Database models used by all parts of the network.
* The public website, including an admin interface used for some essential configuration.
* Several services which perform tasks like parsing and calculating results tables and leaderboards.

Framework
---
[Ruby on Rails](https://rubyonrails.org/): The full-stack framework.

Installation
---
These are general instructions you must follow in order to successfully mount the application.

Install the following services and configure them to run on their default ports:
* [Ruby 2.7.3](https://www.ruby-lang.org/en/)
  * OS X: [RVM](http://rvm.io/) is recommended over the default OS X Ruby. Here's a one-liner:
   `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
* [MongoDB 3+](https://www.mongodb.com/)
* [Redis 7+](http://redis.io/)
* [NodeJS 16+](https://nodejs.org/en/download/)
* [Yarn 1.22+](https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable/)

Ubuntu 18.04
---
The following installation instructions are specific to Linux, Ubuntu 18. This is the recommended OS to run
the application on. In a clean Ubuntu installation, run the following commands in super-user mode to install and run
all the required services and tools:

Enable super-user mode.
```bash
sudo su
```

Update & Upgrade Packages.
```bash
apt-get update -y && apt-get upgrade -y
```

Install MongoDB & Redis.
```bash
apt-get install mongodb -y && apt-get install redis-server -y
```

Start the services.
```bash
service mongodb start && service redis-server start
```

Docker
---
...

Mounting
---
Clone this repository to your machine and cd into it:
```bash
git clone https://github.com/Re-Volt-America/RVA
cd RVA
```

Ensure bundler is installed:
```bash
gem install bundle
```

Download and install dependencies:
```bash
bundle install
```

### Database Setup

#### MongoDB
You may edit your client configuration from the `config/mongoid.yml` file. Since Mongo is running on its default port,
you don't need to do anything here. Default settings should suffice. You may modify this file in case you want to change
the default connection strategy or other mongoid options.

In the project's root, there is a directory named `db/`. This directory contains several MongoDB exported collections
with sample data. Using these files, you will be able to simulate a working environment to parse session results on the
site.

Import each file as follows:
```bash
mongoimport --db rva_development --collection users --file rv_cars.cars.json --jsonArray
mongoimport --db rva_development --collection users --file rv_rankings.rankings.json --jsonArray
mongoimport --db rva_development --collection users --file rv_seasons.seasons.json --jsonArray
mongoimport --db rva_development --collection users --file rv_tracks.tracks.json --jsonArray
mongoimport --db rva_development --collection users --file rv_users.users.json --jsonArray
```

#### Redis
The caching configuration and connection to the Redis database you may find here:
* [config/environments/development.rb](https://github.com/Re-Volt-America/RVA/blob/3774cd04472ea3e1aff52f9f602339083721af00/config/environments/development.rb#L23)
* [config/environments/production.rb](https://github.com/Re-Volt-America/RVA/blob/3774cd04472ea3e1aff52f9f602339083721af00/config/environments/production.rb#L58)

### Environment
Run the following shell command from the RVA repo to start the application:
```
rails rva -b HOST -p PORT              # Public website on http://HOST:PORT
```

Replace HOST and PORT with the desired host and port you would like to use for the website. For example, you could run
the application on host "localhost" and port 3000.

At this point, you should be able to visit the website at http://localhost:3000, but there isn't much to see and you
have no account to login with. To create an account, we'll first get a Bungee and Lobby running, and then do the
standard registration process.

Create an admin user
---
From the RVA repo, run `rails c` to start a Rails shell session.

To create the initial admin user for the website, type this command into the rails console, replacing the data fields
with your account info:
```
User.create!(
    email: 'test@example.com',
    username: 'Test',
    password: 'password',
    password_confirmation: 'password',
    admin: true
).confirm
```

Contributing
---
Please read the full instructions on how to contribute to this project found in the
[CONTRIBUTING.md](https://github.com/Re-Volt-America/RVA/blob/master/docs/CONTRIBUTING.md) file.

Governance
---
The lead maintainer of this project is [BGM](https://github.com/BGMP). As the project grows, we'll scale the governance
model to meet those needs.

Licence
---
RVA Website/Backend is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
Public Licence as published by the Free Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public Licence for more
details.

A copy of the GNU Affero General Public Licence is included in the file LICENCE, and can also be found at
https://www.gnu.org/licenses/agpl-3.0.en.html.

The AGPL license is quite restrictive, please make sure you understand it. If you run a modified version of this
software as a network service, anyone who can use that service must also have access to the modified source code.

Thanks to
---
### Developers
* [Marco Roth](https://github.com/marcoroth). For helping with the *esbuild* migration and solving some HAML issues.

### Sponsors
* [Gabriel Carnielli](https://github.com/RVGforce).
* [Mateusz Kobylański](https://github.com/Nickurn).
* [Benjamin Mosso](https://github.com/bamm99).
* [Juan Pablo Rosas](https://github.com/yeipills).
* [Leandro Rodriguez](https://github.com/TioRotti).
* [Lautaro](https://github.com/Burdang).
