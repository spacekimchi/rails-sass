# Rails Sass

The purpose of this project is to create a fast, easy, and insightful way for prop traders to record their trades. Traders who are using NinjaTrader will be able to connect their Muh Trades account and automatically import their executions. Executions will be processed into trades for easy recording and analysis. Stop blowing up, get profitable now.

# Ruby and Rails versions

- Ruby: 3.3.0
- Rails: 7.1.3

# Docker

Run `docker-compose up --build` to run the project. It will start both the database (db) and webserver (web) containers.

You can rebuild image using `docker-compose build --no-cache`

Add a `-d` flag to run it in the background.

To list the containers running, use: `docker-compose ps`

Run `docker attach <container_id_or_name>` to view server logs and you can debug using this with `binding.pry`

To enter the database, use: `docker-compose exec db psql -U username -d database_name`. Note that `db` is the name of the postgresql container

Enter the docker container using `docker-compose exec web bash`

Individual containers can be restarted using `docker-compose restart web`. `web` can be replaced with the names of the docker containers

We can view logs of each container using the command: `docker-compose logs web` where `web` is the name of the docker container

To remove all unused images: `docker image prune -a`

To remove all images: `docker rmi $(docker images -q)`

To do a full cleanup, run: `docker system prune`

When the container is already running, you can attach the docker session to the terminal session. Do this by:

To find all .swp files, run: `find . -type f -name "*.swp"`


# Database Creation

The project uses a PostgreSQL 16 database.

To run migrations, you can run `docker-compose exec web bundle exec rails db:migrate`. Note that `web` is the name of the docker container running the webapp.

We can pass commands to the docker container using `docker-compose exec` followed by the command we want to run. For example, we can run `docker-compose exec web bundle exec rails generate clearance:install` to run the install script for clearance.

We need to use `docker-compose exec web bundle exec rails` when trying to use commands like `rails db:migrate`

# Stripe Payments

To run a stripe webhooks listener locally, run `stripe listen --forward-to localhost:3000/stripe/webhooks`

Different stripe webhooks events can be triggered with `stripe trigger customer.subscription.created`
 - The different events can be found in the `stripe_webhooks_controller.rb` file

# Stylesheets

Run `yarn build:css` to compile scss into css

To get scss to autocompile during developent, install: `npm install nodemon --save-dev`

After installing, run `npm run watch:scss`

# Annotate models with

`docker-compose exec web bundle exec annotate --models`

# Deployment instructions

Deployment will be done with github workflows

# Testing

The project uses RSpec for testing.

To run tests we are using Docker. This gives the advantage of having tests, development, and production all run in the same environment

Run this to create and migrate the test database if it doesn't exist: `docker-compose run --rm -e "RAILS_ENV=test" web bundle exec rails db:create`

Run tests with this command: `docker-compose run --rm -e "RAILS_ENV=test" web bundle exec rspec spec/models/role_spec.rb`

# Deploying the application

Get a VPS somewhere like Vultr, Digital Ocean, or Hetzner.

Install docker and docker compose

```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Commands for using the production docker compose files
```
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml up -d
```

Set up nginx for a reverse proxy
```
sudo apt install nginx
```

Create a new nginx configuration and create a symlink to enable it. Test the configuration and restart nginx
```
sudo vim /etc/nginx/sites-available/{site-name-here}
sudo ln -s /etc/nginx/sites-available/{site-name-here} /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```
Here is an example of setting it up for a reverse proxy

```
server {
    listen 80;
    listen [::]:80;
    server_name choppinglist.co www.choppinglist.co;

    # Adjust this path to your Rails app's public directory
    # This is for serving static files through nginx
    root /path/to/public/files;

    location / {
        try_files $uri $uri/ @rails;
    }

    location @rails {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # For WebSocket support (if needed)
    location /cable {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }

    # Add some basic security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    # Optionally, add gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;
}
```

Create a certbot for adding SSL for HTTPS connections
```sudo certbot --nginx -d choppinglist.co -d www.choppinglist.co```

Sometimes we run into an error for rails master key problems
we can run 
EDITOR="code --wait" bin/rails credentials:edit --environment production
to create a production master key and copy those files into the production server.
Edit the config/environment/production.rb file to include this
```config.require_master_key = ENV["SECRET_KEY_BASE_DUMMY"].nil?```
