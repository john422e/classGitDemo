(

// OSC INITIALIZATION -----------------------------------------
// for LANs, hostname or IP
// for sending over internet, public facing IP address is needed (ipchicken.com)
~hostname = "eagle2018.local"; // "127.0.0.1"
~ip = "68.175.138.88";
~port = 10002;
~host = NetAddr.new(~hostname, ~port);
~host2 = NetAddr.new(~ip, ~port);
)

// send message to be printed
~host.sendMsg('/print', "HELLO WORLD!");
~host2.sendMsg('/print', "HELLO WORLD!");
// send argument to update a synth
~host.sendMsg('/freq', rrand(100.0, 1000));
