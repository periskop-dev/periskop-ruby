.PHONY: prepare test test-ci

prepare:
	bundle install

test:
	bundle exec rspec
