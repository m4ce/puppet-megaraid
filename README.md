# Puppet types and providers for LSI MegaRAID

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the megaraid module](#setup)
4. [Reference - Types reference and additional functionalities](#reference)
5. [Hiera integration](#hiera)
6. [Contact](#contact)

## Overview

This module implements native types and providers to manage some aspects of LSI MegaRAID devices.

## Module Description

The megaraid module allows to automate the configuration of LSI MegaRAID devices. Currently, it only supports managing virtual disks.

## Setup

The module requires the storcli package in order to manage MegaRAID volumes. An RPM version is available for download [here](ftp://ftp.supermicro.com/Driver/SAS/LSI/Tools/storcli_6.6-1.14.12/Linux/storcli-1.14.12-1.noarch.rpm).

A custom fact named 'has_megaraid' defines whether your system is equipped with one or more LSI MegaRAID devices.

You can use that fact to optionally include the megaraid class in your manifests as shown below:


```
if $::has_megaraid {
  include megaraid
}
```

## Reference

### Types

#### megaraid_vd
`megaraid_vd` manages virtual disks using the StorCLI utility

```
megaraid_vd {"data":
  controller => 0,
  raid_type => 1,
  drives => "1,2" # If the Enclosure ID is not given, the first one available will be picked (this will generate a warning message though)
}
```

##### `name` (required)
Name to describe the VD

##### `vd_name`
Virtual disk name, defaults to name

##### `ensure` (required)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

##### `controller` (required)
Controller Index, must be an Integer

##### `raid_type` (required)
RAID type. Valid values are: 0, 1, 5, 6, 10, 50, 60.

##### `iopolicy`
Logical drive cache policy. Valid values are: 'direct', 'cached'.

##### `writepolicy`
Write policy. Valid values are: 'wb', 'wt'.

##### `accesspolicy`
Access policy. Values values are: 'rw', 'ro', 'blocked', 'rmvblkd'.

##### `readpolicy`
Read policy. Values values are: 'ra', 'nora'.

##### `drives` (required)
Physical drives to use. Valid syntax is [e:]s|[e:]s-x|[e:]s-x,y,[e:]s-x,y,z

##### `spares`
Physical drives to be used as spares. Valid syntax is [e:]s|[e:]s-x|[e:]s-x,y,[e:]s-x,y,z

##### `pdperarray`
Number of physical drives per array. Must be an Integer between 0..15.

##### `strip`
Strip size. Valid values are: 8, 16, 32, 64, 128, 256, 512, 1024.

##### `pdcache`
Enables or disables PD cache. Valid values are: on, off, default.

##### `sed`
Creates security-enabled drives. Must be a Boolean.

##### `pi`
Enables protection information. Must be a Boolean.

##### `dimmerswitch`
Power-saving policy. Valid values are: automatic, none, max, maxnocache.

##### `aftervd`
Creates the VD in the adjacent free slot next to the specified VD.

##### `force`
Forces a security-capable physical drive to be added to a drive group without security. Must be a Boolean, default is false.

## Hiera integration

You can optionally define your virtual disks in Hiera using the megaraid::virtual_disks class parameter.

```
---
megaraid::virtual_disks:
  data1:
    controller: 0
    raid_type: 1
    drives: 1,2
    iopolicy: "direct"
    writepolicy: "wb"
    readpolicy: "ra"
  data2:
    controller: 0
    raid_type: 10
    drives: 3-6
    strip: 512
```

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk
