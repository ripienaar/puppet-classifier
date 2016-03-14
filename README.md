What?
=====

An attempt to port https://github.com/binford2k/puppet-classifier to pure Puppet 4 DSL.

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
      - fact: os.family
        operator: ==
        value: RedHat
      - fact: is_virtual
        operator: ==
        value: true
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

Reference
---------

The full type description of a rule is:

```
Hash[String,
  Struct[{
    match => Enum["all", "any"],
    rules    => Array[
      Struct[{
        fact     => String,
        operator => Enum["==", "=~", ">", " =>", "<", "<="],
        value    => Data,
        invert   => Optional[Boolean]
      }]
    ],
    classes  => Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]]
  }]
] $rules = {},
```

A few notes:

### match
Match can be either `any` or `all` and it means that in the case where you have many `rules`
they must either all match a node or at least one.

### fact
The fact at present takes the form `os.family` which maps to `$facts[os][family]`, at present it
only supports data from facts and nothing else.  This is due to some bug in the new Hiera which
should be fixed soon ans you can put anything there

## operator
Valid operators are `"==", "=~", ">", " =>", "<", "<="`, most of these comparisons are done using
the `versioncmp` function so you should probably understand it to really grasp what these will do.

In time I'd consider adding some others here, not really sure what makes sense.

## invert
This inverts the match so setting it true just swaps the whole comparison around, so there is no
`!=` operator for example, but you can achieve that using the `==` one and inverting it

Issues
------

Ideally the fact within a classification would not be limited to facts but rather anything
Hiera knows.  But due to PUP-6054 this does not work in Environment data only in classic
Hiera, so for now the `fact` on a rule has to be a `.` seperated path within the `$facts`
hash.

Contact?
--------

R.I.Pienaar / rip@devco.net / http://www.devco.net/ / @ripienaar
