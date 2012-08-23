# Hero

## Its a bird, its a plane, its... its... my Hero

Ever wish that you could unwind the spaghetti and get out of the corner you've been backed into?

### Hero is here to save the day

I've seen my share of poor app structure. 
Hell, I wrote most of it.
Whether is fat controllers, giant models with mystery callbacks, or a junk drawer lib directory.

The question remains. **Where do I put my business logic?**

Finally... an answer that might even make DHH proud. 
One that evolved from the real world with concrete use cases and actual production code.

## Process Modeling

The problem has always been: How to effectively model a business process within your app.

Things start simply enough but eventually edge cases force *gothcas* into
various libs, modules, and classes. Before you know you it,
you have a lump of spaghetti that's difficult to maintain and even harder to improve.

### Enter Hero

Hero provides a simple pattern that encourages you to 
<a href="http://en.wikipedia.org/wiki/Decomposition_(computer_science)">decompose</a>
business processes into managable chunks.

And... the best part is, they are easily tested.

---

Here's an example. 
Assume we have a Rails app that needs to support logins. 

Our implementation might look something like this.

##### app/controllers/logins_controller.rb
```ruby
class LoginsController < ApplicationController

  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end

  def destroy
    @_current_user = session[:current_user_id] = nil
    redirect_to root_url
  end

end
```

##### app/controllers/application_controller.rb
```ruby
class ApplicationController < ActionController::Base
  before_filter :require_login
 
  private
 
  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url # halts request cycle
    end
  end
 
  def logged_in?
    !!current_user
  end

  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by_id(session[:current_user_id])
  end

end
```

Hero approaches this problem differently. 
It asks us to <a href="http://en.wikipedia.org/wiki/Decomposition_(computer_science)">decompose</a>
the login requirement into business processes which might look something like this.

#### Login

1. Authenticate the user
1. Save user info to session
1. Send user to home page

#### Logout

1. Remove user session
1. Send user to home page

#### Protect Page

1. Verify the user is logged in

Note that we just defined an [ontology](http://en.wikipedia.org/wiki/Process_ontology) 
that can be used to discuss the requirement and its implementation with non developers.

*This point cannot be understated.*

I know that this seems like overkill for our simple login requirement, 
but stay with me... the benefits will become obvious soon.

Here's an example of what our implementation with Hero might look like.

##### lib/errors.rb
```ruby
class AuthenticationError < StandardError; end
class AuthorizationError < StandardError; end
```

##### config/initializers/login.rb
```ruby
Hero::Formula.register(:login)
Hero::Formula[:login].add_step do |context|
  user = User.authenticate(context.params[:username], context.params[:password])
  raise AuthenticationError unless user
  context.session[:current_user_id] = user.id
end

Hero::Formula.register(:logout)
Hero::Formula[:logout].add_step do |context|
  context.session[:current_user_id] = nil
end

Hero::Formula.register(:protect_page)
Hero::Formula[:protect_page].add_step do |context|
  raise AuthorizationError if context.session[:current_user_id].nil?
end
```

##### app/controllers/logins_controller.rb
```ruby
class LoginsController < ApplicationController
  rescue_from AuthenticationError, :with => :new

  def new
  end

  def create
    Hero::Formula[:login].run(self)
    redirect_to root_url
  end

  def destroy
    Hero::Formula[:logout].run(self)
    redirect_to root_url
  end

end
```

##### app/controllers/application_controller.rb
```ruby
class ApplicationController < ActionController::Base
  before_filter :protect
  rescue_from AuthorizationError, :with => :force_login

  private

  def protect
    Hero::Formula[:protect_page].run(self)
  end

  def force_login
    flash[:error] = "You must be logged in to access this section"
    redirect_to new_login_url
  end
 
end
```
