class Page < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  cadmus_page
end
