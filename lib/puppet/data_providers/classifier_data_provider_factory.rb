module Puppet::DataProviders
  class ClassifierDataProviderFactory < Puppet::Plugins::DataProviders::PathBasedDataProviderFactory
    def create(name, paths, parent_provider)
      ClassifierDataProvider.new(name, paths)
    end
  end

  class ClassifierDataProvider < Puppet::Plugins::DataProviders::PathBasedDataProvider
    include HieraInterpolate

    def unchecked_lookup(key, lookup_invocation, merge)
      lookup_invocation.with(:data_provider, self) do
        scope = lookup_invocation.scope

        unless scope.class_scope("classifier::node_data")
          lookup_invocation.report_not_found(key)
          throw :no_such_key
        end

        data = scope["classifier::node_data::data"]

        unless data
          lookup_invocation.report_not_found(key)
          throw :no_such_key
        end

        if data.include?(key)
          lookup_invocation.report_found(key, post_process(data[key], lookup_invocation))
        else
          lookup_invocation.report_not_found(key)
          throw :no_such_key
        end
      end
    end

    def post_process(value, lookup_invocation)
      interpolate(value, lookup_invocation, true)
    end
  end
end
