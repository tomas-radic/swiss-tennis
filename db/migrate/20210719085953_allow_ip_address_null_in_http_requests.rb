class AllowIpAddressNullInHttpRequests < ActiveRecord::Migration[5.2]

  def change
    change_column_null :http_requests, :ip_address, true
  end

end
