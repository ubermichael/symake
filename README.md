# Symfony Make Files

In each Symfony project in the DHIL we use a series of [Makefiles][mk-intro] to gather commonly used commands and multistep processes. The command `make` and [Makefiles are well documented][mk-docs]. These make files are very biased to MacOS and [Homebrew][brew]. They will be difficult (maybe impossible) to use on a different platform.

The makefiles are in a separate [git repository][mk-repo]. Add it to a Symfony project:

```bash
git submodule add -f -b main https://github.com/ubermichael/symake etc
```

## The files

Makefile
: Sets up a few env variables which can be overridden and includes the relevant makefiles in the submodule

Makefile.local (optional)
: Defines local development settings like database name and URL. If used, it must be included after setting the env variables in the main Makefile

etc/Makefile
: Includes etc/Makefile.common and provides a set of test targets that work with a real database

etc/Makefile.legacy
: Includes etc/Makefile.common and provides a set of test targets that work with a SQLite database

etc/Makefile.common
: Provides all the non-test targets

## Configuration

The make files must define these environment variables 

 - `DB` the name of the database for the project. `DB_TEST` is automatically defined from this one.
 - `PROJECT` the name of the project. It might be the same as `DB`. Used to create Solr cores for dev and test, and sets the name of the database dump files in the `db.reload` target. 

## The targets
Invoke the commands with `make $target`. `make` without a target or `make help` will print a list of targets with a brief description of each one.

### General targets
open
: Open the project home page in a browser. Assumes that the URL environment variable is set up somewhere.

clean.git
: Force clean the git metadata with `git gc` and some other tools. Packs objects and removes any dangling reflogs.

devconf
: Configure some dev tools for the project. Uses composer to add [php-cs-fixer][php-cs-fixer] and [phpstan][phpstan] and standardized configuration files for them. Does not overwrite the configuration files if they already exist.

devconf-force:
: Like `devconf` but overwrites any php-cs-fixer or phpstan configuration files.

### Composer targets         

composer.install
: Install composer dependencies

composer.update
: Update composer dependencies

composer.autoload
: Update the autoload system

### Cache targets            

cc
: Clear the Symfony cache and warm it up via the Symfony console

cc.purge
: Remove the cache and logs directories. Useful if Symfony has cached something broken and the Symfony console is broken.

### Assets etc.              

assets
: Link all the symfony bundle assets into /public

yarn
: Install yarn assets from package.json

yarn.upgrade
: Upgrade the yarn assets in package.json

sass
: Recompile the SASS assets from /public/scss to /public/css. Assumes [sass][sass] is installed via homebrew.

sass.watch
: Start the SASS watcher which to recompile the SASS assets from /public/scss to /public/css any time a file in /public/scss changes

### Database things

Unless otherwise noted, all database targets use the symfony console to work. Make sure the database is configured correctly before using these.

db
: Create the database if it does not already exist, remove and recreate all tables and validate the schema

db.diff
: Diff the database schema against the entity definitions and show the result. Does not apply any changes. See the Migration section for managing database changes.

db.validate
: Validate the doctrine annotations and schema definition

db.reset
: Remove the contents of the database and load the development fixtures

db.reload
: Drop and recreate the database with an empty schema, then load it with data downloaded from the server. Assumes that `pv` and `mysql` commands are available and that the schema and data are stored in `$project-schema.sql` and `$project-data.sql`.

###  Database migrations         

migrate                        
: Run any migrations as required.

migrate.down                   
: Undo one database migration. This particular target will probably only work with GNU make, because it uses some nonsense syntax and shell extensions to figure out which is the current migration. Just look at this nonsense:
: `	$(eval CURRENT=$(shell $(CONSOLE) --env=dev doctrine:migrations:current))`

migrate.diff                   
: Generate a new migration by diffing the db and entities. You should probably review and edit it.

migrate.status
: Show the status of database migrations. Does not make any changes.

migrate.rollup                 
: Remove all the migration files and replace them with a single schema definition. Use with care and make sure all migrations are applied to production before using.

