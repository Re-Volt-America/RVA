class ApplicationMailer < ActionMailer::Base
  default :from => ORG::EMAIL
  layout 'mailer'
end
