# frozen_string_literal: true

module RedmineEmailWatcherLabel
  module MailerPatch
    extend ActiveSupport::Concern

    prepended do
      prepend InstanceMethods
    end

    class_methods do
      def deliver_issue_add(issue)
        users = issue.notified_users | issue.notified_watchers | issue.notified_mentions
        users.each do |user|
          watcher = issue.notified_watchers.include?(user)
          issue_add(user, issue, watcher: watcher).deliver_later
        end
      end

      def deliver_issue_edit(journal)
        users = journal.notified_users | journal.notified_watchers | journal.notified_mentions | journal.journalized.notified_mentions
        users.select! do |user|
          journal.notes? || journal.visible_details(user).any?
        end
        users.each do |user|
          watcher = (journal.notified_watchers).include?(user)
          issue_edit(user, journal, watcher: watcher).deliver_later
        end
      end

      def deliver_wiki_content_added(wiki_content)
        users = wiki_content.notified_users | wiki_content.page.wiki.notified_watchers | wiki_content.notified_mentions
        users.each do |user|
          watcher = wiki_content.notified_watchers.include?(user)
          wiki_content_added(user, wiki_content, watcher: watcher).deliver_later
        end
      end

      def deliver_wiki_content_updated(wiki_content)
        users  = wiki_content.notified_users
        users |= wiki_content.page.notified_watchers
        users |= wiki_content.page.wiki.notified_watchers
        users |= wiki_content.notified_mentions

        users.each do |user|
          watcher = wiki_content.notified_watchers.include?(user)
          wiki_content_updated(user, wiki_content, watcher: watcher).deliver_later
        end
      end
    end

    module InstanceMethods
      def issue_add(user, issue, **options)
        email = super(user, issue)

        if options[:watcher]
          email.subject.prepend("[#{l(:mail_subject_prefix)}] [#{l(:mail_subject_watcher)}] ")
        else
          email.subject.prepend("[#{l(:mail_subject_prefix)}] ")
        end
        email
      end

      def issue_edit(user, journal, **options)
        email = super(user, journal)

        if options[:watcher]
          email.subject.prepend("[#{l(:mail_subject_prefix)}] [#{l(:mail_subject_watcher)}] ")
        else
          email.subject.prepend("[#{l(:mail_subject_prefix)}] ")
        end
        email
      end

      def wiki_content_added(user, wiki_content, **options)
        email = super(user, wiki_content)

        if options[:watcher]
          email.subject.prepend("[#{l(:mail_subject_prefix)}] [#{l(:mail_subject_watcher)}] ")
        else
          email.subject.prepend("[#{l(:mail_subject_prefix)}] ")
        end
        email
      end

      def wiki_content_updated(user, wiki_content, **options)
        email = super(user, wiki_content)

        if options[:watcher]
          email.subject.prepend("[#{l(:mail_subject_prefix)}] [#{l(:mail_subject_watcher)}] ")
        else
          email.subject.prepend("[#{l(:mail_subject_prefix)}] ")
        end
        email
      end
    end
  end
end

base = Mailer
patch = RedmineEmailWatcherLabel::MailerPatch
base.prepend patch unless base.included_modules.include?(patch)
