Commands

Initial Setup:

bundle config set --local path 'vendor/bundle'
bundle install


Refactoring:

bundle exec rspec ./gilded_rose_spec.rb; ./texttest_fixture.rb 10 > ttf_output_10.txt
git diff (everything is clean when tests pass and ttf_output_10.txt has no changes)

ToDo

Complete refactoring of Backstage passes logic (watch out for timing of decrement_sell_in)
Encapsulate logic for item.sell_in < 0 in quality method calls
Checks on initial values into Item
DRY up specs with helper method(s)
Name checks to RegExps (Can the names vary ?)
