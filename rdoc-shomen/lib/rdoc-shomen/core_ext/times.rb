# Extend Numeric with time constants
class Numeric # :nodoc:

  # Time constants
  #
  # TODO: Use RichUnits instead (?)
  #
  module Times # :nodoc:

    MINUTES =  60
    HOURS   =  60 * MINUTES
    DAYS    =  24 * HOURS
    WEEKS   =   7 * DAYS
    MONTHS  =  30 * DAYS
    YEARS   = 365.25 * DAYS

    # Number of seconds (returns receiver unmodified)
    def seconds
      return self
    end
    alias_method :second, :seconds

    # Returns number of seconds in <receiver> minutes
    def minutes
      MINUTES
    end
    alias_method :minute, :minutes

    # Returns the number of seconds in <receiver> hours
    def hours
      HOURS
    end
    alias_method :hour, :hours

    # Returns the number of seconds in <receiver> days
    def days
      DAYS
    end
    alias_method :day, :days

    # Return the number of seconds in <receiver> weeks
    def weeks
      WEEKS
    end
    alias_method :week, :weeks

    # Returns the number of seconds in <receiver> fortnights
    def fortnights
      return self * 2.weeks
    end
    alias_method :fortnight, :fortnights

    # Returns the number of seconds in <receiver> months (approximate)
    def months
      MONTHS
    end
    alias_method :month, :months

    # Returns the number of seconds in <receiver> years (approximate)
    def years
      YEARS #return (self * 365.25.days).to_i
    end
    alias_method :year, :years

    # Returns the Time <receiver> number of seconds before the
    # specified +time+. E.g., 2.hours.before( header.expiration )
    def before( time )
      return time - self
    end

    # Returns the Time <receiver> number of seconds ago. (e.g.,
    # expiration > 2.hours.ago )
    def ago
      return self.before( ::Time.now )
    end

    # Returns the Time <receiver> number of seconds after the given +time+.
    # E.g., 10.minutes.after( header.expiration )
    def after( time )
      return time + self
    end

    # Reads best without arguments:  10.minutes.from_now
    def from_now
      return self.after( ::Time.now )
    end

    # Return a string describing the amount of time in the given number of
    # seconds in terms a human can understand easily.
    def time_delta_string
      seconds = self
      return 'less than a minute' if seconds < MINUTES
      return (seconds / MINUTES).to_s + ' minute' + (seconds/60 == 1 ? '' : 's') if seconds < (50 * MINUTES)
      return 'about one hour' if seconds < (90 * MINUTES)
      return (seconds / HOURS).to_s + ' hours' if seconds < (18 * HOURS)
      return 'one day' if seconds < DAYS
      return 'about one day' if seconds < (2 * DAYS)
      return (seconds / DAYS).to_s + ' days' if seconds < WEEKS
      return 'about one week' if seconds < (2 * WEEKS)
      return (seconds / WEEKS).to_s + ' weeks' if seconds < (3 * MONTHS)
      return (seconds / MONTHS).to_s + ' months' if seconds < YEARS
      return (seconds / YEARS).to_s + ' years'
    end

  end # module TimeConstantMethods

  include Times
end


