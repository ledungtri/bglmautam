## Prerequisites
* Install [ASDF Version Manager](https://asdf-vm.com) - Using as a version manager for Ruby
* Install [ASDF Ruby plugin](https://github.com/asdf-vm/asdf-ruby)
* Install [PostgreSQL](https://www.postgresql.org/download/)

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
Once the server is up and running, you can access the application at http://localhost:3000