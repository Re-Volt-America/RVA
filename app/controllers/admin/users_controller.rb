module Admin
  # User Administration: a read-only overview of every account, with search and
  # role filtering. (Relocated here from the old /admin/users members page.)
  class UsersController < BaseController
    ROLE_FIELDS = { 'admin' => :admin, 'mod' => :mod, 'organizer' => :organizer, 'sponsor' => :sponsor }.freeze

    def index
      users = User.all.order_by(:created_at.desc)

      if params[:q].present?
        pattern = Regexp.new(Regexp.escape(params[:q].to_s.strip), Regexp::IGNORECASE)
        users = users.any_of({ :username => pattern }, { :email => pattern }, { :country => pattern })
      end

      role_field = ROLE_FIELDS[params[:role]]
      users = users.where(role_field => true) if role_field

      @q = params[:q]
      @role = params[:role]
      @users = Kaminari.paginate_array(users.to_a).page(params[:page]).per(20)
      @count = (@users.current_page - 1) * @users.limit_value
    end
  end
end
