Puppet::Bindings.newbindings('classifier::default') do
  bind {
    name "classifier"
    in_multibind "puppet::path_based_data_provider_factories"
    to_instance "Puppet::DataProviders::ClassifierDataProviderFactory"
  }
end
