module YTLJit

  module AsmType
    class TypeCommon
      def initialize
        @type = nil
        @size = nil
        @alignment = nil
      end

      attr :type
      attr :size
      attr :alignment
    end

    class Scalar<TypeCommon
      def initialize(size, align = 4, kind = :int)
        @size = size
        @alignment = align
        @kind = kind
      end

      attr :kind
    end

    class PointedData<TypeCommon
      def initialize(type, index, offset)
        @type = type
        @index = index
        @offset = offset + index * type.size
      end

      attr :index
      attr :offset

      def size
        @type.size
      end

      def [](*args)
        @type[*args]
      end

      def alignment
        @type.alignment
      end
    end
    
    class Pointer<TypeCommon
      def initialize(type)
        @type = type
      end
      
      def size
        MACHINE_WORD.size
      end
      
      def alignment
        MACHINE_WORD.alignment
      end
      
      def [](n = 0, offset = 0)
        PointedData.new(@type, n, offset)
      end
    end

    class Array<TypeCommon
      def initialize(type, size)
        @type = type
        @size = size
      end

      def size
        @size * @type.size
      end

      def alignment
        @type.alignment
      end
      
      def [](n = 0, offset = 0)
        PointedData.new(@type, n, offset)
      end
    end
    
    @@type_table = {}
    def self.deftype(name, tinfo)
      type = Scalar.new(*tinfo)
      const_set(name.to_s.upcase, type)
      @@type_table[name] = type
    end
    
    def self.type_table
      @@type_table
    end
    
    deftype :void, [0, 1]
    deftype :int8, [1, 1]
    deftype :sint8, [1, 1]
    deftype :uint8, [1, 1]
    deftype :int16, [2, 2]
    deftype :uint16, [2, 2]
    deftype :int32, [4, 4]
    deftype :uint32, [4, 4]
    deftype :int64, [8, 8]
    deftype :uint64, [8, 8]
    deftype :double, [8, 8]
    deftype :float, [4, 4]

    case $ruby_platform
    when /i.86/ 
      deftype :machine_word, [4, 4]

    when /x86_64/
      deftype :machine_word, [8, 8]
    end
  end
end
