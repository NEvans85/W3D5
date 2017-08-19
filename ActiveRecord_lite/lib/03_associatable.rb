require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each do |k, v|
      send("#{k}=", v)
    end
    @foreign_key ||= name.foreign_key.to_sym
    @class_name ||= name.classify
    @primary_key ||= :id

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each do |k, v|
      send("#{k}=", v)
    end
    @foreign_key ||= self_class_name.foreign_key.to_sym
    @class_name ||= name.classify
    @primary_key ||= :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
