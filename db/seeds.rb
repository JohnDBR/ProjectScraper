# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(
    username:admin,
    full_name:"Super Captain Admin",
    role:1
)

t = Token.create(
	secret:"cd7f27e1bbfa4ca4959fbb3dbcc6c3fb", 
	expire_at:"2018-04-20", 
	user_id: 1
	)
t.update_attribute(:secret, "cd7f27e1bbfa4ca4959fbb3dbcc6c3fb") #Admin