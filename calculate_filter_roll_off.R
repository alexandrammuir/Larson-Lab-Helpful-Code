# The following script will calculate roll-off for your filters. 
# Alexandra Muir: November, 2020

############################## CHANGE THESE VALUES ################################
# To find these values, you will go to NetStation and find your script with the filters. You will double click each filter, 
# and then click on "Options". You will then see the passband gain, stopband gain, rolloff. The pass band and the stop band will most likely be negative (ENTER THEM AS NEGATIVE NUMBERS!) and will be found underneath the % box. The rolloff will be the actual number in the box. The freq variable is the frequency of the filter, which can be found in the main box (either highpass or lowpass).
# NOTE: I don't know if these calculations work for notch filters.

##### HIGH PASS ####
passgain <- -0.01 # in dB
stopgain <- -40 # in dB
rolloff <- 2 # in Hz
high_freq <- .10 # in Hz

##### LOW PASS ####
passgain <- -0.01 # in dB
stopgain <- -40 # in dB
rolloff <- 2 # in Hz
low_freq <- 30 # in Hz

############################## DO NOT TOUCH #############################################
db_octave_high <- (passgain - stopgain -3) / log2(high_freq + (rolloff/high_freq))
db_octave_low <- (passgain - stopgain -3) / log2(low_freq + (rolloff/low_freq))

high_db <- paste0("The roll-off for our ", high_freq, " Hz high pass filter (passgain: ", passgain, " dB, stopgain: ", stopgain, " dB, roll-off: ", rolloff, " Hz) is ", round(db_octave_high,2), " db/octave.")

low_db <- paste0("The roll-off for our ", low_freq, " Hz high pass filter (passgain: ", passgain, " dB, stopgain: ", stopgain, " dB, roll-off: ", rolloff, " Hz) is ", round(db_octave_low,2), " db/octave.")

low_high <- paste0("Data were high-pass filtered at ", high_freq, " Hz (roll-off: ", round(db_octave_high,2), " dB/octave), and low-pass filtered at ", low_freq, " Hz (roll-off: ", round(db_octave_low,2), " dB/octave).")

high_db
low_db
low_high