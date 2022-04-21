%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integrate and Fire Model

% This tutorial will show you how to simulate a simple integrate
% and fire model of a neuron and demonstrate that the spiking
% responses of such a model neuron behavior in a linear fashion
% with respect to injected current.

% First we define some parameters for the simulation.
deltaT=.1;   				% 1 msec time steps
gleak = 0.01; 				% leak conductance (uS)
Vleak = -80;				% leak/resting potential (mV)
Vreset = -65;				% Voltage to reset to after a spike
C = 1; 					    % capacitance (nF)
theta = -55; 				% spike threshold (mV)
Vintrinsic = 0;				% reversal potential for intrinsic conductance
gintrinsic = .02;			% intrinsic conductance

% colors for plots
colors = ['k' 'r' 'g' 'b' 'm' 'c' 'y'];

% Define the range of times for the simulation.
times=[0:deltaT:1000]; 			% 1000 msec simulation

% Make a sinewave for the input
freq = 2;
sinewave = sin(2*pi*freq*times/1000);

% Initialize membrane potential and clear all the spikes.
V=Vleak*ones(size(times));
spikes=zeros(size(times));

% We will use a sinewave as the stimulation current
stim = .5*sinewave;

% The following loop will simulate the neuron for
% one second with the stimulation current.
for i=1:(length(times)-1)

  % This following is the main difference equation which defines how
  % the membrane potential changes with time. To see how it
  % is derived we will start with the differential equation
  % it is derived from:
  %
  %      dV
  %    C -- = I
  %      dt
  %
  % This is the defining equation of a capacitor and represents
  % the membrane capcitance. V is the membrane voltage and I is
  % the current across the membrane. The current for our integrate
  % and fire model is composed of three parts:
  %
  %    I = Istim - Ileak - Iintrinsic
  %
  % Istim is the stimulation current which is what we as
  % experimenters add to the system, i.e. it is the input.
  %
  % Ileak is a leak current which has a low reversal potential
  % of -80 mv. It is a passive current which acts to bring
  % the membrane potential down below threshold. In a real neuron
  % this would be the potassium current. Using Ohm's law (V=IR)
  % we can relate it to the membrane potential as follows:
  %
  %    Ileak = gleak * (V - Vleak)
  % 
  % Here V is the membrane potential and Vleak is the reversal
  % potential (i.e. -80mv) of the leak current. gleak is the
  % conductance of the leak current. Recall that conductance
  % is one over resistance.
  %
  % Iintrinsic is a passive current which has a higher reversal
  % potential of 0 mv. In a real neuron sodium currents behave
  % in a similar way to the intrinsic current although they
  % tend to have higher reversal potentials near 50 mv. Similar
  % to the leak current it can be defined in terms of membrane
  % voltage as:
  %
  %   Iintrinsic = gintrinsic * (V - Vintrinsic)
  %
  % Note that none of these conductances have voltage dependencies; they
  % are not active currents. The voltage dependence is what
  % allows a real neuron to spike, but since we are going to
  % simply force the neuron to output a spike whenever we
  % cross a fixed threshold, we ignore all the voltage dependencies
  % of the currents which make the neuron fire.
  % 
  % Putting these things together, we now have the equation:
  %
  %      dV
  %    C -- = Istim - gleak * (V - Vleak) - gintrinsic * (V - Vintrinsic)
  %      dt
  % 
  % The only thing left to do is convert this to a difference 
  % equation which we can simulate. To do this we use the definition
  % of a derivative:
  %
  %   dV              V(t+dt) - V(t)
  %   -- = lim dt->0  --------------
  %   dt                     dt
  %
  % for our discrete difference equation we set dt to something
  % small, i.e. deltaT and make time step in discrete steps of
  % deltaT. So now instead of time t+dt and t we have time step
  % i+1 and i. So our derivative looks like:
  %
  %  V(i+1) - (Vi)
  %  -------------
  %     deltaT
  %
  % Substituting into our membrane equation above and rearranging
  % terms gives the equation below:
  V(i+1) = V(i) + (deltaT/C) * (stim(i) - gleak*(V(i)-Vleak) - gintrinsic*(V(i)-Vintrinsic));

  % Here we check to see if the voltage has exceeded threshold
  % which we have set to -55 mv. If it does, then we record
  % a spike and reset the membrane potential to -65 mv.
  if V(i+1) > theta
    spikes(i+1) = 1;
    V(i+1) = Vreset;
  end

  % update the current time to the next time step
  t=(i+1)*deltaT;
