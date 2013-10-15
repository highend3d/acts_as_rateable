# Acts As Rateable

Acts_as_rateable is a plugin released under the MIT license.
It makes activerecord models rateable through a polymorphic association and optionally logs which user rated which model.
In this case, one user can rate an object once.

## Installation

You can easily install gem by adding this line into your Gemfile:

```ruby
  gem 'acts_as_rateable', :git => 'git://github.com/highend3d/acts_as_rateable.git', :branch => 'master'
```

After you install Acts As Rateable and add it to your Gemfile, you need to run the generator:

```
  rails generate acts_as_rateable
```

The generator will add new migration, that's why the next is run migration:

```
  rake db:migrate
```

## Usage

Insert 'acts_as_rateable' into your model, and don't forget to restart your application.

```ruby
  class Post < ActiveRecord::Base
    acts_as_rateable
  end
```
Now you can rate it (1..#) or calculate the average rating.

```ruby
  # Rate the post
  @post.rate_it(4, current_user) #=> true || false

  # Average rating of selected post
  @post.average_rating #=> 4.0
  @post.average_rating_round #=> 4
  @post.average_rating_percent #=> 80

  # Check if the post is rated by user
  @post.rated_by?(current_user) #=> instance of rating model || false

  @post.parse_ratings(:json) #=> JSON formatted string containing the post's ratings

  # Find posts with rating '4'
  Post.find_average_of(4) #=> array
```

## Notes

Jinzhu - generator is compatible with rails 3.
Copyright (c) 2011 Anton Zaytsev, http://antonzaytsev.com , released under the MIT license
Copyright (c) 2007-2010 Ferenc Fekete, http://feketeferenc.hu , released under the MIT license
Copyright (c) 2011 Joerg Polakowski, http://mobile-melting.de , released under the MIT license
