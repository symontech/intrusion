# Intrusion main module

module Intrusion

  DefaultConfig = Struct.new(:threshold) do
    def initialize
      self.threshold = 10
    end
  end

  def self.configure
    @config = DefaultConfig.new
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end

  def self.reset
    @config = nil
    @cache = nil
  end

  # check if ip is blocked
  def ids_is_blocked?(address)
    ids_load.each do |d|
      return true if d[:ip] == address && d[:counter] >= Intrusion.config.threshold
    end
    false
  end

  # return block counter of address
  def ids_counter(address)
    ids_load.each { |d| return d[:counter] if d[:ip] == address }
    0
  end

  # report suspicious activity
  def ids_report!(address, block = false)
    dt = ids_load
    found = nil
    dt.each { |d| found = d if d[:ip] == address }
    if found
      block ? found[:counter] = Intrusion.config.threshold : found[:counter] += 1
    else
      dt << { ip: address, counter: block ? Intrusion.config.threshold : 1 }
    end
    ids_save!(dt)
  end

  # reset counter and stay
  def ids_unblock!(address)
    dt = ids_load
    found = false
    dt.each { |d| found = d if d[:ip] == address }

    if found
      dt.delete(found)
      return ids_save!(dt)
    end
    false
  end

  # convert yaml string helper
  def ids_load
    data = ids.blank? ? [] : YAML.safe_load(ids, [Symbol])
    raise 'invalid data in ids field' unless data.is_a?(Array)
    data
  rescue RuntimeError
    []
  end
  
  # save current state to object or file
  def ids_save!(dt)
    update(ids: dt.to_yaml)
  end

end
