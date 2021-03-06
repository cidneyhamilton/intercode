require File.expand_path('app/models/user_con_profile', Rails.root)

class CreateUserConProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :user_con_profiles do |t|
      t.references :user, :null => false
      t.references :con, :null => false

      t.string :registration_status, :null => false, :default => "unpaid"
      t.references :comp_event
      t.integer :payment_amount_cents
      t.string :payment_amount_currency, :length => 3
      t.text :payment_note

      %w(
        bid_committee
        staff
        bid_chair
        gm_liaison
        outreach
        con_com
        scheduling
        mail_to_gms
        mail_to_attendees
        mail_to_vendors
        mail_to_unpaid
        mail_to_alumni
      ).each do |priv_name|
        t.boolean priv_name, :null => false, :default => false
      end

      t.timestamps
    end

    add_index :user_con_profiles, [:con_id, :user_id], :unique => true
    add_index :user_con_profiles, :registration_status
  end
end
