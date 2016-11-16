#!/usr/bin/env ruby
#
# megaraid.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

%x[/sbin/lspci | grep -q 'MegaRAID']
has_megaraid = $?.success? ? true : false
Facter.add("has_megaraid") do
  setcode do
    has_megaraid
  end
end
