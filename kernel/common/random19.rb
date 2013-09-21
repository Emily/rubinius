# -*- encoding: us-ascii -*-

class Rubinius::Randomizer
  def random_range(limit)
    min, max = limit.max.coerce(limit.min)
    diff = max - min
    diff += 1 if max.kind_of?(Integer)
    random(diff) + min
  end

  def random(limit)
    if undefined.equal?(limit)
      random_float
    else
      if limit.kind_of?(Range)
        if limit.min.respond_to?(:to_time)
          random_time_range(limit)
        else
          random_range(limit)
        end
      elsif limit.kind_of?(Float)
        raise ArgumentError, "invalid argument - #{limit}" if limit <= 0
        random_float * limit
      else
        limit_int = Rubinius::Type.coerce_to limit, Integer, :to_int
        raise ArgumentError, "invalid argument - #{limit}" if limit_int <= 0

        if limit.is_a?(Integer)
          random_integer(limit - 1)
        elsif limit.respond_to?(:to_f)
          random_float * limit
        else
          random_integer(limit_int - 1)
        end
      end
    end
  end

  ##
  # Returns a random value from a range made out of Time, Date or DateTime
  # instances.
  #
  # @param [Range] range
  # @return [Time|Date|DateTime]
  #
  def random_time_range(range)
    min  = range.min.to_time.to_f
    max  = range.max.to_time.to_f
    time = Time.at(random(min..max))

    if range.min.is_a?(DateTime)
      time = time.to_datetime
    elsif range.min.is_a?(Date)
      time = time.to_date
    end

    return time
  end
end

class Random
  def self.new_seed
    Thread.current.randomizer.generate_seed
  end

  def self.srand(seed=undefined)
    if undefined.equal? seed
      seed = Thread.current.randomizer.generate_seed
    end

    seed = Rubinius::Type.coerce_to seed, Integer, :to_int
    Thread.current.randomizer.swap_seed seed
  end

  def self.rand(limit=undefined)
    Thread.current.randomizer.random(limit)
  end

  def initialize(seed=undefined)
    @randomizer = Rubinius::Randomizer.new
    if !undefined.equal?(seed)
      @randomizer.swap_seed seed.to_int
    end
  end

  def rand(limit=undefined)
    @randomizer.random(limit)
  end

  def seed
    @randomizer.seed
  end

  def state
    @randomizer.seed
  end
  private :state

  def ==(other)
    return false unless other.kind_of?(Random)
    seed == other.seed
  end

  # Returns a random binary string.
  # The argument size specified the length of the result string.
  def bytes(length)
    length = Rubinius::Type.coerce_to length, Integer, :to_int
    s = ''
    i = 0
    while i < length
      s << @randomizer.random_integer(255).chr
      i += 1
    end

    s
  end
end
