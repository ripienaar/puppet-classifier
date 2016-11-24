What?
=====

An attempt to port and expand https://github.com/binford2k/puppet-classifier to pure Puppet 4 DSL.

This is a node classifier where you can write classification rules that perform boolean matches on
fact data and should a rule match some classes will be included.  Any number of classification
rules can match on a given node and they can all contribute classes.

Different data tiers can contribute rules and it has a way to just add classes statically like
the old `hiera_include()` approach.

**NOTE:** I'm using semver and as this is still less than 1.0.0 expect breaking changes to happen.

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
  - --sensu
  - nagios
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
      - --centos::vm
      - centos::core

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
  * *$classifier::enc_used* - boolean indicating if the ENC was used
  * *$classifier::enc_source* - path to the data file that was matched and supplied the environment, undef when not used
  * *$classifier::enc_environment* - the environment the ENC set, undef when not used

Reference
---------

The full type description of a rule is:

```
Hash[String,
  Struct[{
    match    => Optional[Enum["all", "any"]],
    rules    => Array[
      Struct[{
        fact     => Optional[Data],
        operator => Enum["==", "=~", ">", " =>", "<", "<=", "in", "has_ip_network"],
        value    => Data,
        invert   => Optional[Boolean]
      }]
    ],
    data     => Optional[Hash[Pattern[/\A[a-z0-9_][a-zA-Z0-9_]*\Z/], Data]],
    classes  => Optional[Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]]]
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
  * *Classifier::Node* - classification result for a node

A few notes:

### match
Match can be either `any` or `all` and it means that in the case where you have many `rules`
they must either all match a node or at least one.

### fact
Use Hiera interprolation to put any fact or trusted data into the rule set. Take note in hiera
to interpolate data you have to quote things like this `"${facts.thing}"` which coherse the data
into a string.  In the example rule above a boolean fact is cohersed to a string in this manner
and so the match value has to be `"true"` as well.

The fact is optional, since some times like in the case of `has_ip_network` for example it does
not make sense since it checks a range of facts from the node.

## operator
Valid operators are `"==", "=~", ">", " =>", "<", "<=", "in", "has_ip_network"`, most of these comparisons
are done using the `versioncmp` function so you should probably understand it to really grasp what
these will do.

There are a special ones planned like the current `has_ip_network` which comes from `stdlib`, when
using that the `fact` is optional, so something like:

```
Development Servers:
  rules:
    - operator: has_ip_network
      value: 192.168.88.0
  classes:
    - development
```

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

in your site manifest.  You can include other classes manually under this but generally you want the
classifier included first so it can create all the data and other classes can all be configured using
it.

An alternative is to use the included ENC which will include the classifier for you and supports
setting the environment based on hiera data.  See ENC.md.

In that case a `puppet lookup --compile some::key` will do the right thing for whatever node you're
doing a lookup for.

Setting The Environment?
------------------------

You can set the environment of a node with the help of a ENC included in bin, see ENC.md

Future Plans?
-------------

I want to expand the rules so you can use other functions to do evaluation, things like checking if
a node IP belongs to a certain subnet for example, this could be done by adding functions to the
classifier and them into the `classifier::evaluate_rule` function as operators perhaps.

At the moment there is `has_ip_network`, I am not really sure if this is a good fit so that's experimental
while I figure it out.  It might be nice to support any function call there not just ones that's hardcoded
in `classifier::evaluate_rule` in order to make the classifier user extendible at their site using any
functions they might have. If we only supported a bunch of hard coded ones I can imaginet his becoming a
huge nightmare to support in the long term as users might want to add many such matchers.  A more extendible
approach makes more sense.

But down that road lies basically doing `eval()` in puppet and this is just a terrible terrible idea
so I am not sure what's best.  It would be very easy to write a function dispatch for any function
that exists, but really it would not be a good idea.

Contact?
--------

R.I.Pienaar / rip@devco.net / http://www.devco.net/ / @ripienaar
