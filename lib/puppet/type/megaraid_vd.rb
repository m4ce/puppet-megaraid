#
# megaraid_vd.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

Puppet::Type.newtype(:megaraid_vd) do
  @doc = "Manage MegaRAID virtual disks through StorCLI"

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:vd_name, :namevar => true) do
    desc "Specifies the drive name for each virtual drive"
  end

  newparam(:controller) do
    desc "Controller Index"

    newvalues(/^\d+/)
  end

  newparam(:raid_type) do
    desc "Sets the RAID type of the configuration"

    newvalues(/^[0|1|5|6|10|50|60]$/)
  end

  newproperty(:iopolicy) do
    desc "Sets the logical drive cache policy"

    newvalues(:direct, :cached)
  end

  newproperty(:writepolicy) do
    desc "Sets the write policy"

    newvalues(:wb, :wt)
  end

  newproperty(:accesspolicy) do
    desc "Sets the access policy"

    newvalues(:rw, :ro, :blocked, :rmvblkd)
  end

  newproperty(:readpolicy) do
    desc "Sets the read policy"

    newvalues(:ra, :nora)
  end

  newparam(:drives) do
    desc "Specifies the drives to use (e:s|e:s-x|e:s-x,y,e:s-x,y,z)"
  end

  newparam(:spares) do
    desc "Specifies the physical drives that are to be assigned to a disk group for spares"
  end

  newparam(:pdperarray) do
    desc "Specifies the number of physical drives per array. The default value is automatically chosen"

    validate do |value|
      unless value >= 0 and value <= 15
        raise ArgumentError, "Physical drives per array must be between 0 and 15"
      end
    end
  end

  newparam(:strip) do
    desc "Sets the strip size for the RAID configuration"

    newvalues(/^[8|16|32|64|128|256|512|1024]$/)
  end

  newproperty(:pdcache) do
    desc "Enables or disables PD cache"

    newvalues(:on, :off, :default)
  end

  newparam(:sed) do
    desc "Creates security-enabled drives"

    newvalues(:true, :false)
  end

  newparam(:pi) do
    desc "Enables protection information"

    newvalues(:true, :false)
  end

  newparam(:dimmerswitch) do
    desc "Specifies the power-saving policy. Sets to default automatically"

    newvalues(:automatic, :none, :max, :maxnocache)
  end

  newparam(:aftervd) do
    desc "Creates the VD in the adjacent free slot next to the specified VD"
  end

  newparam(:force) do
    desc "Forces a security-capable physical drive to be added to a drive group without security"

    defaultto(:false)
    newvalues(:true, :false)
  end

  validate do
    raise Puppet::Error, "Controller index is required." unless self[:controller]

    if self[:ensure] == :present
      raise Puppet::Error, "RAID type is required." unless self[:raid_type]
      raise Puppet::Error, "Must specify a list of drives for the VD." unless self[:drives]

      Puppet.warning("MegaRAID: no Enclosure ID specified in list of the drives for VD #{self[:name]}. The first EID available will be used.") unless self[:drives] =~ /^\d+:/

      if self[:spares]
        Puppet.warning("MegaRAID: no Enclosure ID specified in list of the spares for VD #{self[:name]}. The first EID available will be used.") unless self[:spares] =~ /^\d+:/
      end
    end
  end
end
