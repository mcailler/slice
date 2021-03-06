require 'valuables/domain_response'

module Valuables

  class NumericResponse < DomainResponse

    def name
      hash_name_or_response
    end

    def raw
      begin
        Float(@object.response)
      rescue
        @object.response
      end
    end

    def display_name
      hash_display_name_or_response
    end

    private

    def response_with_add_on
      @object.response.blank? ? "" : [@object.variable.prepend, @object.response, @object.variable.units, @object.variable.append].compact.join(' ').squish
    end

    def hash_name_or_response
      hash_value_and_name.blank? ? response_with_add_on : hash_value_and_name
    end

    def hash_display_name_or_response
      hash_display_name.blank? ? response_with_add_on : hash_display_name
    end

  end

end
