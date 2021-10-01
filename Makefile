.PHONY: prepare test test-ci

prepare:
	bundle install

test:
	bundle exec rspec

test-ci:
	bundle exec rspec --format json --out rspec.json
