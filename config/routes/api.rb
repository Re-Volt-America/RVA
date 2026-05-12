RVA::Application.routes.draw do
	scope :api, defaults: { :format => :json } do
		get 'weekly-schedule', to: 'api/exports#weekly_schedule'
		get 'today-track-list', to: 'api/exports#today_track_list'
	end
end
