# Club Leaderboard

A Rails application for managing club players and matches with a leadboard and user authentication and authorization.

## Features

- User authentication (Devise)
- Role-based authorization (Pundit)

## Requirements

- Ruby 3.4+
- Rails 8.x
- PostgreSQL

## Setup

1. **Clone the repository:**

   ```sh
   git clone git@github.com:Derrynmitri/effective-engine.git club-leaderboard
   cd club-leaderboard
   ```

2. **Install dependencies:**

   ```sh
   bundle install
   ```

3. **Set up the database:**

   ```sh
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed # optional: this will seed an admin user and 6 players.
   ```

4. **Start the development server:**

   ```sh
   bin/dev
   ```

   Visit http://localhost:3000 in your browser.
