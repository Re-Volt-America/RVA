# frozen_string_literal: true

server 'server02.rva.lat', :user => 'deploy', :roles => %w[web app], :primary => true
