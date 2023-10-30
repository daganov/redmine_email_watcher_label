Redmine::Plugin.register :redmine_email_watcher_label do
  name "Redmine Email Watcher Label plugin"
  author "Aganov D."
  description "This plugin adds a label [Watcher] to email subject when a user is watcher"
  version "1.0"
  url "https://github.com/daganov/redmine_email_watcher_label"
  author_url "https://github.com/daganov/redmine_email_watcher_label"
end

require_relative "lib/redmine_email_watcher_label"
