require 'concurrent'                               # => true
require 'algebrick'                                # => true

# Actor message protocol definition with Algebrick
Protocol = Algebrick.type do
  variants Add      = type { fields! a: Numeric, b: Numeric },
           Subtract = type { fields! a: Numeric, b: Numeric }
end                                                # => Protocol(Add | Subtract)

class Calculator < Concurrent::Actor::RestartingContext
  include Algebrick::Matching

  def on_message(message)
    # pattern matching on the message with deconstruction
    # ~ marks values which are passed to the block
    match message,
          (on Add.(~any, ~any) do |a, b|
            a + b
          end),
          # or use multi-assignment
          (on ~Subtract do |(a, b)|
            a - b
          end)
  end
end 

calculator = Calculator.spawn('calculator')
    # => #<Concurrent::Actor::Reference /calculator (Calculator)>
calculator.ask! Add[1, 2]                          # => 3
calculator.ask! Subtract[1, 0.5]                   # => 0.5
calculator << :terminate!
    # => #<Concurrent::Actor::Reference /calculator (Calculator)>