migrate.reset
: Remove all migration metadata from the database and recreating it from the available files. Very helpful when a migration goes missing. Use with care.

### Container debug targets  
These targets do not make any changes, but provide some useful troubleshooting information. `make dump.env | grep WHATEVER` is especially useful.

dump.autowire
: Show Symfony services that can be autowired in to other services.

dump.container                 
: Show service container, with all services and their service IDs for use in config files.

dump.env
: Show all Symfony environment variables discovered in .env files.

dump.params
: List all of the container parameters. There are a lof of them. `grep` is your friend.

dump.router
: Display all the routing information from router configuration files and controller classes.

dump.twig                      
: Print a list of available twig functions, filters, tests, global variables, and loader paths.

### Solr search and indexing targets 
The solr targets assume Solr was installed via Homebrew.

solr.clear
: Remove all content from the SOLR core

solr.config
: Stop the brew solr service, copy the solr schema from /solr to the core, and start the solr service again.

solr.delete
: Delete the solr core.

solr.index                     
: Empty the solr core, the repopulate it via the Symfony console.

solr.open
: Open the local solr core in a web browser

: solr.setup
Create the SOLR core for indexing

### Useful development services 
[Mailhog][mailhog] is a development, local-only, mail receiver for testing and development. Use it to make sure emails are getting sent from Symfony correctly.

mailhog.start
: Start the email catcher and open the web UI.
: You must manually add `MAILER_DSN=smtp://localhost:1025` to .env.local for symfony to send the emails to it.

mailhog.stop
: Stop the email catcher
: You must manually remove `MAILER_DSN=smtp://localhost:1025` from .env.local or Symfony will throw errors.

### Test targets
These targets are defined in Makefile and Makefile.legacy. The Makefile targets are designed to work with MariaDB testing databases. The legacy targets use SQLite.

test.db                        
: Create the test database if it does not already exist and load the database schema.

test.reset
: Remove all test data and load the fixtures.

test.clean
: Remove any test data, cache, or log files.

test.run
: Directly run tests. Use optional `path=/path/to/tests` to limit target

test
: Does `test.clean`, `test.reset`, and `test.run` in that order.

test.run
: Directly run tests. Use optional path=/path/to/tests to limit target

test.cover                   
: Run the tests with a coverage generator and then open the result in a browser.

### Solr test targets        
test.solr.clear                
: Clear the content from the SOLR core

test.solr.config
: Copy the solr schema to the test core

test.solr.delete
: Remove the SOLR test core

test.solr.index
: Index the content in the test database in the test solr core

test.solr.open
: Open the local SOLR core in a web browser

test.solr.setup
: Create the test SOLR core for indexing

### Coding standards fixing
The `devconf` target will install `php-cs-fixer` via composer and add a default config file.

fix
: Fix the code with the CS rules.

fix.cc
: Remove the PHP CS Cache file

fix.all
: Ignore the CS cache and fix the code with the CS rules

fix.list
: Check the code against the CS rules. Does not make any changes, just prin the results.

### Coding standards checking
In addition to the PHP CS targets above there are also additional code standards checks.

symlint
: Run the symfony linting checks: security and container configuration as well as doctrine schema validation

twiglint
: Check the twig templates for syntax errors

twigcs
: Check the twig templates against the recommended coding standards

stan
: Run static analysis via `phpstan`

stan.cc
: Clear the static analysis cache

stan.baseline
: Generate a new phpstan baseline file which records all current warnings/errors in the code base so they are ignored.

### Makefile debugging          
printvars
: Print configuration variables


[mailhog]: https://github.com/mailhog/MailHog
[sass]: https://sass-lang.com/
[php-cs-fixer]: https://cs.symfony.com/
[phpstan]: https://phpstan.org/
[brew]: https://brew.sh/
[mk-docs]: https://www.gnu.org/software/make/manual/html_node/Introduction.html
[mk-intro]: https://opensource.com/article/18/8/what-how-makefile
[mk-repo]: https://github.com/ubermichael/symake
