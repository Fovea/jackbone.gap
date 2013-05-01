lint: check-jshint
	@jshint js/*.js

tests: check-phantomjs
	@./tests/boilerplate-lite.sh
	@./tests/navigation.sh

all: lint tests
	@echo 'ok'

check-jshint:
	@which jshint > /dev/null || ( echo 'Please Install JSHint, npm install -g jshint'; exit 1 )

check-phantomjs:
	@which phantomjs > /dev/null || ( echo 'Please PhantomJS, http://phantomjs.org/'; exit 1 )

clean:
	@find . -name '*~' -exec rm '{}' ';'
