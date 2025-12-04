[soundwave,Fs] = audioread("B EE 461\W15OO70.WAV"); 
sound(soundwave,Fs);
FFTofSound = fft(soundwave);
magOfFFT = abs(FFTofSound);


plot(20*log10(magOfFFT));