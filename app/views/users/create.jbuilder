json.user do
    json.(@user, :created_at, :name, :email)
    json.roles(@user.user_roles, :role, :created_at)
end