module BaseballStats
  module Stats
    class Stat
      module Formatter
        def player_name
          "#{self[:name]} (#{self[:player_id]})".ljust(37)
        end
      end

      def self.default(option_name, value)
        define_method(option_name) { value }
      end

      def initialize(options = {})
        options.each {|name, value| self.class.class_eval { define_method(name) { value } } }
      end

      def data
        BaseballStats.db[sql].all.inject([]) {|rows, stat| yield stat.extend(Formatter), rows }
      end
    end
  end
end
