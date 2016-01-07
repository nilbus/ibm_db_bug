class CreateAuditDetails < ActiveRecord::Migration
  def change
    create_table :audit_details do |t|
      t.integer :audit_id
    end
  end
end
