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
Manage virtual disks using storcli

##### Example:
```
megaraid_vd {"data":
  controller => 0,
  raid_type => 1,
  drives => "1,2" # If the Enclosure ID is not given, the first one available will be picked (this will generate a warning message though)
}
```

##### Attributes
| Name | Description | Possible values | Default Value | Required |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| vd_name | Virtual disk name | String | namevar | yes |
| ensure | Creates or destroy virtual disk | present, absent | present | yes |
| controller | Controller Index | Integer | | yes |
| raid_type | RAID type | 0, 1, 5, 6, 10, 50, 60 | | yes |
| iopolicy | Logical drive cache policy | direct, cached | | no |
| writepolicy | Write policy | wb, wt | | no |
| accesspolicy | Access policy | rw, ro, blocked, rmvblkd | | no |
| readpolicy | Read policy | ra, nora | | no |
| drives | Physical drives to use | [e:]s&#124;[e:]s-x&#124;[e:]s-x,y,[e:]s-x,y,z | yes |
| spares | Physical drives to be used as spares | [e:]s&#124;[e:]s-x&#124;[e:]s-x,y,[e:]s-x,y,z | | no |
| pdperarray | Number of physical drives per array | 0..15  | | no |
| strip | Strip size | 8, 16, 32, 64, 128, 256, 512, 1024| | no |
| pdcache | Enables or disables PD cache | on, off, default | | no |
| sed | Creates security-enabled drives | Boolean | | no |
| pi | Enables protection information | Boolean | | no |
| dimmerswitch | Power-saving policy | automatic, non, max, maxnocache | | no |
| aftervd | Creates the VD in the adjacent free slot next to the specified VD | Integer | | no |
| force | Forces a security-capable physical drive to be added to a drive group without security | Boolean | false | no |

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
