class HeroObserver

  # Constructor...
  #
  # @example
  #   events = {
  #     :create_user => [
  #       FixData,
  #       Validate,
  #       etc...
  #     ],
  #     :checkout => [
  #       Verify,
  #       Charge,
  #       etc...
  #     ]
  #   }
  #
  # HeroObserver.new(hero, events)
  # @param [Hero] hero The Hero object to watch.
  # @param [Hash] handlers A Hash containing event names and the handlers to run at each event.
  def initialize(hero, handlers)
    @handlers = handlers
    hero.instance.add_observer(self)
  end

  # Callback invoked whenever a Hero event is triggered.
  #
  # @param [String] event_name The name of the event.
  # @param [Object] target The target of the event.
  # @param [Hash] options An options Hash that gets forwarded to the rules.
  def update(event_name, target, options={})
    handler = @handlers[event_name] || []
    handler.each do |handler|
      handler_name = handler.name
      handler.call(target, options)
    end
  end

end

