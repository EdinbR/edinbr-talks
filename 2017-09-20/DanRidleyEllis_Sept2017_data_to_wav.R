library(tuneR)
library(seewave)

  # the sample rate is effectively controlling the speed (frequency) of data playback 
  samplef=8000 # sampling frequency in Hz
  
  # this controls the quality of sound.
  samplebit=8 # sampling bit depth (8/16/24/32/64)

  # grab some slightly appropriate data to use
  amplitude = as.numeric(LakeHuron)
  
  # we need to set the mean value to zero
  amplitude = amplitude - mean(amplitude)
  
  # make the wave object
  Sound = Wave(left = amplitude, right = amplitude, samp.rate=samplef, bit=samplebit)
  
  # this is short, so let's just loop it a few times
  
  Sound = pastew(Sound, Sound, output = "Wave")
  Sound = pastew(Sound, Sound, output = "Wave")
  Sound = pastew(Sound, Sound, output = "Wave")
  Sound = pastew(Sound, Sound, output = "Wave")
  Sound = pastew(Sound, Sound, output = "Wave")
  Sound = pastew(Sound, Sound, output = "Wave")

  #Let's have a look at the sound
  oscillo(Sound)
  
  # Play the sound  
  listen(Sound)
  
  # You probably need to close your sound player before you can run this again
  