end

% Now we can see how the model behaved in response to
% our sinusoidal current input. What you should see is
% that with a sinusoidal input current the spiking of the
% cell is also sinusoidal. Note that this model neuron has
% a high resting firing rate near 100 spikes/s upon which
% to exhibit modulations. The firing rate which is displayed
% in the bottom panel of the plot is calculated as one over
% the time between spikes. 
plotmodel(times,stim,spikes,'r',V);

% Now we will demonstrate that this model neuron behaves in
% a linear fashion with respect to current injection. We will
% test linearity by testing two properties of a linear system.
% The first is that if you scale the input linearly, the output
% of the system will also scale linearly. That means that as
% we increase the amplitude of the sinusoidal current input,
% then the output sinusoid should be scaled accordingly. 
% We will test this by testing a sinusoidal input with the
% following amplitudes.
amplitudes = [.1 .2 .3 .4 .5];
spiketimes = [];
for j = 1:length(amplitudes)	
   % Initialize the model
   V=Vleak*ones(size(times));
   spikes=zeros(size(times));

   % set the stim current to the correct amplitude.
   stim = amplitudes(j)*sinewave;

   % This is the same loop from above which simulates the neuron.
   for i=1:(length(times)-1)
 	 V(i+1) = V(i) + (deltaT/C) * (stim(i) - gleak*(V(i)-Vleak) - gintrinsic*(V(i)-Vintrinsic));
 	 if V(i+1) > theta
 	   spikes(i+1) = 1;
 	   V(i+1) = Vreset;
  	 end
     t=(i+1)*deltaT;
   end
 % for each amplitude we plot the results and keep the
 % spike times.
 plotmodel(times,stim,spikes,colors(j));
 spiketimes = [spiketimes ; spikes];
end
% What you should see in the output is different color traces
% for each of the different inputs and the resulting firing
% rates in the lower window. You should be able to see that
% scaling the input scales the output as expected for a linear
% system. To confirm that this scaling is in fact linear we
% can calculate the amplitude of each resulting sinusoidal
% firing rate and plot that with respect to the amplitude
% of the input amplitude. This should form a straight line.
% The following function fits the firing rate with a sinusoid
% and returns the amplitude and offset of that sinusoid.
[amplitude offset] = fitSinusoid(times, spiketimes, freq);
figure;plot(amplitudes,amplitude(1,:),'k.','MarkerSize',12);
xlabel('Input amplitude');ylabel('Output firing rate amplitude');

% The second property of a linear system we can test is the
% following: If the input to a linear system is a sinusoid
% then the output must be a sinusoid of the same frequency
% with possibly different amplitude and phase from the input.
% We will test this be examining the response to the following
% frequencies.
freqs = [.5 1 2 4 8];
spiketimes = [];
figure;
for j = 1:length(freqs)
	
   % Initialize the model
   V=Vleak*ones(size(times));
   spikes=zeros(size(times));
   
   % calculate the required input sinusoid.
   sinewave = sin(2*pi*freqs(j)*times/1000);
   stim = .2*sinewave;
   
   % again the simulation loop from above.
   for i=1:(length(times)-1)
 	 V(i+1) = V(i) + (deltaT/C) * (stim(i) - gleak*(V(i)-Vleak) - gintrinsic*(V(i)-Vintrinsic));
 	 if V(i+1) > theta
 	   spikes(i+1) = 1;
 	   V(i+1) = Vreset;
     end
 	 t=(i+1)*deltaT;
  end

 % for each amplitude we plot the results and keep the
 % spike times.
 plotmodel(times,stim,spikes,colors(j));
 spiketimes = [spiketimes ; spikes];
end

% The resulting graph for this simulation is a bit busy, but
% you should be able to see that input at different frequencies
% produces output at the same frequencies. If we plot the
% amplitude of the sinusoidal fit to the data we see that
% at each frequency the amplitude is the same, as expected.
[amplitude offset] = fitSinusoid(times, spiketimes, freqs);
figure
plot(freqs,amplitude(1,:),'k.','MarkerSize',12);
set(gca,'YLim',[0 25]);
xlabel('Input frequency'); ylabel('Output amplitude');

