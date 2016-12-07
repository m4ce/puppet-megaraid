#
# megaraid.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

if File.exists?('/sbin/lspci')
  Facter.add(:has_megaraid) do
    %x[/sbin/lspci | grep -q 'MegaRAID']
    has_megaraid = $?.success?
    setcode do
      has_megaraid
    end
  end
end
