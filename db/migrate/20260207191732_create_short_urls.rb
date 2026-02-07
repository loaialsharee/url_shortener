class CreateShortUrls < ActiveRecord::Migration[8.1]
  def change
    create_table :short_urls do |t|
      t.string :target_url
      t.string :code
      t.string :title

      t.timestamps
    end
  end
end
