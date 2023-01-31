routes = case RVA::Application.rva_role
         when 'rva'
           %w(application user)
         when 'api'
           %w(api)
         else
           raise "Unknown RVA_ROLE: #{RVA::Application.rva_role}"
         end

routes.each do |r|
  load "config/routes/#{r}.rb"
end

