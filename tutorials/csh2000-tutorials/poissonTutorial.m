%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% poissonTutorial
%
% This tutorial introduces the Poisson model of stochastic
% neuronal firing.  It starts off simulating the action
% potential discharge of a hypothetical model neuron
% by generating realizations of an (approximately) poisson process.
% This shows how the model can account qualtitatively for the
% seemingly random timing of spikes recorded from neurons.
% Then, it shows how to generate samples from the poisson
% distribution using the "inverse cumulative density"
% function.
%
% This tutorial was created by David Heeger and was modified
% by Greg Horwitz (for CSH '00).
%
% Dependencies: matlab statstics toolbox               
%
% GDLH 6/6/00
% Upgraded accordingly in 2014 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize
%
clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating Samples of a Poisson Process.

% A Poisson process is a member of the class of stochastic point
% processes.  It is formally defined by the following set of
% equations (here, N(t) is the number of events that have occurred
% by time 't').
%
% 1) N(0)=0
%    Translation: No spikes at the begining of time.
% 2) The process is stationary and has independent increments
%    Translation: the spike rate doesn't change over time and
% the number of spikes occurring in any interval is independent
% of the number of spikes occurring in any other (non-overlapping)
% interval.
% 3) Prob{N(h)=1} = lamba*h + o(h)
%    Translation: The probability of one event in a 'brief' window of
% time is a constant, 'lambda' multiplied by the duration of the window.
% 4) Prob{N(h)>1} = o(h)
%    Translation: The probability of more than one spike in a 'short'
% window of time is vanishingly small, or '0' in the limit.
%
% The Poisson model occurs very naturally in situations in which a
% large number of independent components all have the capacity
% for generating an event, but none of them are very likely to do so
% at a given time.
%
% The arrival of telephone calls to a given telephone operator can be
% well modeled by a Poisson process, for instance.
%
% Early neurophysiologists were struck by the irregularity spike trains
% recorded from neurons in vivo and thus the Poisson model of neural
% firing was born.  Even these early neurophysiologists were aware
% that *real* neurons are strictly stationary and don't have strictly
% independent increments.  Still, these violations aside, it's remarkable
% how far the Poisson model can go towards explaining firing variability
% of cortical neurons.
%
% One of the easiest ways to generate a Poisson spike train is to rely
% on the approximation:
%
%    Prob{1 spike during (t,t+deltaT)} = r(t)*deltaT
%
% where r(t) is the instantaneous firing rate and deltaT is again
% the time step.  Notice how similar this looks to equation 3) in the
% definition of the Poisson process above.  This approximation is only
% valid when deltaT is very short so that there is essentially no chance
% that the neuron would fire more than one spike in any given time interval.

% Let's begin by choosing a time step and by choosing an average
% firing rate.

deltaT=1e-3; 			% 1e-3 secs = 1 msec
rate=50;				% 50 spikes/sec
duration=5;				% 5 sec simulation
times=[0:deltaT:duration];

% Now that everything is set up, we're going to choose a bunch of random
% numbers, one for each time step, unformly distributed between 0 and 1.
% The idea here is that at each moment in time (where 'moment' means
% an epoch of time that is 'deltaT' in duration) we are going to check
% whether our model neuron fires a spike or not.

xr=rand(size(times));

% Finally, insert a spike whenever the probability of firing
% (rate*deltaT) is greater than the corresponding random number:

neuralResponse = (rate*deltaT) > xr;
figure;
axes('position',[.1,.4,.8, .2]);
bar(times,neuralResponse,1.0);
axis tight;
set(gca,'TickDir','out');
xlabel('Time (sec)')
ylabel('Neural response')

% See, it looks kind of like a spike train.  Some of the spikes are
% probably so close together they look like a single spike.  You
% stretch the figure window to make it look better.

% A remarkable property of the Poisson process is that the interspike
% intervals are distributed exponentially.  This is a neat result and
% worth thinking about.  It's also worth mentioning that the converse
% is *not* true: just because interspike intervals are distributed
% exponentially does *not* mean that the spikes are well described
% by a Poisson process.  For one thing, the interspike intervals could
% have some sort of weird dependence on each one other.  The hallmark of
% the Poisson process is that every instant of time is independent of
% every other instant, precluding this kind of dependence.

% In the next section we'll show that spike train that we just simulated
% has roughly exponentially distributed interspike intervals, just as we'd
% expect.

% First, get the spike times (in msec)

spikeTimes=find(neuralResponse)*deltaT*1000;

% Then, the spike intervals (difference between adjacent spike
% times).

spikeIntervals=spikeTimes(2:length(spikeTimes))-...
    spikeTimes(1:length(spikeTimes)-1);

% Compute a histogram of the spike intervals, normalized to unit
% volume.

clf;
binsize=1;
x=[1:binsize:100];
intervalDist=hist(spikeIntervals(spikeIntervals<100),x);
intervalDist=intervalDist/sum(intervalDist)/binsize;
bar(x,intervalDist);

