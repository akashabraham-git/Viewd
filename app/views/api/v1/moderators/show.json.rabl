object @moderator
attributes :id, :employee_number, :department

child :user do
  attributes :id, :name, :username, :email
end