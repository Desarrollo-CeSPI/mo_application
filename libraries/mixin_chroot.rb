class MoApplication
  module ChrootResourceBase
    def self.included(klass)
      klass.attribute :path, :kind_of => String, :name_attribute => true
      klass.attribute :copy_files, :kind_of => [Array,String], :default => []
    end
  end
end
