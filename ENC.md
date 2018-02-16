External Node Classifier
========================

## Intro
The way this Hiera based classifier works does not let it set the environment
like in traditional ENCs.  This is because the classification is done during
compilation and Puppet does not support setting the environment at that point.

In order to set the environment of a node using this classifier a small helper
ENC is provided.

## Functionality supported by the helper ENC

  * Looking up 'classifier::environment' from a set of directories and patterns that map to YAML or JSON files
  * Including the main 'classifier' class
  * Setting a few data items in the classifier class to indicate how the environment was set
  * Supports a default environment
  * Writing debug lines to a log file, set `--debug /some/file`

## Implementation
So given a file '/etc/puppetlabs/code/hieradata/node.example.yaml' with the following in it:

```
classifier::environment: development
```

And the ENC configured like this:

```
[main]
node_terminus = exec
external_nodes = /usr/local/bin/classifier_enc.rb --data-dir /etc/puppetlabs/code/hieradata --node-pattern %%.yaml
```

It will consult `/etc/puppetlabs/code/hieradata` directory looking for `node.example.yaml`, look for
'classifier::environment' variable in `node.example.yaml` and classify the environment accordingly.

The `--data-dir` be multiple paths seperated by `:` (or whatever PATH seperator
your OS use) and can contain globs parsed with `Dir.glob`

So if you use the environment data instead of site wide data you can do (this is the default):

```
--data-dir /etc/puppetlabs/code/environments/*/hieradata
```

This will expand to every environment you have and they will all be checked for
the data file matching the `--node-pattern`

A sample classification that gets sent to Puppet will look like:

```
---
environment: production
classes:
  classifier:
    enc_used: true
    enc_source: /etc/puppetlabs/code/hieradata/node.example.yaml
    enc_environment: production
```

## Migrating from classification to classification and environment setting.
You might be caught out by having previously set default node config to include ```classifier``` class. Doing this will result in puppet
complaining about a duplicate class declaration. Thus be sure the remove the classifier class from your default node config, as the action of
setting the environment also includes the classifier class as stated above.
