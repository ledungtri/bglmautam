## Prerequisites
* Install [ASDF Version Manager](https://asdf-vm.com) - Using as a version manager for Ruby.
* Install [ASDF Ruby plugin](https://github.com/asdf-vm/asdf-ruby).
* Install [PostgreSQL](https://www.postgresql.org/download/).

## Editing tool
* [RubyMine](https://www.jetbrains.com/ruby/) by Jetbrains is a good IDE for programming Ruby on Rails application. 
But it is expensive.
If you have a free licence or willing to pay, RubyMine is a recommended.
* Alternatively, [VS Code](https://code.visualstudio.com/) is a powerful text editor. 
It is free, and with the right extensions, you can do a lot with it. 
Some useful extensions for this project:
  * [VSCode Ruby](https://marketplace.visualstudio.com/items?itemName=wingrunr21.vscode-ruby)
  * [Ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby)
  * [Ruby Solargraph](https://marketplace.visualstudio.com/items?itemName=castwide.solargraph)
  * [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
  * [PostgreSQL](https://marketplace.visualstudio.com/items?itemName=ckolkman.vscode-postgres)

## Get started
When first setting up ruby you will have to run the following before bundling:
```
asdf install
gem install bundler
```

Install the rails dependencies:
```
bundle install
```

Setup the database and seeding data:
```
rake db:create
rake db:migrate
rake db:seed
```

Run the server locally:
```
rails s
```
Once the server is up and running, you can access the application at http://localhost:3000.

## Production
* The current domain is bglmautam.com.
* The production server and domain are hosted on Hostinger and currently managed by ledungtri.2202@gmail.com.
* The current charges are $190 quadrennially for the server, and $11 annually for the domain.
* On this server, the application is served by Apache with the ability to host multiple domains in the same server. 
(Something to consider when expanding to more websites)
* In case the server is down or crashes, to restart the Rails application, we can restart Apache: 
  ```
  sudo service apache2 restart
  ```

## Backup database
We use seed_dump gem to backup the database or to create a `seeds.rb` file.

To create a seeds.rb file based on the current database, run:
```
rake db:seed:dump EXCLUDE=[]
```
To backup the current database for future uses, run:
```
rake db:seed:dump FILE=db/backups/2025-11-09.rb EXCLUDE=[]
```
The ```FILE=db/backups/2021-12-31.rb``` option is the specify the path and the name of the backup file.

The ```EXCLUDE=[]``` option is to make sure ```seed_dump``` includes the ```id```, ```created_at```, ```updated_at``` fields.

---
```
  pg_dump bglmautam_development > 2025
```

```
  psql -p 5433 -U bglmautam bglmautam_development < pg_backup_11-11-2025
  ```

## Development procedure
When working on a new task or a new feature, it is good practice to follow these steps:
* Checkout master branch
* Pull the latest code
* Create a new branch for that feature. Make sure the branch name is descriptive
* Commit your changes frequently with a descriptive messages. 
This will help managing code and keeping tracking on changes more easily.
* Test carefully on your local environment
* When the implementation is done push to remote branch
* Then go to Github and create a Pull Request from your feature branch onto the ```master``` branch.
* Another team member will review and test the your implementation. 
* Once the PR is reviewed, it will be merged to ```master``` and deploy to production.



