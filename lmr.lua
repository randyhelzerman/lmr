#!/usr/local/bin/luajit
--#!/usr/local/bin/lua

dbg = require("debugger")

-- load up rocks we use
local inspect  =  require "inspect"
local lzmq     =  require "lzmq"
local optparse =  require "optparse"


-- set up option handling
function configure ()
   local optparser = optparse
[[
 Version 0.0
 Just starting out.

 Still experimental.

 Usage: lmr

 Map Reduce

 Any program which can be cast in the form:
 ( map | sort | reduce ) < intput.txt  > output.txt
 can be parallelized with map reduce.

 Your mileage may vary.

 ./lmr.lua --map map.sh --reduce reduce.sh  --hosts "server1, server2, server3" < input.txt > output.txt

 Options:

   -h, --hosts=HOSTS        list of hostsnames
   -m, --map=MAP            the map function
   -r, --reduce=RED         the reduce function
   -s, --sort-opts=SO       sort options
   -t, --test               local test mode
       --version            display version information, then exit
       --help               display this help, then exit

 See documentation at github.
 
]]
   
   _G.arg, _G.opts = optparser:parse(_G.arg)
   Config = _G.opts;
   
   -- Just run on local for now.
   --Config.test=true;
   
   -- do defaults
   if nil == Config.sort_opts then Config.sort_opts = '' end
   if nil == Config.hosts     then Config.hosts     = 'localhost' end
   
   --print(inspect(Config))
end


-- first rule of parallel and distributed programming:
-- get a serial version of the algorithm working first.
-- you are going to need it anyways to test the results of
-- your parallel algorihm, and you can work out the dorky
-- endcases which have nothing to do with parallelization.
function localExecute()
   local tmpFileName = os.tmpname();
   
   local cmd
      = 'eval \"( '
      .. Config.map
      .. ' | sort ' .. Config.sort_opts .. ' | '
      .. Config.reduce
      .. ' ) > '
      .. tmpFileName
      .. '\"'
   
   --print("cmd = [" ..cmd .. "]")
   
   local fp = io.popen(cmd, "w");
   for line in io.lines() do
      fp:write(line .. "\n")
   end
   fp:close()
   
   for line in io.lines(tmpFileName) do
      print(line)
   end
   
   os.remove(tmpFileName)
end


function spawn()
   for host in string.gmatch(Config.hosts, "%S+") do
      print(host)
   end
end


function main()
   -- parse command line options
   configure();
   
   -- if we are just doing a local test
   -- then do it here.
   if Config.test then
      localExecute()
      return
   end
   
   -- establish connections with remote hosts.
   spawn()
end


main()
