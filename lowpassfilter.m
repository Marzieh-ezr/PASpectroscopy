function lowpassfilter=lowpassfilter(signal, samplinginterval, WP)
Ts = samplinginterval;                                                     % Sampling Interval (s)
Fs = 1/Ts;                                                      % Sampling Frequency (Hz)
Fn = Fs/2;                                                      % Nyquist Frequency (Hz)
Wp = WP;                                                     % Passband Frequency For Lowpass Filter (Hz)
Ws = 0.99;                                                    % Stopband Frequency For Lowpass Filter (Hz)
Rp =  1;                                                        % Passband Ripple For Lowpass Filter (dB)
Rs = 1.5;                                                        % Stopband Ripple (Attenuation) For Lowpass Filter (dB)

[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                 % Calculate Filter Order
[z,p,k] = ellip(n,Rp,Rs,Wp);                                    % Calculate Filter
[sos,g] = zp2sos(z,p,k);                                        % Second-Order-Section For Stability

lowpassfilter = filtfilt(sos,g,signal);                                     % Filter Signal

end