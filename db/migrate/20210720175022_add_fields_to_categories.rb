class AddFieldsToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :position, :integer, null: false, default: 1
    add_column :categories, :detail, :string
    add_column :categories, :nr_finalists, :integer, null: false, default: 0

    Category.all.each.with_index(1) do |category, idx|
      category.set_list_position idx
    end
  end
end
