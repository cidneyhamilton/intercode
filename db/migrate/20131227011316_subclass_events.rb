class SubclassEvents < ActiveRecord::Migration
  def change
    add_reference :events, :user, index: true
    add_column :events, :type, :string
    add_column :events, :status, :string
    remove_column :events, :special_event_flags, :text
  end
end
