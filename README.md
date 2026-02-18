# Pocket URL Tracker - Backend Application

Backend application built with Ruby on Rails.

🌐 Live: https://pocket-url-tracker.vercel.app/ <br>
📜 Docs: https://github.com/loaialsharee/url_shortener/wiki/Pocket-%E2%80%90-A-URL-Shortener-Solution

# Local Development Setup
* Ruby 3.3.5
* Rails 8.1.2
* PostgreSQL
* Redis

# Quick Start
1️⃣ Install dependencies:
```
bundle install
```

2️⃣ Setup the database

```
rails db:create
rails db:migrate
```


3️⃣ Start Redis server

```
redis-server
```

4️⃣ Start the Rails server
```
rails s
```

* Make sure the backend server is running on a different port if you're integrating with the frontend app.

5️⃣ Run the tests
```
rails test
```


# Production Deployment

The deployed service runs using:

```
bundle exec rails db:migrate && bundle exec puma -p $PORT -e production
```

