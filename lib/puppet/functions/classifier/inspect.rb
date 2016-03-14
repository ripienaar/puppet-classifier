require 'pp'

Puppet::Functions.create_function(:"classifier::inspect") do
  def inspect(thing)
    "\n%s" % thing.pretty_inspect.chomp
  end
end
