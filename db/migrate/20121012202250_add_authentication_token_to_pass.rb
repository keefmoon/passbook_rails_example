class AddAuthenticationTokenToPass < ActiveRecord::Migration
  def change
    add_column :passes, :authentication_token, :string
  end
end
