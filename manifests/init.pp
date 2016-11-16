class megaraid (
  Hash $packages,
  Hash $virtual_disks
) {

  $packages.each |String $package_name, Hash $package| {
    package {$package_name:
      * => $package
    }
  }

  $virtualdisks.each |String $vd_name, Hash $vd| {
    megaraid_vd {$vd_name:
      * => $vd
    }
  }
}
