require 'win32ole'


class WIN32OLE; def oms = ole_methods.map(&:name).sort; end
#ie = WIN32OLE.connect 'InternetExplorer.Application'
ie = WIN32OLE.new 'InternetExplorer.Application'
begin
  ie.visible = true
  ie.oms.display
  ie.Navigate(
    'http://localhost:8080/',
    0,
    '_self',
    nil,
    'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0'
  )
  sleep 5
  ie = WIN32OLE.connect 'InternetExplorer.Application'
  ie.Quit
ensure
  #ie.Quit
end
