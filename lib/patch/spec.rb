module Patch

  # Helper for dealing with spec files
  module Spec

    extend self

    # Given a file name, file or hash, populate a spec hash
    # @param [File, Hash, String] object
    # @return [Hash]
    def new(object)
      spec_file = case object
                  when File, String then object
                  end
      case spec_file
      when nil then object
      else YAML.load_file(spec_file)
      end
    end
    
  end
end
