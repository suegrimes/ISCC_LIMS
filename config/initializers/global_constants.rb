GIT_BRANCH = `git status | sed -n 1p`.split(" ").last
CAPISTRANO_DEPLOY = "#{Rails.root}".include?('releases')
