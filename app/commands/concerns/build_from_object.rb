module BuildFromObject
  extend ActiveSupport::Concern

  class_methods do
    def build_from_object(resource)
      new(attributes_from_object(resource))
    end

    def build_from_object_and_attributes(resource, attributes)
      new(attributes_from_object(resource).merge(attributes).symbolize_keys)
    end

    def attributes_from_object(resource)
      [
        main_attributes_from(resource),
        extra_attributes_from(resource)
      ].reduce(&:merge)
    end

    # override this when attributes are not 1:1 mapped to resource attributes
    def extra_attributes_from(resource)
      return {} unless resource.respond_to?(:metadata)

      attributes_from_hash(resource.metadata)
    end

    def attributes_from_hash(hash)
      hash.with_indifferent_access.slice(*attribute_names)
    end

    def main_attributes_from(resource)
      attribute_names
        .select { |name| resource.respond_to?(name) }
        .map { |name| { name => resource.send(name) } }
        .reduce(&:merge) || {}
    end
  end
end
