module RepositoriesHelper
  # NOTE: The staff team will likely not lie about their github accounts... but it'd be nice to
  # add a separate field for them to have internal VCS accounts.
  def user_by_github(github)
    Rails.cache.fetch("User##{github}") do
      User.find { |u| (u.profile.github.eql?(github) && user_is_staff?(u)) }
    end
  end

  def web_repo_or_first
    r = Repository.find { |r| r.repo.eql?(ORG::GIT_REPO) }
    return r if r&.open?

    Repository.all.first
  end
end
