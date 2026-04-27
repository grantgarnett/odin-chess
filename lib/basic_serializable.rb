require "json"

# This provides default serialization and
# deserializations methods for classes with
# only basic data types as instance variables
module BasicSerializable
  def serialize
    obj = {}

    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    JSON.dump obj
  end

  def unserialize(string)
    obj = JSON.parse(string)

    obj.each_key do |key|
      instance_variable_set(key, obj[key])
    end
  end
end
