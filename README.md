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

* App structure matches the mental map of your business
* Testable coponents
* Faster ramp up time for new team members
* Easily handles changing requirements 

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

This looks surprising similar to the requirements handed to us. 
In fact we can easily publish the specification directly from Hero.

```ruby
puts Hero::Formula[:gather_news].publish

# => gather_news
#      1. hacker_news
#      2. reddit
#      3. google
#      4. email
```

Pretty slick.
The implementation is in complete alignment with the business requirements.
Now... lets run the process.

```ruby
Hero::Formula[:gather_news].run({})
```

And we're done.

### Key take aways

- The implementation aligns perfectly with the requirements.
- The formula is composed of smaller steps that are interchangable.
  *This means we are poised for changing requirements.*
- Each step implements the interface `def call(context)` 
  *This means we can create step classes to simplify the app structure.*

More info soon...
