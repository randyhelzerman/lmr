#!/usr/local/bin/luajit
--#!/usr/local/bin/lua

-- load up rocks we use
local std      =  require "std"
local inspect  =  require "inspect"
local lzmq     =  require "lzmq"


-- set up option handling
function configure ()
   local optparser = std.optparse [[
 Version 0.0
 Just starting out.

 Still experimental.

 Usage: lmr

 Map Reduce

 Any program which can be cast in the form:
 cat intput.txt | map | sort | reduce > output.txt
 can be parallelized with map reduce.

 Your mileage may vary.

 ./lmr.lua -map map.sh -reduce reduce.sh  -hosts "server1, server2, server3" < input.txt > output.txt

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


function localExecute()
   -- dump stdin to the comand
   local infileName = os:tmpname();
   ifh = io.open(infileName,"w");
   while true do
      line = io.stdin:read()
      if nil == line then break end
      ifh:write(line.."\n")
   end
   ifh:close();
   
   -- open up pipe to faked command
   local cmdName
      = Config.map .. " < " .. infileName
      .. " | sort " .. Config.sort_opts .. " | "
      .. Config.reduce;
   local cfh = io.popen(cmdName, 'r');
   
   -- file name is very cool here. 
   while true do
      line = cfh:read();
      if nil == line then break end
      print(line);
   end
   cfh:close()
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
