module Valuables

  class Default

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def name
      @object.response
    end

    def raw
      @object.response
    end

    def display_name
      self.name
    end

  end

end
