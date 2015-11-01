class megaraid (
  $virtual_disks
) {
  validate_hash($virtual_disks)

  realize(Package["storcli"])

  create_resources("megaraid_vd", $virtual_disks, {"require" => Package["storcli"]})
}
