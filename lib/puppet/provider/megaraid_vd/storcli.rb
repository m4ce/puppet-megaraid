#
# storcli.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'json'

Puppet::Type.type(:megaraid_vd).provide(:storcli) do
  desc "Manages MegaRAID virtual disks through StoreCLI"

  commands :storcli => "/opt/MegaRAID/storcli/storcli64"

  def self.instances
    instances = []
    data = JSON.parse(storcli("/call", "/vall", "show", "all", "J"))
    data['Controllers'].each do |controller|
      controller_id = controller['Command Status']['Controller']
      controller.fetch('Response Data',{}).each do |k, v|
        if k =~ /^\/c\d+\/v\d+$/
          vd = v.first
          dg_index, vd_index = vd['DG/VD'].split('/')
          vd_properties = controller['Response Data']["VD#{vd_index} Properties"]

          instances << new(
            :name => vd['Name'],
            :dg_index => dg_index.to_i,
            :vd_index => vd_index.to_i,
            :controller => controller_id,
            :raid_type => vd['TYPE'].gsub(/RAID/, '').to_i,
            :state => vd['State'],
            :accesspolicy => vd['Access'].downcase,
            :consist => vd['Consist'],
            :readpolicy => case vd['Cache']
                           when /^R/
                             :ra

                           when /^NR/
                             :nora
                         end,
            :writepolicy => case vd['Cache']
                           when /WB/
                             :wb

                           when /WT/
                             :wt
                         end,
            :iopolicy => case vd['Cache']
                           when /D$/
                             :direct

                           when /C$/
                             :cached
                         end,
            :scc => (vd['sCC'] == '-') ? nil : vd['sCC'],
            :size => vd['Size'],
            :strip => vd_properties["Strip Size"][/\d+/],
            :pi => (vd_properties["Data Protection"] == "Enabled") ? :true : :false,
            :encryption => (vd_properties["Encryption"] == "None") ? nil : vd_properties["Encryption"],
            :pdcache => case vd_properties["Disk Cache Policy"]
                          when "Enabled"
                            :on

                          when "Disabled"
                            :off

                          else
                            :default
                        end,
            :ensure => :present
          )
        end
      end
    end

    instances
  end
  #rescue
  #  raise Puppet::Error, "Failed to look up virtual disks (#{$!})"
  #end

  def self.prefetch(resources)
    vds = instances
    resources.each do |name, resource|
      if provider = vds.find { |vd| vd.name == name and vd.controller == resource[:controller] }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    cmd = []
    cmd << "/c#{@resource[:controller]} add vd r#{@resource[:raid_type]} name=#{@resource[:name]}"

    drives = nil

    # user specified Enclosure ID, good
    if @resource[:drives] =~ /^\d+:/
      drives = @resource[:drives]
    else
      data = JSON.parse(storcli("/c#{@resource[:controller]}", "/eall", "show", "J"))

      # let's get the first enclosure ID available
      eid = data['Controllers'][0]['Response Data']['Properties'].first['EID'].to_i

      drives="#{eid}:#{@resource[:drives]}"
    end
    cmd << "drives=#{drives}" if drives

    cmd << "spares=#{@resource[:spares]}" if @resource[:spares]
    cmd << "pdperarray=#{@resource[:pdperarray]}" if @resource[:pdperarray]
    cmd << "pdcache=#{@resource[:pdcache]}" if @resource[:pdcache]
    cmd << "dimmerswitch=#{@resource[:dimmerswitch]}" if @resource[:dimmerswitch]
    cmd << @resource[:iopolicy] if @resource[:iopolicy]
    cmd << @resource[:writepolicy] if @resource[:writepolicy]
    cmd << @resource[:readpolicy] if @resource[:readpolicy]
    cmd << "Strip=#{@resource[:strip]}" if @resource[:strip]
    cmd << "AfterVd=#{@resource[:aftervd]}" if @resource[:aftervd]

    cmd << "pi" if @resource[:pi]
    cmd << "force" if @resource[:force]

    storcli(cmd.join(' '))

    @property_hash[:ensure] = :present
  end

  def destroy
    cmd = []

    # retrieve vd index

    cmd << "/c#{@resource[:controller]} /v#{@property_hash[:vd_index]} delete"
    cmd << "force" if @resource[:force]

    storcli(cmd.join(' '))

    @property_hash.clear
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def iopolicy=(value)
    @property_flush[:iopolicy] = value
  end

  def pdcache=(value)
    @property_flush[:pdcache] = value
  end

  def writepolicy=(value)
    @property_flush[:writepolicy] = value
  end

  def readpolicy=(value)
    @property_flush[:readpolicy] = value
  end

  def flush
    storcli("/c#{@resource[:controller]}", "/v#{@property_hash[:vd_index]}", "set", "iopolicy=#{@property_flush[:iopolicy]}") if @property_flush[:iopolicy]
    storcli("/c#{@resource[:controller]}", "/v#{@property_hash[:vd_index]}", "set", "pdcache=#{@property_flush[:pdcache]}") if @property_flush[:pdcache]
    storcli("/c#{@resource[:controller]}", "/v#{@property_hash[:vd_index]}", "set", "wrcache=#{@property_flush[:writepolicy]}") if @property_flush[:writepolicy]
    storcli("/c#{@resource[:controller]}", "/v#{@property_hash[:vd_index]}", "set", "rdcache=#{@property_flush[:readpolicy]}") if @property_flush[:readpolicy]
  end
end
