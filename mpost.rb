require 'win32ole'

class WIN32OLE; def oms = ole_methods.map{|m|m.name}.sort; end
Edge = WIN32OLE.connect 'Edge.Application'
