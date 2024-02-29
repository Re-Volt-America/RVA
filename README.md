# RVA [![License: GPL v3](https://img.shields.io/github/license/Re-Volt-America/RVA)](https://www.gnu.org/licenses/agpl-3.0.en.html)
This is the code that powers the website and backend services for Re-Volt America (RVA), the American community around
the popular RC Cars racing game [Re-Volt](https://en.wikipedia.org/wiki/Re-Volt) from 1999.

In order to play online, we use [RVGL](https://rvgl.org/), a cross-platform rewrite / port of Re-Volt that runs natively
on a wide variety of platforms. This version of the game is also known for extending the original game experience with
support for custom, community-made content such as tracks and cars.

In RVA, we organise a series of online sessions where players from all around the world (primarily from the American
continent) get to race against each other, score points for the races they play, and get indexed into Re-Volt Americas'
official rankings.

|                                                          RVGL Results                                                          |                                                          RVGL Results                                                          |
|:------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------:|
| ![screenshot_2023-02-07_20-03-15](https://github.com/Re-Volt-America/RVA/assets/26081543/339632ce-564c-45cc-a08b-dad1802bb602) | ![screenshot_2022-11-05_15-30-13](https://github.com/Re-Volt-America/RVA/assets/26081543/35e9b74b-f1b4-4647-9800-9df12a2efece) |

This project aims to be the main website for RVA, where online session logs will be uploaded and parsed into
RVA's results format to be displayed. The site will also help manage and maintain a wide range of information related to
RVA's internal scoring system.

Table of Contents
===
* [Architecture](#architecture)
* [Installation](#installation)
    * [Ubuntu 18.04](#ubuntu-1804)
        * [Download & Install](#download--install)
        * [Mounting](#mounting)
        * [Database Setup](#database-setup)
            * [MongoDB](#mongodb)
            * [Redis](#redis)
        * [Environment](#environment)
* [Docker](#docker)
* [Contributing](#contributing)
* [Governance](#governance)
* [Licence](#licence)
* [Thanks To](#thanks-to)
    * [Developers](#developers)
    * [Sponsors](#sponsors)

## Architecture
This repo contains the following components:
* Database models used by all parts of the network.
* The public website, including an admin interface used for some essential configuration.
* Several services which perform tasks like parsing and calculating results tables and leaderboards.

This project was built using [Ruby on Rails](https://rubyonrails.org/), the full-stack framework.

## Installation
Install the following services and configure them to run on their default ports if needed:
* [Ruby 3.2.2](https://www.ruby-lang.org/en/)
  * OS X: [RVM](http://rvm.io/) is recommended over the default OS X Ruby. Here's a one-liner:
   `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
* [MongoDB 3+](https://www.mongodb.com/)
* [Redis 7+](http://redis.io/)
* [NodeJS 16+](https://nodejs.org/en/download/)
* [Yarn 1.22+](https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable/)

## Database Setup
Both MongoDB and Redis come configured to work on "localhost" by default. If you run the application with Docker, make
sure to change "localhost" for "mongo" and "redis" respectively. For example, in the `mongoid.yml` file, you would have
to change `- "localhost:27017"` to `- "mongo:27017"`.

### MongoDB
You may edit your MongoDB client configuration from the `config/mongoid.yml` file. Since Mongo is running on its default
port, you don't need to do anything here. Default settings should suffice. You may modify this file in case you want to
change the default connection strategy or other mongoid options.

### Redis
The caching configuration and connection to the Redis database you may find here:
* [config/environments/development.rb](https://github.com/Re-Volt-America/RVA/blob/3774cd04472ea3e1aff52f9f602339083721af00/config/environments/development.rb#L23)
* [config/environments/production.rb](https://github.com/Re-Volt-America/RVA/blob/3774cd04472ea3e1aff52f9f602339083721af00/config/environments/production.rb#L58)

Very much like it happens with Mongo, since Redis is running on its default port, you don't need to do anything here.
Default settings should suffice. You may modify this file in case you want to change the default connection info or
other Redis options.

### Environment
Run the following shell command from the RVA repo to start the application:
```
rails rva -b HOST -p PORT              # Public website on http://`<host>`:`<port>`
```

Replace `<host>` and `<port>` with the desired host and port you would like to use for the website. For example, you
could run the application on host 0.0.0.0 and port 80 to make the site accessible from outside localhost.

At this point, you should be able to visit the website at http://`<host>`:`<port>`.

## Contributing
Please read the full instructions on how to contribute to this project found in the
[CONTRIBUTING.md](https://github.com/Re-Volt-America/RVA/blob/master/docs/CONTRIBUTING.md) file.

You may also have a look at the [repository wiki](https://github.com/Re-Volt-America/RVA/wiki).

## Governance
The lead maintainer of this project is [BGM](https://github.com/BGMP). As the project grows, we'll scale the governance
model to meet its needs.

## Thanks to
### Developers
* [Marco Roth](https://github.com/marcoroth). For helping with the *esbuild* migration and solving some HAML issues.
* [Nicolás Duque](https://github.com/nickskyline). For testing the installation instructions on Linux platforms,
beta-testing the site on its early stages, and helping with i18n.

### Sponsors
* [Vicente Aguilera](https://github.com/ViceAguilera).
* [Gabriel Carnielli](https://github.com/RVGforce).
* [Dario Chaile](https://github.com/Burdang).
* [Benjamín Contreras](https://github.com/Benjax14).
* [Benjamín Ferrada](https://github.com/BenjaFerrada).
* [Josafat Jimenez](https://github.com/JosafatJimenezB).
* [Mateusz Kobylański](https://github.com/Nickurn).
* [Jorge Matamala](https://github.com/jorgematamala).
* [Benjamin Mosso](https://github.com/bamm99).
* [Leandro Rodriguez](https://github.com/TioRotti).
* [Juan Pablo Rosas](https://github.com/yeipills).
