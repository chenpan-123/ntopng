--
-- (C) 2013-18 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
local json = require "dkjson"

local function send_error(error_type)
   local msg = "Generic error"
   if error_type == "not_found" then
      msg = "Host not found"
   elseif error_type == "not_granted" then
      msg = "Request not granted. Another request may be in progress. Retry later."
   end

   sendHTTPContentTypeHeader('application/json')
   print(json.encode({error = msg}))
end

local host = _GET["host"]
if isEmptyString(host) then
   send_error("not_found")
else
   local granted = true -- interface.requestLiveTraffic(host)

   if not granted then
      send_error("not_granted")
   else
      sendHTTPContentTypeHeader('application/vnd.tcpdump.pcap', 'attachment; filename="'..host..'_live.pcap"')

      interface.liveCapture(host)
   end
end
