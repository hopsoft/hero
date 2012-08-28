---
title: hero
layout: main
forkme_url: https://github.com/hopsoft/hero
---
# Hero {#hero}

![Hero GEM](http://hopsoft.github.com/hero/images/hero.jpg)

## Its a bird, its a plane, its... its... my Hero {#its-a-bird,-its-a-plane,-its...-its...-my-hero}

---

*Controlling complexity is the essence of computer programming. -- [Brian Kernighan](http://en.wikipedia.org/wiki/Brian_Kernighan)*

---

I've seen my share of poor app structure.
Hell, I wrote most of it.
Whether is fat controllers, giant models with mystery callbacks, or a junk drawer lib directory.

The question remains. **Where do I put my business logic?**

Finally... an answer that might even make DHH proud.
One that evolved from the real world with concrete use cases and actual production code.

## Why Hero? {#why-hero?}

* It matches the mental map of your business requirements
* It produces testable components
* It easily handles changing requirements
* It reduces the ramp up time for new team members

## Process Modeling {#process-modeling}

The problem has always been: **How do you effectively model a business process within your app?**

Things start simply enough but eventually edge cases force *gotchas* into
various libs, modules, and classes. Before you know you it,
you have a lump of spaghetti that's difficult to maintain and even harder to improve.

Hero provides a simple pattern that encourages you to
<a href="http://en.wikipedia.org/wiki/Decomposition_(computer_science)">decompose</a>
these processes into managable chunks.

---

## Quick Start {#quick-start}

{% highlight bash %}
gem install hero
{% endhighlight %}

Lets model a business process for collecting the top news stories from Hacker News, Reddit, & Google and then emailing the results to someone.

---

Gather News

- Get news from Hacker News
- Get news from Reddit
- Get news from Google
- Email Results

---

Now that we have the basic requirements, lets model it with Hero.

{% highlight ruby %}
Hero::Formula[:gather_news].add_step :hacker_news do |context, options|
  # make api call
  # parse results
  # append results to context
end

Hero::Formula[:gather_news].add_step :reddit do |context, options|
  # make api call
  # parse results
  # append results to context
end

Hero::Formula[:gather_news].add_step :google do |context, options|
  # make api call
  # parse results
  # append results to context
end

Hero::Formula[:gather_news].add_step :email do |context, options|
  # format news for email
  # compose the email
  # send the email
end
{% endhighlight %}

This looks surprising similar to the requirements.
In fact we can publish the specification directly from Hero.

{% highlight ruby %}
Hero::Formula[:gather_news].print

# => gather_news
#      1. hacker_news
#      2. reddit
#      3. google
#      4. email
{% endhighlight %}

Pretty slick.
Now... lets run the process.

{% highlight ruby %}
news = {}
Hero::Formula[:gather_news].run(news)
{% endhighlight %}

And we're done.

### Key take aways {#key-take-aways}

- The implementation aligns perfectly with the requirements.
  *Developers and business folks can talk the same lingo.*

- The formula is composed of smaller steps that are interchangable.
  *We are poised for changing requirements.*

- Steps can be tested independently.

- Each step implements the interface: `def call(context, options)`


## Next Steps {#next-steps}

As our app grows in complexity, we should change the steps from blocks to classes.
Here's an example.

{% highlight ruby %}
# this
Hero::Formula[:gather_news].add_step :hacker_news do |context, options|
  # make api call
  # parse results
  # append results to context
end

# changes to this
module GatherNews
  class HackerNews

    def call(context, options)
      # make api call
      # parse results
      # append results to context
    end

  end
end

Hero::Formula[:gather_news].add_step GatherNews::HackerNews.new
{% endhighlight %}

We should also create a directory structure that maps to the business process.
Something like this.

{% highlight bash %}
|-app
  |-formulas
    |-gather_news
      |-hacker_news.rb
      |-reddit.rb
      |-google.rb
      |-email.rb
{% endhighlight %}

We also need an initializer to set the formula up.

{% highlight ruby %}
# app/initializer.rb
Hero::Formula[:gather_news].add_step :hacker_news, GatherNews::HackerNews.new
Hero::Formula[:gather_news].add_step :reddit, GatherNews::Reddit.new
Hero::Formula[:gather_news].add_step :google, GatherNews::Google.new
Hero::Formula[:gather_news].add_step :email, GatherNews::Email.new
{% endhighlight %}

Now we have a well structured application thats ready to grow.
Notice how well organized everything is.

Also note that we can write tests for each step independent of anything else.
This is an important point and a powerful concept.

## Deep Cuts {#deep-cuts}

Logging comes for free if you register a logger with Hero. Here's an example.

{% highlight ruby %}
Hero.logger = Logger.new(STDOUT)

Hero::Formula[:log_example].add_step :first_step do |context, options|
  context << 1
end

Hero::Formula[:log_example].add_step :second_step do |context, options|
  context << 2
end

Hero::Formula[:log_example].add_step :third_step do |context, options|
  context << 3
end

Hero::Formula[:log_example].run([])

# The log will now contain the following lines.
#
# I, [2012-08-26T11:37:22.267072 #76676]  INFO -- : HERO before log_example -> first_step Context: [] Options: {}
# I, [2012-08-26T11:37:22.267166 #76676]  INFO -- : HERO after  log_example -> first_step Context: [1] Options: {}
# I, [2012-08-26T11:37:22.267211 #76676]  INFO -- : HERO before log_example -> second_step Context: [1] Options: {}
# I, [2012-08-26T11:37:22.267248 #76676]  INFO -- : HERO after  log_example -> second_step Context: [1, 2] Options: {}
# I, [2012-08-26T11:37:22.267282 #76676]  INFO -- : HERO before log_example -> third_step Context: [1, 2] Options: {}
# I, [2012-08-26T11:37:22.267333 #76676]  INFO -- : HERO after  log_example -> third_step Context: [1, 2, 3] Options: {}
{% endhighlight %}

---

{% include disqus.html %}
{% include forkme.html %}