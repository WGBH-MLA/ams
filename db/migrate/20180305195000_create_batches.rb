class CreateBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :batches do |t|
      t.string :job_id
      t.string :submitter
      t.string :original_filename

      t.timestamps
    end
  end
end
