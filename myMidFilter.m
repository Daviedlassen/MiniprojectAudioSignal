function Hd = MidFilter (fs)

% All frequency values are in Hz.
Fs = fs;  % Sampling Frequency

Fstop1 = 160;         % First Stopband Frequency
Fpass1 = 200;         % First Passband Frequency
Fpass2 = 1280;        % Second Passband Frequency
Fstop2 = 1380;        % Second Stopband Frequency
Astop1 = 80;          % First Stopband Attenuation (dB)
Apass  = 1;           % Passband Ripple (dB)
Astop2 = 80;          % Second Stopband Attenuation (dB)
match  = 'stopband';  % Band to match exactly

h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match); %Using the Butter Method

% [EOF]
