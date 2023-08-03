RVA
===
This is the code that powers the website and backend services for Re-Volt America (RVA), the American community around
the popular RC Cars racing game [Re-Volt](https://en.wikipedia.org/wiki/Re-Volt) from 1999.

In order to play online, we use [RVGL](https://rvgl.org/), a cross-platform rewrite / port of Re-Volt that runs natively
on a wide variety of platforms. This version of the game is also known for extending the original game experience with
support for custom, community-made content such as tracks and cars.

On RVA, we organise a series of online sessions were players from all around the world (primarily from the American
continent) get to race against each other, score points for the races they play, and get indexed into Re-Volt Americas'
official rankings.

This project aims to be the main website for RVA, where online session logs will be uploaded and parsed into
RVA's results format to be displayed. The site will also help manage and maintain a wide range of information related to
RVA's internal scoring system.

Architecture
---
This repo contains the following components:
* Database models used by all parts of the network.
* The public website, including an admin interface used for some essential configuration.
* Several services which perform tasks like parsing and calculating results tables and leaderboards.

Installation
---
Install the following services and configure them to run on their default ports:
* [Ruby 2.7](https://www.ruby-lang.org/en/)
  * OS X: [RVM](http://rvm.io/) is recommended over the default OS X Ruby. Here's a one-liner:
   `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
* [MongoDB 3.6.3](https://www.mongodb.com/)
* [Redis](http://redis.io/)

Ensure bundler is installed: `gem install bundle`

Run `bundle install` to download and install dependencies.

Database Setup
---
Start MongoDB and Redis with default settings.

Backend App
---
Run the following shell command from the RVA repo to start the application:
```
rails rva              # Public website on http://localhost:3000
```

At this point, you should be able to visit the website at http://localhost:3000, but there isn't much to see and you
have no account to login with. To create an account, we'll first get a Bungee and Lobby running, and then do the
standard registration process.

Create an admin user
---
To create the initial admin user for the website, type this command into rails console, replacing the data fields with
your account info:
```
User.create!(
    email: 'test@example.com',
    username: 'Test',
    password: 'password',
    password_confirmation: 'password',
    admin: true
).confirm
```
