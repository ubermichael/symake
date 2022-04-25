include etc/Makefile.common

## Make file

## -- Test targets

test.db: ## Create the test database if it does not already exist
	$(CONSOLE) --env=test doctrine:database:create --if-not-exists --quiet
	$(CONSOLE) --env=test doctrine:schema:drop --force --quiet
	$(CONSOLE) --env=test doctrine:schema:create --quiet
	$(CONSOLE) --env=test doctrine:schema:validate --quiet

test.reset: ## Create a test database and load the fixtures in it
	$(CONSOLE) --env=test doctrine:cache:clear-metadata --quiet
	$(CONSOLE) --env=test doctrine:fixtures:load --quiet --no-interaction --group=dev --purger=fk_purger

test.run: ## Directly run tests. Use optional path=/path/to/tests to limit target
	$(PHPUNIT) $(path)

test: test.clean test.reset test.run ## Run all tests. Use optional path=/path/to/tests to limit target

test.cover: test.clean test.reset ## Generate a test cover report
	$(PHP) -d zend_extension=xdebug.so -d xdebug.mode=coverage $(PHPUNIT) -c phpunit.coverage.xml $(path)
	open $(LOCAL)/dev/coverage/index.html
