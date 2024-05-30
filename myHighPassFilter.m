function Hd = HighPassFilter (fs)

% All frequency values are in Hz.
Fs = fs;  % Sampling Frequency

Fstop = 1180;        % Stopband Frequency
Fpass = 1280;        % Passband Frequency
Astop = 80;          % Stopband Attenuation (dB)
Apass = 1;           % Passband Ripple (dB)
match = 'stopband';  % Band to match exactly

h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
Hd = design(h, 'butter', 'MatchExactly', match); %Using the butter method

% [EOF]
