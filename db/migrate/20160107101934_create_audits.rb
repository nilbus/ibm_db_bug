class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.integer :audit_id
    end
  end
end
