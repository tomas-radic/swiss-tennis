class AddCanceledAtToEnrollments < ActiveRecord::Migration[5.2]
  def change
    add_column :enrollments, :canceled_at, :datetime
  end
end
