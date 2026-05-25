defmodule Brock.Accounts do
  use Ash.Domain, otp_app: :brock, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Brock.Accounts.Token
    resource Brock.Accounts.User
  end
end
