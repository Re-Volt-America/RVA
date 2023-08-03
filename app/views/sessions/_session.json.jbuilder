json.extract! session, :id, :host, :version, :physics, :protocol, :number, :date, :sessionlog, :created_at, :updated_at
json.url session_url(session, :format => :json)
