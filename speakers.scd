Routine.new( {
	s.waitForBoot({
	// Arpeggiate a triad:
		x = Pbind(\degree, Pseq([0, 3, 5, 7, 10, 7, 5, 3, 0, -4], 1), \dur, 0.300);
	  x.play;
	});
	
	10.wait;
	"QUITTING".postln;
	s.quit;
}).play;


