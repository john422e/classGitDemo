/*
piReceiver.ck
for class demonstration on 11.23.21
server
*/

// sound chain
SinOsc s => Envelope sEnv => Gain sGain => dac;
SndBuf b => Envelope bEnv => Gain bGain => dac;

me.dir() + "audio/demoHarmony.wav" => string path;
path => b.read; // read in audio file
1 => b.loop; // turn looping on
0 => s.freq; // initialize


// OSC
OscIn in;
OscMsg msg;
10001 => in.port;
in.listenAll();
1 => int serverOn; // 0/1 bool

// initialize sound settings
1.0 => sGain.gain;
0.0 => float freq;
0.5 => sEnv.time;
1.0 => bGain.gain;
0.01 => bEnv.time;
0 => int soundOn;
//bEnv.keyOff();
//sEnv.keyOff();

// sensor vars
25.0 => float thresh; // distance thresh (lower values trigger sound)
10.0 => float distOffset; // set for each sensor to compensate for irregularities
float dist;
float amp;

// time/score vars
600 => int pieceLength; // in seconds
1 => int second_i;
1 => int rate; // in seconds

// FUNCTIONS ---------------------------------------------------

fun float normalize( float inVal, float x1, float x2 ) {
	/*
	for standard mapping:
	x1 = min, x2 = max
	inverted mapping:
	x2 = min, x1 = max
	*/
	// catch out of range numbers and cap
	if( x1 > x2 ) { // for inverted ranges
		if( inVal < x2 ) x2 => inVal;
		if( inVal > x1 ) x1 => inVal;
	}
	// normal mapping
	else {
		if( inVal < x1 ) x1 => inVal;
		if( inVal > x2 ) x2 => inVal;
	}
	(inVal-x1) / (x2-x1) => float outVal;
	return outVal;
}

fun void get_osc() {
	<<< "OSC SERVER ON" >>>;
	while( serverOn == 1 ) {
		
		// check for osc messages
		in => now;
		while( in.recv(msg) ) {
			// addresses
			<<< "MESSAGE IN:", msg >>>;
			
			// start piece
			if( msg.address == "/beginPiece" ) {
				<<< "BEGINNING CUED" >>>;
				Std.system("python3 oscDistanceSensor.py &"); // start sensor program
				spork ~ main();
			};
			
			// end piece
			if( msg.address == "/endPiece" ) 0 => serverOn;
			
			// ultrasonic sensor distance
			if( msg.address == "/distance" ) {
				msg.getFloat(0) => dist;
				<<< "/distance", dist >>>;
				// turn on sound if value below thresh and get tone
				if( dist < thresh && dist > 0.0 ) {
					// <<< "sound on" >>>;
					1 => soundOn;
					normalize(dist, thresh, distOffset) => amp;
					<<< "sensorAmp", amp >>>;
					amp => sEnv.target;
					spork ~ sEnv.keyOn();
				}
				else { // no sound
					0 => soundOn;
					spork ~ sEnv.keyOff();
				}
			}
			
			// set freq
			if( msg.address == "/freq" ) {
				<<< "SET FREQ" >>>;
				msg.getFloat(0) => s.freq;
			}
			
			// bufPlay
			if( msg.address == "/bufOn" ) {
				<<< "BUFFER ON" >>>;
				msg.getFloat(0) => bGain.gain;
				bEnv.keyOn();
			}
			if( msg.address == "/bufOff" ) {
				<<< "BUFFER OFF" >>>;
				bEnv.keyOff();
			}
		}
		//<<< "NO OSC" >>>;
	}
}

fun void main () {

	// STARTUP SOUND ---------------------------------------------------
	0.2 => sGain.gain;
	0.01 => sEnv.time;
	for( 0 => int i; i < 5; i++ ) {
		220 => s.freq;
		sEnv.keyOn();
		0.5::second => now;
		sEnv.keyOff();
		0.5::second => now;
	}
	1.0 => sGain.gain;
	0.5 => sEnv.time;

	// MAIN PROGRAM ---------------------------------------------------

	<<< "STARTING FORM" >>>;

	// loop for whole piece
	while( second_i < pieceLength ) {
		if( second_i % 5 == 0 ) <<< second_i / 60, ":", second_i % 60 >>>;
	
		// increment time, do this last
		1 +=> second_i;
		rate::second => now;
	}
}


// this will trigger everything when /beginPiece comes in from masterSpeakerCtl.ck
<<< "STARTING SERVER" >>>;

spork ~ get_osc(); // start sensor listener

// run forever
while( true ) 1::second => now;