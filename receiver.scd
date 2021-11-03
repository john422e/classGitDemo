(
// basic OSC receiver
OSCdef.new(
	\printOSC,
	{
		arg msg, time, addr, port;
		["OSC MESSAGE:", msg, time, addr, port].postln;
	},
	\print,
	recvPort: 10003
);
)









// boot server (EACH PLAYER MUST CHECK THAT SERVER IS RUNNING

(
s.waitForBoot {

// synth def
SynthDef( \tone, { arg freq=220, gate=0, amp=1.0, out=0;
	var sig, env; // amount of attenuation to apply to amp (0 - 1)
	env = EnvGen.kr(Env.adsr(0.05, 0.1, 0.5, 3), gate);
	sig = SinOsc.ar(freq);
	sig = Pan2.ar(sig!2);
	sig = BHiShelf.ar(sig, 150, 1.0, -6);
	sig = BHiShelf.ar(sig, 300, 1.0, -6);
	sig = BHiShelf.ar(sig, 450, 1.0, -6);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
});

(
// for synth
OSCdef.new(
	\sinSynth,
	// function to be evaluated upon receiving qualifying OSC message
	{
		arg msg, time, addr, port; // these are the messages passed on
		var freq;
		//[msg, time, addr, port].postln; // action to be executed
		freq = msg[1].asFloat;
		["LOCAL FREQ SET", freq].postln;
		~mySynth.set(\freq, freq);

	},
	'/freq',
	recvPort: 10002,
);
)


//OSCdef.freeAll;

// start synth
~mySynth = Synth.new(\tone, [\gate, 1]);
