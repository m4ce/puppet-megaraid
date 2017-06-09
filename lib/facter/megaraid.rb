#
# megaraid.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

if Facter::Core::Execution.which('lspci')
  Facter.add(:has_megaraid) do
    setcode do
      Facter::Core::Execution.execute('lspci').include? 'MegaRAID'
    end
  end
end