# Hero

![Hero GEM](http://hopsoft.github.com/hero/images/hero.jpg) 

## Its a bird, its a plane, its... its... my Hero

---

*Controlling complexity is the essence of computer programming. -- [Brian Kernighan](http://en.wikipedia.org/wiki/Brian_Kernighan)*

---

I've seen my share of poor app structure. 
Hell, I wrote most of it.
Whether is fat controllers, giant models with mystery callbacks, or a junk drawer lib directory.

The question remains. **Where do I put my business logic?**

Finally... an answer that might even make DHH proud. 
One that evolved from the real world with concrete use cases and actual production code.

## Why Hero?

* It matches the mental map of your business requirements
* It produces testable coponents
* It easily handles changing requirements 
* It reduces the ramp up time for new team members

## Process Modeling

The problem has always been: **How do you effectively model a business process within your app?**

Things start simply enough but eventually edge cases force *gotchas* into
various libs, modules, and classes. Before you know you it,
you have a lump of spaghetti that's difficult to maintain and even harder to improve.

Hero provides a simple pattern that encourages you to 
<a href="http://en.wikipedia.org/wiki/Decomposition_(computer_science)">decompose</a>
these processes into managable chunks. And the best part... the components can be easily tested.

---

## Quick Start

```bash
gem install hero
```

Lets model a business process for collecting the top news stories from Hacker News, Reddit, & Google and then emailing the results to someone.

Gather News

- Get news from Hacker News
- Get news from Reddit
- Get news from Google
- Email Results

Now that we have the basic requirements, lets model it with Hero.

```ruby
Hero::Formula[:gather_news].add_step :hacker_news do |news|
  # make api call
  # parse results
  # append results to news
end

Hero::Formula[:gather_news].add_step :reddit do |news|
  # make api call
  # parse results
  # append results to news
end

Hero::Formula[:gather_news].add_step :google do |news|
  # make api call
  # parse results
  # append results to news
end

Hero::Formula[:gather_news].add_step :email do |news|
  # format news for email
  # compose the email
  # send the email
end
```

This looks surprising similar to the requirements. 
In fact we can publish the specification directly from Hero.

```ruby
puts Hero::Formula[:gather_news].publish

# => gather_news
#      1. hacker_news
#      2. reddit
#      3. google
#      4. email
```

Pretty slick.
Now... lets run the process.

```ruby
Hero::Formula[:gather_news].run({})
```

And we're done.

### Key take aways

- **The implementation aligns perfectly with the requirements.**
  *This means that developers and business folks can talk the same lingo.*

- **The formula is composed of smaller steps that are interchangable.**
  *This means we are poised for changing requirements.*

- **Each step implements the interface `def call(context)`**
  *This means we can create step classes to simplify the app structure.*

## Next Steps

As our app grows in complexity, we should change the steps from blocks to classes.
Here's an example.

```ruby
# this
Hero::Formula[:gather_news].add_step :hacker_news do |news|
  # make api call
  # parse results
  # append results to news
end

# changes to this
module GatherNews
  class HackerNews

    def call(news)
      # make api call
      # parse results
      # append results to news
    end

  end
end

Hero::Formula[:gather_news].add_step GatherNews::HackerNews.new
```

We should also create a directory structure that maps to the business process.
Something like this.

```bash
- app
 |-formulas
   |-gather_news
     |-hacker_news.rb
     |-reddit.rb
     |-google.rb
     |-email.rb
```

We also need an initializer to set the formula up.

```ruby
# app/initializer.rb
Hero::Formula[:gather_news].add_step GatherNews::HackerNews.new
Hero::Formula[:gather_news].add_step GatherNews::Reddit.new
Hero::Formula[:gather_news].add_step GatherNews::Google.new
Hero::Formula[:gather_news].add_step GatherNews::Email.new
```

Now we have a well structured application that is ready to grow.
Notice how well organized everything is.

Also note that we can write tests for each step independent of anything else.
This is an important point and a powerful concept.

## Deep Cuts

Advanced usage coming soon...
