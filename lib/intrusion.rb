# Intrusion main module
module Intrusion
  # check if ip is blocked
  def ids_is_blocked?(address)
    ids_load.each do |d|
      return true if d[:ip] == address && d[:counter] > 9
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
      block ? found[:counter] = 10 : found[:counter] += 1
    else
      dt << { ip: address, counter: block ? 10 : 1 }
    end

    # update record
    update_attributes(ids: dt.to_yaml)
  end

  # reset counter and stay
  def ids_unblock!(address)
    dt = ids_load
    found = false
    dt.each { |d| found = d if d[:ip] == address }

    if found
      dt.delete(found)
      # update
      return update_attributes(ids: dt.to_yaml)
    end
    false
  end

  # convert yaml string helper
  def ids_load
    dt = ids.blank? ? [] : YAML.load(ids, Intrusion) rescue []
    dt = [] unless dt.class == Array
    dt
  end
end
