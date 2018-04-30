# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

 2.5.0

* System dependencies

* Configuration

* Database creation
 
* Database initialization



* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions:
    
  *  bundle exec rails g spree:install --sample=false
  *  bundle exec rake spree_auth:admin:create
  *  rails g spree_gateway:install
  *  bundle exec rails g spree_reviews:install
  *  bundle exec rails g spree_multi_currency:install
