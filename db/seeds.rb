# Seed admin user
admin_email = 'admin@example.com'
admin_password = 'adminpassword123'
admin = User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = :admin
end

# Seed 6 players
player_data = [
  { name: 'Magnus', surname: 'Carlsen', birthday: '1990-11-30', email: 'magnus@example.com' },
  { name: 'Hikaru', surname: 'Nakamura', birthday: '1987-12-09', email: 'hikaru@example.com' },
  { name: 'Fabiano', surname: 'Caruana', birthday: '1992-07-30', email: 'fabiano@example.com' },
  { name: 'Ding', surname: 'Liren', birthday: '1992-10-24', email: 'ding@example.com' },
  { name: 'Alireza', surname: 'Firouzja', birthday: '2003-06-18', email: 'alireza@example.com' },
  { name: 'Ian', surname: 'Nepomniachtchi', birthday: '1990-07-14', email: 'ian@example.com' }
]

player_data.each_with_index do |pdata, idx|
  user = User.find_or_create_by!(email: pdata[:email]) do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.role = :player
  end
  Player.find_or_create_by!(user: user) do |player|
    player.name = pdata[:name]
    player.surname = pdata[:surname]
    player.birthday = pdata[:birthday]
    player.ranking = idx + 1
  end
end
