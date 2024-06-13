# Official base image for Ruby 3.2.2
FROM ruby:3.2.2

ENV NODE_VERSION=16.13.0
ENV NVM_DIR=/root/.nvm
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Update & Upgrade Packages
RUN apt-get update -y
RUN apt-get upgrade -y

# Install NodeJS 16
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

# Install Yarn
RUN npm install -g yarn

# Clone the RVA repository
RUN git clone -b docker https://github.com/Re-Volt-America/RVA /usr/src/app
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