% As promised, the historgram looks like an exponential probability
% distribution.  For verificiation, we'll superimpose the exponential
% probability density function.

y=exppdf(x,1/(rate*deltaT));
axis([min(x) max(x) 0 max(y)]);
xlabel('Interspike interval');
ylabel('Probability');
hold on;
plot(x,y);
hold off;

% If a neuron acts like a Poisson process, the number of spikes
% fired in a window of length 't' has a Poisson distribution with
% parameter lambda*t, where lambda is the firing rate per unit time.
% This is a point of confusion for some people: the distribution of
% interspike intervals is *exponential* and the distribution of
% spike counts is *Poisson*.  In the next section we'll examine the
% Poisson distribution directly.

% Here are some things for you to do:
%
% - Try simulating a longer stimulus duration (e.g., 10 secs
%   instead of 1) and recomputed the interspike interval
%   histogram.
%
% - Try running this simulation a lot of times, keeping track of
%   the spike count each time.  Compute the mean spike count and
%   the variance in the spike count across these repeated trials.
%   Plot a histogram of the spike counts across these repeated
%   trials.
%
% - Try to simulate a nonhomogeneous Poisson process.  For
%   example, choose the instantaneous rate function to be a 2 Hz
%   sinusoid that modulates between 0 and 50 spikes/sec.
%
% - Try running a lot of repeated simulations of the
%   nonhomogeneous Poisson process, computing the mean spike count,
%   and the variance in the spike count, and plot a histogram of the
%   spike counts across these repeated trials.
%
% - If you want more information about Poisson processes you might
%   want to check out GamSpikeTrainTutorial.m.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating Samples of a Random Variable

% We want to draw random numbers from a particular probability
% distribution.  For example, imagine that we are simulating
% repeated trials of an neurophysiology experiment in which we
% want to generate random numbers corresponding to how the spike
% count varies from one trial of the experiment to the next.  The
% 'rand' function returns random numbers that are uniformly
% distributed over [0,1].  And the 'randn' function returns
% random numbers that are normally (Gaussian) distributed.  But
% there is no randp function that returns Poisson distributed
% random numbers.

% The trick is to use the 'rand' function in conjunction with the
% inverse of the desired cumulative distribution function,
% 'poissinv' in this case.

% Let's begin by plotting the Poisson probability density
% function for an average spike count of 3.
meanSpikeCount=3;
x=[0:0.01:10];
pdf=poisspdf(x,meanSpikeCount);
plot(x,pdf);
xlabel('Spike count');
ylabel('Probability');

% Notice that the Poisson density takes on nonzero probabilities
% only at integer spike counts.  This makes perfect sense since
% we are trying to model spike counts.  There's no such thing as
% half a spike.  It's kind of like being half pregnant.

% Next, let's plot the cumulative Poisson distribution.
cdf=poisscdf(x,meanSpikeCount);
plot(x,cdf)
xlabel('Spike count')
ylabel('Cumulative probability')

% The staircase shape is again due to the fact that you can't
% have a fractional spike count.

% Now we can use the inverse of this cumulative distribution
% function to generate Poisson distributed random draws as
% follows: (1) pick a (uniformaly distributed) random number
% between 0 and 1, and (2) run that number through the inverse of
% the desired cumulative distribution.  In our example, starting
% with the random number 0.1 would yield a spike count of 1 (look
% at the graph to see why).  Likewise, starting with the random
% number 0.8 would yield a spike count of 4.

poissinv(0.1,meanSpikeCount)
poissinv(0.8,meanSpikeCount)

% Start by generating a bunch (1000) of uniformly distributed
% random numbers, and then run each of them through the inverse
% of the cumulative distribution function.  For each of the 1000
% trials we get a simulated spike count.

xr=rand(1,1000);
spikeCounts = poissinv(xr,meanSpikeCount);

% Let's make sure that we get the mean spike count and the
% variance in the spike count that we expect to get (we set
% the mean spike count to '3', and a property of the Poisson
% distribution is that the mean is always equal to the variance).

mean(spikeCounts)
var(spikeCounts)
fano=var(spikeCounts)/mean(spikeCounts)

% Plot a spike count histogram

x=[0:10];
hist(spikeCounts,x)
axis([min(x) max(x) 0 250])
xlabel('Spike count')
ylabel('Probability')

% Plot a normalized histogram for comparison with the Poisson
% pdf:

spikeCountHist=hist(spikeCounts,x)/1000;
bar(x,spikeCountHist)
axis([min(x) max(x) 0 0.25])
xlabel('Spike count')
ylabel('Probability')
hold on;
y=poisspdf(x,meanSpikeCount);
plot(x,y);
hold off;

% Here are some things for you to do:
%
% - Try changing the meanSpikeCount.  How big does the mean spike
%   count have to be for the distribution to look normal
%   (Gaussian).
%
% - Try increasing the number of trials in the simulation.  You
%   should be able to get the Fano factor arbitrarily close to 1.
%
% - Try generating random samples from an exponential
%   distribution as if you were trying to choose a bunch of
%   interspike intervals.
