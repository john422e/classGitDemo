(
SynthDef.new( \cpsNote, {
	var freq, note, sig;
	freq = MouseX.kr(27.5, 1760);
	note = freq.cpsmidi;
	note = note.cpsname;
	[freq, note].poll;
	sig = SinOsc.ar(freq, 0, 0);
	Out.ar(0, sig);
}).add;
)


x = Synth(\cpsNote);
x.free;


(
r = Routine.new( {
	a = 55;
	while( { a < 1000 }, {
		[a, a.cpsmidi, a.cpsname].postln;
		a = a + 1;
		0.5.wait;
	});
}).play;
)