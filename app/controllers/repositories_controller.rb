class RepositoriesController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :authenticate_admin, :except => [:index, :show]
  before_action :set_repository, :only => [:show, :edit, :update, :destroy]

  # GET /repositories or /repositories.json
  def index
    @repositories = Repository.all
  end

  # GET /repositories/1 or /repositories/1.json
  def show
    @repositories = Repository.all
    @repository = Repository.find_by!(:id => params[:id])
    @revs = []

    if @repository.open?
      Github.repos.commits.list(@repository.namespace, @repository.repo, @repository.branch,
                                :per_page => 100).each do |r|
        author_name = r.commit.committer.name
        author_email = r.commit.committer.email
        message = r.commit.message
        date = r.commit.committer.date
        sha = r.sha

        @revs.push(Revision.new(@repository.provider, author_name, author_email, message, date, sha))
      end
    end

    @revs = Kaminari.paginate_array(@revs).page(params[:page]).per(20)
    @count = (@revs.current_page - 1) * (@revs.limit_value + 1)
  end

  # GET /repositories/new
  def new
    @repository = Repository.new
  end

  # GET /repositories/1/edit
  def edit; end

  # POST /repositories or /repositories.json
  def create
    @repository = Repository.new(repository_params)

    respond_to do |format|
      if @repository.save
        format.html { redirect_to repository_url(@repository), :notice => 'Repository was successfully created.' }
        format.json { render :show, :status => :created, :location => @repository }
      else
        format.html { render :new, :status => :unprocessable_entity }
        format.json { render :json => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repositories/1 or /repositories/1.json
  def update
    respond_to do |format|
      if @repository.update(repository_params)
        format.html { redirect_to repository_url(@repository), :notice => 'Repository was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @repository }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1 or /repositories/1.json
  def destroy
    @repository.destroy!

    respond_to do |format|
      format.html { redirect_to repositories_url, :notice => 'Repository was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  helper do
    def commit_url(sha)
      "https://#{@repository.provider}.com/#{@repository.namespace}/#{@repository.repo}/commit/#{sha}"
    end
  end

  helper do
    def provider_user_url(username)
      "https://#{@repository.provider}.com/#{username}"
    end
  end

  class Revision
    attr_reader :author_name, :author_email, :message, :date, :sha
    attr_writer :deployed, :latest, :author

    def initialize(provider, author_name, author_email, message, date, sha)
      @provider = provider
      @author_name = author_name
      @author_email = author_email
      @message = message
      @date = date
      @sha = sha
    end

    def sha_brief
      sha[0..6]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repository
    @repository = Repository.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def repository_params
    params.require(:repository).permit(:title, :description, :visible, :provider, :namespace, :repo, :open, :branch)
  end
end
