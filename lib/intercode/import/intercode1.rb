require 'sequel'
require 'term/ansicolor'

module Intercode
  module Import
    module Intercode1
      extend ActiveSupport::Autoload

      col = Term::ANSIColor

      mattr_accessor :logger
      self.logger = Logger.new(STDERR)
      logger.formatter = proc do |severity, time, _progname, msg|
        severity_padded = format('%-7s', "[#{severity}]")

        severity_rep = case severity
        when 'FATAL' then col.black(col.on_red(severity_padded))
        when 'ERROR' then col.bold(col.red(severity_padded))
        when 'WARN' then col.bold(col.yellow(severity_padded))
        when 'INFO' then col.bold(col.green(severity_padded))
        when 'DEBUG' then col.dark(col.blue(severity_padded))
        else severity_padded
        end

        "#{severity_rep} #{col.dark(col.yellow(time.strftime('%H:%M:%S.%L')))} - #{msg}\n"
      end

      autoload :DateHelpers
      autoload :EmbeddedPdfPage
      autoload :FormImporter
      autoload :HtmlContent
      autoload :HtmlConverter
      autoload :Importer
      autoload :Markdownifier
      autoload :NavigationItems
      autoload :Php
      autoload :ProposalForm
      autoload :RegistrationPolicyFactory
      autoload :RegistrationStatuses
      autoload :StaffPositionImporter
      autoload :Table
      autoload :Tables
      autoload :UploadFile
      autoload :UserConProfileForm
    end
  end
end
