module GameData
  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is known by a symbol or an ID number.
  #=============================================================================
  module ClassMethods
    def schema
      return self::SCHEMA
    end

    def register(hash)
      self::DATA[hash[:id]] = self::DATA[hash[:id_number]] = self.new(hash)
    end

    # @param other [Symbol, self, String, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String, Integer]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    # @param other [Symbol, self, String, Integer]
    # @return [self, nil]
    def try_get(other)
      return nil if other.nil?
      validate other => [Symbol, self, String, Integer]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in order of their id_number.
    def each
      sorted_keys = self::DATA.keys.sort { |a, b| self::DATA[a].id_number <=> self::DATA[b].id_number }
      sorted_keys.each { |key| yield self::DATA[key] if !key.is_a?(Integer) }
    end

    def count
      return self::DATA.length / 2
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by a symbol.
  #=============================================================================
  module ClassMethodsSymbols
    def schema
      return self::SCHEMA
    end

    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [Symbol, self, String]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [Symbol, self, String]
      other = other.id if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      return !self::DATA[other].nil?
    end

    # @param other [Symbol, self, String]
    # @return [self]
    def get(other)
      validate other => [Symbol, self, String]
      return other if other.is_a?(self)
      other = other.to_sym if other.is_a?(String)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

# @param other [Symbol, self, String, Array]
# @return [self, nil]
def try_get(other)
  return nil if other.nil?
  # If it's an array, validate each element in the array
  if other.is_a?(Array)
    other.each { |o| validate o => [Symbol, self, String] }
    return other.map { |o| o.is_a?(self) ? o : (self::DATA.has_key?(o.to_sym) ? self::DATA[o.to_sym] : nil) }
  end
  # Original validation for single element
  validate other => [Symbol, self, String]
  return other if other.is_a?(self)
  other = other.to_sym if other.is_a?(String)
  return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in the order they were defined.
    def each
      self::DATA.each_value { |value| yield value }
    end

    # Yields all data in alphabetical order.
    def each_alphabetically
      keys = self::DATA.keys.sort { |a, b| self::DATA[a].real_name <=> self::DATA[b].real_name }
      keys.each { |key| yield self::DATA[key] }
    end

    def count
      return self::DATA.length
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common class methods (called
  # by GameData::Thing.method) that provide access to data held within.
  # Assumes the data class's data is stored in a class constant hash called DATA.
  # For data that is only known by an ID number.
  #=============================================================================
  module ClassMethodsIDNumbers
    def schema
      return self::SCHEMA
    end

    def register(hash)
      self::DATA[hash[:id]] = self.new(hash)
    end

    # @param other [self, Integer]
    # @return [Boolean] whether the given other is defined as a self
    def exists?(other)
      return false if other.nil?
      validate other => [self, Integer]
      other = other.id if other.is_a?(self)
      return !self::DATA[other].nil?
    end

    # @param other [self, Integer]
    # @return [self]
    def get(other)
      validate other => [self, Integer]
      return other if other.is_a?(self)
      raise "Unknown ID #{other}." unless self::DATA.has_key?(other)
      return self::DATA[other]
    end

    def try_get(other)
      return nil if other.nil?
      validate other => [self, Integer]
      return other if other.is_a?(self)
      return (self::DATA.has_key?(other)) ? self::DATA[other] : nil
    end

    # Returns the array of keys for the data.
    # @return [Array]
    def keys
      return self::DATA.keys
    end

    # Yields all data in numberical order.
    def each
      keys = self::DATA.keys.sort
      keys.each { |key| yield self::DATA[key] }
    end

    def count
      return self::DATA.length
    end

    def load
      const_set(:DATA, load_data("Data/#{self::DATA_FILENAME}"))
    end

    def save
      save_data(self::DATA, "Data/#{self::DATA_FILENAME}")
    end
  end

  #=============================================================================
  # A mixin module for data classes which provides common instance methods
  # (called by thing.method) that analyse the data of a particular thing which
  # the instance represents.
  #=============================================================================
  module InstanceMethods
    # @param other [Symbol, self.class, String, Integer]
    # @return [Boolean] whether other represents the same thing as this thing
    def ==(other)
      return false if other.nil?
      case other
      when Symbol
        return @id == other
      when self.class
        return @id == other.id
      when String
        return @id == other.to_sym
      when Integer
        return @id_number == other
      end
      return false
    end

    def get_property_for_PBS(key)
      ret = nil
      if self.class::SCHEMA.include?(key) && self.respond_to?(self.class::SCHEMA[key][0])
        ret = self.send(self.class::SCHEMA[key][0])
        ret = nil if ret == false || (ret.is_a?(Array) && ret.length == 0)
      end
      return ret
    end
  end

  #=============================================================================
  # A bulk loader method for all data stored in .dat files in the Data folder.
  #=============================================================================
  def self.load_all
    self.constants.each do |c|
      next if !self.const_get(c).is_a?(Class)
      self.const_get(c).load if self.const_get(c).const_defined?(:DATA_FILENAME)
    end
  end

  def self.get_all_data_filenames
    ret = []
    self.constants.each do |c|
      next if !self.const_get(c).is_a?(Class)
      next if !self.const_get(c).const_defined?(:DATA_FILENAME)
      if self.const_get(c).const_defined?(:OPTIONAL) && self.const_get(c)::OPTIONAL
        ret.push([self.const_get(c)::DATA_FILENAME, false])
      else
        ret.push([self.const_get(c)::DATA_FILENAME, true])
      end
    end
    return ret
  end

  def self.get_all_pbs_base_filenames
    ret = {}
    self.constants.each do |c|
      next if !self.const_get(c).is_a?(Class)
      ret[c] = self.const_get(c)::PBS_BASE_FILENAME if self.const_get(c).const_defined?(:PBS_BASE_FILENAME)
      next if !ret[c].is_a?(Array)
      ret[c].length.times do |i|
        next if i == 0
        ret[(c.to_s + i.to_s).to_sym] = ret[c][i]   # :Species1 => "pokemon_forms"
      end
      ret[c] = ret[c][0]   # :Species => "pokemon"
    end
    return ret
  end
end
