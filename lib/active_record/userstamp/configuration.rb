module ActiveRecord::Userstamp::Configuration
  # !@attribute [r] default_stamper
  #   Determines the default model used to stamp other models.
  #
  #   By default, this is set to +'User'+.
  def self.default_stamper
    ActiveRecord::Base.stamper_class_name
  end

  # !@attribute [rw] default_stamper
  # @see {.default_stamper}
  def self.default_stamper=(stamper)
    ActiveRecord::Base.stamper_class_name = stamper
  end
  self.default_stamper = 'User'.freeze

  # @!attribute [r] default_stamper_class
  #   Determines the default model used to stamp other models.
  def self.default_stamper_class
    ActiveRecord::Base.stamper_class
  end

  # !@attribute [rw] creator_attribute
  #   Determines the name of the column in the database which stores the name of the creator.
  #
  #   Override the attribute by using the stampable class method within a model.
  #
  #   By default, this is set to +:creator_id+.
  mattr_accessor :creator_attribute
  self.creator_attribute = :creator_id

  # !@attribute [rw] updater_attribute
  #   Determines the name of the column in the database which stores the name of the updater.
  #
  #   Override the attribute by using the stampable class method within a model.
  #
  #   By default, this is set to +:updater_id+.
  mattr_accessor :updater_attribute
  self.updater_attribute = :updater_id

  # !@attribute [rw] deleter_attribute
  #   Determines the name of the column in the database which stores the name of the deleter.
  #
  #   Override the attribute by using the stampable class method within a model.
  #
  #   By default, this is set to +:deleter_id+.
  mattr_accessor :deleter_attribute
  self.deleter_attribute = :deleter_id

  # !@attribute [rw] company_attribute
  #   Determines the name of the column in the database which stores the name of the company.
  #
  #   Override the attribute by using the stampable class method within a model.
  #
  #   By default, this is set to +:company_id+.
  mattr_accessor :company_attribute
  self.company_attribute = :deleter_id
end
