module RPG
  class Map; end; class MapInfo; end; class Tileset; end; class EventCommand; end
  class MoveRoute; end; class MoveCommand; end; class AudioFile; end; class BGM < AudioFile; end; class BGS < AudioFile; end; class SE < AudioFile; end
  class Event; class Page; class Condition; end; class Graphic; end; end; end
  class CommonEvent; end; class System; class Words; end; class TestBattler; end; end
end
class Table
  attr_reader :xs,:ys,:zs,:data
  def self._load(s); t=allocate; d,x,y,z,n=s.unpack("l5"); t.instance_variable_set(:@xs,x); t.instance_variable_set(:@ys,y); t.instance_variable_set(:@zs,z); t.instance_variable_set(:@data,s[20,n*2].unpack("s*")); t; end
end
class Color; def self._load(s); new; end; end
class Tone; def self._load(s); new; end; end
