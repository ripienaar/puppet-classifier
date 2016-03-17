What?
=====

An attempt to port and expand https://github.com/binford2k/puppet-classifier to pure Puppet 4 DSL.

This is a node classifier where you can write classification rules that perform boolean matches on
fact data and should a rule match some classes will be included.  Any number of classification
rules can match on a given node and they can all contribute classes.

Different data tiers can contribute rules and it has a way to just add classes statically like
the old `hiera_include()` approach.

Sample Data
-----------

Sticking this in Hiera will create a classification that on RedHat VMs will include the classes `centos::vm` and on the node `node.example.net` it will also include `ntp` in addition.

```
# common.yaml
classifier::extra_classes:
 - sensu
classifier::rules:
  RedHat VMs:
    match: all
    rules:
      - fact: "%{facts.os.family}"
        operator: ==
        value: RedHat
      - fact: "%{facts.is_virtual}"
        operator: ==
        value: "true"
    data:
      redhat_vm: true
    classes:
      - centos::vm
```

```
# node.example.net.yaml
# remove sensu and install nagios instead, also add extra stuff
classifier::extra_classes:
  - --sensu,nagios
```

```
# clients/acme.yaml
# adjust the RedHat VMs rule to add ntp on node
# these machines but also to remove centos::vm and
# install centos::core instead
classifier::rules:
  RedHat VMs:
    data:
      client_redhat: true
    classes:
      - ntp
      - --centos::vm,centos::core

# add acme client team
classifier::extra_classes:
  - acme::sysadmins
```

```
node default {
  include classifier
}
```

The `extra_classes` parameter lets you specify a array of additional classes without having to construct
rules and they are setup with a knockout of `--` so that you can remove lower down results.

At present you can't knockout classes included by rules using a knockout prefix on `extra_classes`, this
os something that's planned

You can have many classification rules and which ever match can contribute classes to add

Other classes can access detail about the classification result:

  * *$classifier::classification* - a array of Hashes with matching Rule names and classes
  * *$classifier::classification_classes* - just the classes extracted from the classification
  * *$classifier::extra_classes* - the extra classes resolved from hiera
  * *$classifier::classes* - the list of classes that will be included
  * *$classifier::data[...]* - hash of all the data created by the tiers

Reference
---------

The full type description of a rule is:

```
Hash[String,
  Struct[{
    match    => Enum["all", "any"],
    rules    => Array[
      Struct[{
        fact     => String,
        operator => Enum["==", "=~", ">", " =>", "<", "<="],
        value    => Data,
        invert   => Optional[Boolean]
      }]
    ],
    data     => Optional[Hash[Pattern[/\A[a-z0-9_][a-zA-Z0-9_]*\Z/], Data]],
    classes  => Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]]
  }]
] $rules = {},
```

A number of custom types are defined for things like the list of valid operators, valid
variable and class names, matches, individual rule and the whole classification.  Should
you wish to build additional classes that consume data from this tool please validate the
input using them

  * *Classifier::Classification* - a single classification made up of rules, classes, data and match type
  * *Classifier::Classifications* - a collection of classifications
  * *Classifier::Matches* - the list of valid match types
  * *Classifier::Rule* - a single rule inside a classification
  * *Classifier::Data* - valid data items
  * *Classifier::Operators* - valid operators

A few notes:

### match
Match can be either `any` or `all` and it means that in the case where you have many `rules`
they must either all match a node or at least one.

### fact
Use Hiera interprolation to put any fact or trusted data into the rule set. Take note in hiera
to interpolate data you have to quote things like this `"${facts.thing}"` which coherse the data
into a string.  In the example rule above a boolean fact is cohersed to a string in this manner
and so the match value has to be `"true"` as well.

## operator
Valid operators are `"==", "=~", ">", " =>", "<", "<="`, most of these comparisons are done using
the `versioncmp` function so you should probably understand it to really grasp what these will do.

In time I'd consider adding some others here, not really sure what makes sense.

## invert
This inverts the match so setting it true just swaps the whole comparison around, so there is no
`!=` operator for example, but you can achieve that using the `==` one and inverting it

## data
This is an optional hash of data items kind of like facts, these are accessible in a hash calledcw
`$classification::data[..]` after classification

Exposing Data to Hiera
----------------------

It's a bit meta but as you can see the classifications can create `data` which are merged together.

It would be great if these rules could create data that is used by classes during the Automatic
Parameter Lookup phase, so that your classification can set `someklass::someparam` and they would
be used when `someklass` gets included.

This module includes an Environment Data Provider that does just that, to configure it do something
like this in your environment `hiera.yaml`

```
---
version: 4
datadir: "hieradata"
hierarchy:
  - name: "%{trusted.certname}"
    backend: "yaml"

  - name: "classification data"
    backend: "classifier"

  - name: "common"
    backend: "yaml"
```

Here we load the `classifier` backend or data provider and any data you create here will be usable
in classes or via `lookup()`.

Obviously as this is inside Puppet there's some issues with exposing this to the `lookup` CLI by
default.  You'd generally use this via:

```
node default { include classifier }
```

in your site manifest.  In that case a `puppet lookup --compile some::key` will do the right thing
for whatever node you're doing a lookup for.

Contact?
--------

R.I.Pienaar / rip@devco.net / http://www.devco.net/ / @ripienaar
