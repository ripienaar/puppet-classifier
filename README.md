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
  - client::sysadmins
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

Other classes can access detail about the classification result:

  * *$classifier::classification* - a array of Hashes with matching Rule names and classes
  * *$classifier::classification_classes* - just the classes extracted from the classification
  * *$classifier::extra_classes* - the extra classes resolved from hiera
  * *$classifier::classes* - the list of classes that will be included


Issues
------

Ideally the fact within a classification would not be limited to facts but rather anything
Hiera knows.  But due to PUP-6054 this does not work in Environment data only in classic
Hiera, so for now the `fact` on a rule has to be a `.` seperated path within the `$facts`
hash.

Contact?
--------

R.I.Pienaar / rip@devco.net / http://www.devco.net/ / @ripienaar
