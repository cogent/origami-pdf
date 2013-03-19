=begin

= File
	actions.rb

= Info
	This file is part of Origami, PDF manipulation framework for Ruby
	Copyright (C) 2010	Guillaume Delugré <guillaume AT security-labs DOT org>
	All right reserved.
	  
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

module Origami

  class PDF

    #
    # Lookup script in the scripts name directory.
    #
    def get_script_by_name(name)
      resolve_name Names::Root::JAVASCRIPT, name
    end
    
    #
    # Calls block for each named JavaScript script.
    #
    def each_named_script(&b)
      each_name(Names::Root::JAVASCRIPT, &b) 
    end
  end

  #
  # Class representing an action to launch in a PDF.
  #
  class Action < Dictionary
    
    include StandardObject

    field   :Type,    :Type => Name, :Default => :Action
    field   :S,       :Type => Name, :Required => true
    field   :Next,    :Type => [ Array, Dictionary ], :Version => "1.2"
   
    #
    # Class representing a action going to a destination in the current document.
    #
    class GoTo < Action

      field   :S,       :Type => Name, :Default => :GoTo, :Required => true
      field   :D,       :Type => [ Array, Name, ByteString ], :Required => true

      #
      # Creates a new GoTo Action.
      # _hash_:: A hash of options to set for this jump.
      #
      def self.[](hash = {})
        if hash.is_a? Destination
          self.new(:S => :GoTo, :D => hash)
        else
          self.new(hash)
        end
      end
      
    end
    
    def self.GoTo(hash = {})
      Action::GoTo[hash]
    end

    #
    # Class representing an action launching an URL.
    #
    class URI < Action
     
      field   :S,       :Type => Name, :Default => :URI, :Required => true
      field   :URI,     :Type => ByteString, :Required => true
      field   :IsMap,   :Type => Boolean, :Default => false

      #
      # Creates a new URI Action.
      # _uri_:: The URI to launch.
      # _ismap_::
      #
      def self.[](uri, ismap = false)
        self.new(:URI => uri, :IsMap => ismap)
      end
    
    end

    def self.URI(uri, ismap = false)
      Action::URI[uri, ismap]
    end

    #
    # Class representing a JavaScript Action.
    #
    class JavaScript < Action
      
      field   :S,       :Type => Name, :Default => :JavaScript, :Required => true
      field   :JS,      :Type => [ Stream, String ], :Required => true

      #
      # Creates a new JavaScript Action.
      # _script_:: The script to be executed.
      #
      def self.[](script)
        self.new(:JS => script)
      end
    end

    def self.JavaScript(script)
      Action::JavaScript[script]
    end

    #
    # Class representing an Action which run a command on the current system.
    #
    class Launch < Action
     
      field   :S,         :Type => Name, :Default => :Launch, :Required => true
      field   :F,         :Type => [ ByteString, Dictionary ]
      field   :Win,       :Type => Dictionary
      field   :Mac,       :Type => Object
      field   :Unix,      :Type => Object
      field   :NewWindow, :Type => Boolean

      #
      # Dictionary for passing parameter to Windows applications during Launch.
      #
      class WindowsLaunchParams < Dictionary
        
        include StandardObject
       
        field   :F,         :Type => ByteString, :Required => true
        field   :D,         :Type => ByteString
        field   :O,         :Type => ByteString, :Default => "open"
        field   :P,         :Type => ByteString

      end
    end
    
    #
    # Class representing a Named Action.
    # Named actions are predefined GoTo actions.
    #
    class Named < Action
      
      field   :S,         :Type => Name, :Default => :Named, :Required => true
      field   :N,         :Type => Name, :Required => true

      def self.[](type)
        self.new(:N => type)
      end

      NEXTPAGE = self[:NextPage]
      PREVPAGE = self[:PrevPage]
      FIRSTPAGE = self[:FirstPage]
      LASTPAGE = self[:LastPage]
      PRINT = self[:Print]
    end

    def self.Named(type)
      Action::Named[type]
    end
    
    #
    # Class representing a GoTo Action to an external file.
    #
    class GoToR < Action

      field   :S,         :Type => Name, :Default => :GoToR, :Required => true
      field   :F,         :Type => [ ByteString, Dictionary ], :Required => true
      field   :D,         :Type => [ Array, Name, ByteString ], :Required => true
      field   :NewWindow, :Type => Boolean, :Version => "1.2"

      #
      # Creates a new GoTo remote Action.
      # _file_:: A FileSpec describing the file.
      # _dest_:: A Destination in the file.
      # _newwindow_:: Specifies whether the file has to be opened in a new window.
      #
      def self.[](file, dest = Destination::GlobalFit.new(0), newwindow = false)
        self.new(:F => file, :D => dest, :NewWindow => newwindow)
      end
      
    end

    def self.GoToR(file, dest = Destination::GlobalFit.new(0), newwindow = false)
      Action::GoToR[file, dest, newwindow]
    end
    
    #
    # Class representing a GoTo Action to an embedded pdf file.
    #
    class GoToE < Action
  
      field   :S,         :Type => Name, :Default => :GoToE, :Required => true
      field   :F,         :Type => [ Dictionary, ByteString ]
      field   :D,         :Type => [ Array, Name, ByteString ], :Required => true
      field   :NewWindow, :Type => Boolean
      field   :T,         :Type => Dictionary

      #
      # A class representing a target for a GoToE to an embedded file.
      #
      class EmbeddedTarget < Dictionary
        
        include StandardObject
        
        module Relationship
          PARENT = :P
          CHILD = :C
        end

        field   :R,           :Type => Name, :Required => true
        field   :N,           :Type => ByteString
        field   :P,           :Type => [ Integer, ByteString ]
        field   :A,           :Type => [ Integer, ByteString ]
        field   :T,           :Type => Dictionary
        
      end
    
      def self.[](filename, dest, newwindow = false)
        self.new(:T => EmbeddedTarget.new(:R => :C, :N => filename), :D => dest, :NewWindow => newwindow)
      end
      
    end

    def self.GoToE(filename, dest, newwindow = false)
      Action::GoToE[filename, dest, newwindow]
    end
    
    #
    # (PDF 1.2) Send data to a uniform resource locator. p703
    #
    class SubmitForm < Action
      
      module Flags
        INCLUDEEXCLUDE       = 1 << 0
        INCLUDENOVALUEFIELDS = 1 << 1
        EXPORTFORMAT         = 1 << 2
        GETMETHOD            = 1 << 3
        SUBMITCOORDINATES    = 1 << 4
        XFDF                 = 1 << 5 
        INCLUDEAPPENDSAVES   = 1 << 6
        INCLUDEANNOTATIONS   = 1 << 7
        SUBMITPDF            = 1 << 8
        CANONICALFORMAT      = 1 << 9
        EXCLNONUSERANNOTS    = 1 << 10
        EXCLFKEY             = 1 << 11
        EMBEDFORM            = 1 << 12
      end
     
      field   :S,           :Type => Name, :Default => :SubmitForm, :Required => true
      field   :F,           :Type => Dictionary
      field   :Fields,      :Type => Array
      field   :Flags,       :Type => Integer, :Default => 0

      def self.[](url, fields = [], flags = 0)
        url = FileSpec.new(:FS => :URL, :F => url) unless url.is_a? FileSpec
        self.new(:F => url, :Fields => fields, :Flags => flags)
      end
      
    end

    def self.SubmitForm(url, fields = [], flags = 0)
      Action::SubmitForm[url, fields, flags]
    end

    class ImportData < Action

      field   :S,           :Type => Name, :Default => :ImportData, :Required => true
      field   :F,           :Type => Dictionary, :Required => true

      def self.[](file)
        file = FileSpec.new(:FS => :File, :F => file) unless file.is_a? FileSpec
        self.new(:F => file)
      end
    
    end

    def self.ImportData(file)
      Action::ImportData[file]
    end

    class RichMediaExecute < Action

      field   :S,           :Type => Name, :Default => :RichMediaExecute, :Version => "1.7", :ExtensionLevel => 3, :Required => true
      field   :TA,          :Type => Dictionary, :Version => "1.7", :ExtensionLevel => 3, :Required => true
      field   :TI,          :Type => Dictionary, :Version => "1.7", :ExtensionLevel => 3
      field   :CMD,         :Type => Dictionary, :Version => "1.7", :ExtensionLevel => 3, :Required => true

      class Command < Dictionary
        include StandardObject

        field   :Type,      :Type => Name, :Default => :RichMediaCommand, :Version => "1.7", :ExtensionLevel => 3
        field   :C,         :Type => String, :Version => "1.7", :ExtensionLevel => 3, :Required => true
        field   :A,         :Type => Object, :Version => "1.7", :ExtensionLevel => 3
      end

      def self.[](annotation, command, *params)
        self.new(:TA => annotation, :CMD => Command.new(:C => command, :A => params))
      end
    
    end

    def self.RichMediaExecute(annotation, command, *params)
      Action::RichMediaExecute[annotation, command, *params]
    end
  
  end

end
