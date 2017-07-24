module ActiveRecord::Userstamp::Utilities
  # Removes the association methods from the model.
  #
  # @param [Class] model The model to remove methods from.
  # @param [Symbol] association The name of the association to remove.
  # @return [void]
  def self.remove_association(model, association)
    methods = [
      association,
      "#{association}=",
      "build_#{association}",
      "create_#{association}",
      "create_#{association}!"
    ]

    model.generated_association_methods.module_eval do
      methods.each do |method|
        remove_possible_method(method)
      end
    end
  end

  # Obtains the creator/updater/deleter columns which are present in the model.
  #
  # @param [Class] model The model to query.
  # @return [nil|Array<(bool, bool, bool)>] Nil if the model does not have a table defined.
  #   Otherwise, a tuple of booleans indicating the presence of the created, updated, and deleted
  #   columns.
  def self.available_association_columns(model)
    return nil if model.name.nil? || model.table_name.empty?
    columns = Set[*model.column_names]
    config = ActiveRecord::Userstamp.config

    [config.creator_attribute.present? && columns.include?(config.creator_attribute.to_s),
     config.updater_attribute.present? && columns.include?(config.updater_attribute.to_s),
     config.deleter_attribute.present? && columns.include?(config.deleter_attribute.to_s),
     config.company_attribute.present? && columns.include?(config.company_attribute.to_s),]
  rescue ActiveRecord::StatementInvalid => _
    nil
  end

  # Assigns the stamper to the given association reflection in the record.
  #
  # If the stamper is a record, then it is assigned to the association; if it is a number, then it
  # is assigned to the foreign key.
  #
  # @param [ActiveRecord::Base] record The record to assign.
  # @param [ActiveRecord::Reflection] association The association to assign
  def self.assign_stamper(record, association)
    stamp_value = record.class.stamper_class.stamper
    attribute =
      if stamp_value.is_a?(ActiveRecord::Base)
        association.name
      else
        association.foreign_key
      end

    if attribute == 'company_id'
      record.send("#{attribute}=", stamp_value.company_id)
    else
      record.send("#{attribute}=", stamp_value)
    end
  end
end
