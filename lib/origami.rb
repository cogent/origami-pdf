=begin

= File
	origami.rb

= Info
	Origami is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Origami is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with Origami.  If not, see <http://www.gnu.org/licenses/>.

=end


if RUBY_VERSION < '1.9'
  class Fixnum
    def ord; self; end
  end

  class Hash
    alias key index
  end
end

module Origami
  VERSION   = "1.2.6"
  REVISION  = "$Revision$" #:nodoc:
  
  #
  # Global 
  # options for Origami.
  #
  OPTIONS   = 
  {
    :enable_type_checking => true,      # set to false to disable type consistency checks during compilation.
    :enable_type_guessing => true,      # set to false to prevent the parser to guess the type of special dictionary and streams (not recommended).
    :use_openssl => true,               # set to false to use Origami crypto backend.
    :ignore_bad_references => false,    # set to interpret invalid references as Null objects, instead of raising an exception.
    :ignore_zlib_errors => false,       # set to true to ignore exceptions on invalid Flate streams.
  }
end

require 'origami/pdf'
require 'origami/extensions/fdf'
require 'origami/extensions/ppklite'

