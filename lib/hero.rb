require 'observer'
require 'singleton'

class Hero
  include Observable
  include Singleton

  def notify(event_name, target=nil, options={})
    changed
    notify_observers(event_name, target=nil, options)
  end
end

InitUser.instance.notify(:before_init, {:name => "foo"})
InitUser.instance.notify(:init, {:name => "foo"})
InitUser.instance.notify(:save, {:name => "foo"})
