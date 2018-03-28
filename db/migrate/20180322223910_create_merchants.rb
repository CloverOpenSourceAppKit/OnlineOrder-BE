class CreateMerchants < ActiveRecord::Migration[5.1]
  def change
    create_table :merchants do |t|
      t.string :uuid, null: false

      t.timestamps
    end
  end
end
