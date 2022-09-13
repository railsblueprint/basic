module UniquenessValidator
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  class_methods do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    # this code is mostly copied from ActiveRecord::Validations::UniquenessValidator
    class UniquenessValidator < ActiveRecord::Validations::UniquenessValidator
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
      def validate_each(record, attribute, value)
        finder_class = record.adapter
        value = map_enum_attribute(finder_class, attribute, value)
        begin
          relation = build_relation(finder_class, attribute, value)
          if record.try(:id).present?
            if finder_class.primary_key
              relation = relation.where.not(finder_class.primary_key => record.id)
            else
              raise ActiveRecord::UnknownPrimaryKey.new(
                finder_class,
                "Can not validate uniqueness for persisted record without primary key."
              )
            end
          end
          relation = scope_relation(record, relation)

          if options[:conditions]
            conditions = options[:conditions]

            relation = if conditions.arity.zero?
                         relation.instance_exec(&conditions)
                       else
                         relation.instance_exec(record, &conditions)
                       end
          end
        rescue RangeError
          relation = finder_class.none
        end

        return unless relation.exists?

        error_options = options.except(:case_sensitive, :scope, :conditions)
        error_options[:value] = value

        record.errors.add(attribute, :taken, **error_options)
      end

      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity

      protected

      def scope_relation(record, relation)
        Array(options[:scope]).each do |scope_item|
          scope_value = if record.adapter._reflect_on_association(scope_item)
                          record.association(scope_item).reader
                        else
                          record.send(scope_item)
                        end
          relation = relation.where(scope_item => scope_value)
        end

        relation
      end
    end

    # rubocop:enable Lint/ConstantDefinitionInBlock
  end
  # rubocop:enable Metrics/BlockLength
end
