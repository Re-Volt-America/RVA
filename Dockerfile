# Official base image for Ruby 3.2.2
FROM ruby:3.2.2

# Update & Upgrade Packages
RUN apt-get update -y
RUN apt-get upgrade -y

# Install NodeJS 16
RUN curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install nodejs -y

# Install Yarn
RUN npm install -g yarn

# Clone the RVA repository
RUN git clone https://github.com/Re-Volt-America/RVA /usr/src/app
WORKDIR /usr/src/app

# Bundle gems
RUN gem update --system
RUN gem install bundler
RUN bundler config set force_ruby_platform true
RUN bundler

# Yarn install
RUN yarn install
RUN yarn build
RUN yarn build:css

# Expose port 3000
EXPOSE 3000
