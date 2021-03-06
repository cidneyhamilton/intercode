# Be sure to restart your server when you modify this file.

cookie_options = { key: '_intercode_session' }
default_host = Rails.application.config.action_mailer.default_url_options.try(:[], :host)

if default_host
  just_hostname = URI.parse("http://#{default_host}").host  # get rid of port number if it's there

  # Awful awful shenanigans: get the last up-to-two dot-separated parts of the hostname.
  # So: localhost stays as localhost
  # www.interconlarp.org becomes interconlarp.org
  second_level_domain = just_hostname.split(".").reverse.take(2).reverse.join(".")

  cookie_options[:domain] = ".#{second_level_domain}"
end

Rails.application.config.session_store :active_record_store, cookie_options
