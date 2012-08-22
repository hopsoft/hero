# Hero

## Its a bird, its a plane, its... its... my hero

Ever wish that you could unwind the spaghetti and get out of the corner you've been backed into?
Well... fret no more.

### Hero is here to save the day

I've seen my share of poor app structure. 
Hell, I wrote most of the bad stuff I've seen.

Whether is fat controllers, giant models with mystery ActiveRecord callbacks, or a junk drawer lib directory.

The question remains. **Where do I put my business logic?**

I finally have an answer that would even make DHH proud... 
since it evolved from real world use cases.

## Modeling a business process

The problem has always been effectively modeling a business process within the application structure.

Things start simply enough but eventually the edge cases push little gotchas into
the various libs, modules, and classes of your app. Before you know you it,
you have a lump of spaghetti thats difficult to maintain and even harder to improve.

Enter Hero.

Hero provides a simple pattern that allows you to decompose business processes into managable and testable chunks.

Heres a simple example. Assume our app needs to support logins. 
Our solution might look something like this.

* Verify we have both username & password
* Get the salt and hash the password
* Hash the password prior to querying the database

```ruby
Hero::Formula.register(:login)

Hero::Formula[:login].add_step do |user|

end


Hero::Formula[:login].add_step do |user|

end

Hero::Formula[:login].add_step do |user|

end
```
