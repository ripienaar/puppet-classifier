What?
=====

An attempt to port https://github.com/binford2k/puppet-classifier to pure Puppet 4 DSL

Sample Data
-----------

Sticking this in Hiera will create a rule that on RedHat VMs will include the class `centos::vm` and on the node `node.example.net` it will also include `sensu` and whatever rules are matching.

```
# common.yaml
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
classifier::classes:
  - sensu
```

```
node default {
  include classifier
}
```

Contact?
--------

R.I.Pienaar / rip@devco.net / http://www.devco.net/ / @ripienaar
