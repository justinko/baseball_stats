require 'minitest/spec'
require 'minitest/autorun'
require 'factory'

require 'baseball_stats'

MiniTest::Spec.send :include, Factory

BaseballStats.db = BaseballStats::Database.new('test')
BaseballStats.db.create_tables
