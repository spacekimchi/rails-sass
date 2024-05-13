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

To run migrations, you can run `docker-compose exec web rails db:migrate`. Note that `web` is the name of the docker container running the webapp.

We can pass commands to the docker container using `docker-compose exec` followed by the command we want to run. For example, we can run `docker-compose exec web bundle exec rails generate clearance:install` to run the install script for clearance.

We need to use `docker-compose exec web bundle exec rails` when trying to use commands like `rails db:migrate`

# Stripe Payments

To run a stripe webhooks listener locally, run `stripe listen --forward-to localhost:3000/stripe/webhooks`

Different stripe webhooks events can be triggered with `stripe trigger customer.subscription.created`
 - The different events can be found in the `stripe_webhooks_controller.rb` file

# Stylesheets

Run `yarn build:css` to compile scss into css

# Deployment instructions

Deployment will be done with github workflows

# Testing

The project uses RSpec for testing.

To run tests we are using Docker. This gives the advantage of having tests, development, and production all run in the same environment

Run tests with this command: `docker-compose run -e "RAILS_ENV=test" web bundle exec rspec spec/models/role_spec.rb`

