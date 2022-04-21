% choiceProbabilityTutorial.m
%
% This tutorial deals with the relationship between single neuron activity
% and the behavioral choices that we (or monkeys) make in psychophysics.
% It comes at the tail of the signal detection tutorial and deals with the 
% same topics: motion direction discrimination and MT neural activity.
% This is the payoff from SDT because it gives us something to measure in
% neurons that will ultimately constrain theories of neural coding.
%
% It stems from taking seriously the idea that choices in psychophysics arise
% from the responses of neurons that represent the likelihood of one alternative
% (e.g., leftward motion) versus another (e.g., rightward motion)
%
% M.N. Shadlen, CSH June, 1998

% To model neurons, we need to set the spontaneous activity, the response
% to random noise motion (0% coherence) and the amount of increased or 
% decreased response when motion is in the PREF or NULL direction of the 
% neuron.  This turns out to be well approximated by a linear function
% <resp> = SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*COH 
%
SpontAct = 8
SpikesPerSecAtCoh0 = 20
SpikesPerSecPerPCoh = 30 
SpikesPerSecPerNCoh = -10

% The response on any one trial is variable.  For cortical neurons
% this variability is well accounted for by a proportional relationship 
% between expected spike COUNTS and the variance.  This describes the 
% variability from trial to trial that you would measure if you showed the same
% stimulus over and over again.  See the GamSpikeTrainTutorial.
%
% Var[count] = FanoFactor * <count>

FanoFactor = 1.5
% Since we are dealing with spike counts, we must state how long we have
% to count spikes
Duration = 1		% sec

cohvect = [0 .01 .02 .04 .08 .16 .32 .64]'

ExpectedCountPREF = SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*cohvect
ExpectedCountNULL = SpikesPerSecAtCoh0 + SpikesPerSecPerNCoh*cohvect

% From these values we get the response of a neuron to motion in its
% preferred direction at a number of motion strengths, and the response to 
% motion in its anti-preferred (NULL) direction. We can also compute the 
% standard deviation of the spike counts.
figure(1)
hold off
errorbar(cohvect,ExpectedCountPREF,sqrt(FanoFactor*ExpectedCountPREF))
hold on
errorbar(cohvect,ExpectedCountNULL,sqrt(FanoFactor*ExpectedCountNULL),'r')
hold off
set(gca,'TickDir','out','FontSize',14,'Box','off');
xlabel('Motion Strength')
ylabel('Spike Counts and StdDev')

% This should be old hat.  The signal detection tutorial went through this. 
% It is the relative separation of these response distributions, relative 
% in terms of the standard dev, that leads to the discriminability of 
% the motion on the basis of this neuron. 

% Let's be a little more concrete.  Suppose we show the monkey upward
% motion and suppose the subject (monkey) is really
% making decisions on a trial by trial basis by comparing the response of 
% a neuron preferring up to the response of a neuron peferring down.
% I won't go through this because we covered this in the sdtTutorial.
%
% How would the response of the up neuron relate to the monkey's choices?
% To answer this we do not want to look at lots of motion strengths, because
% it's obvious and trivial that the larger responses from the UP neuron result
% in more upward judgments.  That's just because the stronger UP motion leads
% to stronger response from the UP neuron. No big deal.
% But...if we're serious about our model of how the judgment follows the 
% neural response, we make another more subtle prediction.  Even for the same
% stimulus, the response ought to predict the monkey's choices.

% Let's model this.  We'll model the responses by drawing from a normal distribution
% That's not a bad approximation so long as the mean response is sufficiently
% large (so that negative vals don't occur)
coh = 0
ntrials = 100
ExpectedCountUP = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*coh)
ExpectedCountDOWN = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerNCoh*coh)

CountsUP = normrnd(ExpectedCountUP,sqrt(FanoFactor*ExpectedCountUP),ntrials,1);
CountsDOWN = normrnd(ExpectedCountDOWN,sqrt(FanoFactor*ExpectedCountDOWN),ntrials,1);

% On each trial, the monkey chooses UP if the UP response exceeds the down
% response.  This is just the standard likelihood model that links SDT with
% psychophysics.
choicesUP = CountsUP>CountsDOWN;  	% here's the decision rule
choicesDOWN = ~choicesUP;

% Now let's see whether there is an association between the choice 
% the monkey makes and the response from the Up Neuron
[h1,resp,fUP] = freqhist(CountsUP(choicesUP),[0:2:40]);
[h2,resp,fDOWN] = freqhist(CountsUP(choicesDOWN),[0:2:40]);
figure(1),
hold off
h1 = bar(resp,fUP);
hold on
h2 = bar(resp,-fDOWN);
set(h2,'FaceColor','none')
set(gca,'TickDir','out','FontSize',14,'Box','off');
xlabel('Spike count')
ylabel('Relative frequency')
tck = get(gca,'YTick');
tck = round(100*tck) / 100;
set(gca,'YTick',tck,'YTickLabel',num2str(abs(tck')),'XLim',[0 42])
s='Response distributions from UP neuron to 0% coh, sorted by choice';
title(s),set(get(gca,'Title'),'FontSize',12)


% Notice the subtle difference in these distributions.  
% The mean response from the UP neuron on UP choice trials is
mean(CountsUP(choicesUP))
% The mean response from the UP neuron on DOWN choice trials is
mean(CountsUP(choicesDOWN))

% Remember, these are responses to the same stimulus.
%
% One way to think about this is to ask how well an observer could guess
% the monkey's judgment from the responses.  This is a little like asking how 
% well the neuron's responses discriminate the direction of motion.  We did this 
% to compute the neurometric function.  Here we are asking how well
% an ideal observer would categorize the monkey's choices on the basis
% of the response of the neuron.  As in the sdtTutorial, it would be easier 
% to think of this as if we were given two responses, one drawn from 
% the set associated with UP choices and one associated with DOWN choices 
% (remember these are responses to the SAME stimulus).  You (the ideal
% observer) would say that the larger response was obtained when the monkey 
% chose UP.  What's the probability that you would be right?
% Answer: area under the ROC
ChoiceProbabilityUP = rocN(CountsUP(choicesUP), CountsUP(choicesDOWN))
% You should get a value around 0.86.  That's a pretty strong association. 
% It is a prediction about something that can be measured if you record
% from the right neuron in a monkey doing psychophysics.
% You can compute the theoretical value from the Normal distribution, but
% I'll leave that as an exercise in conditional probabilities.


% You can also write some code to look at the distribution of responses from 
% the DOWN preferring neuron.
[h1,resp,fUP] = freqhist(CountsDOWN(choicesUP),[0:2:40]);
[h2,resp,fDOWN] = freqhist(CountsDOWN(choicesDOWN),[0:2:40]);
figure(2), hold off
h1 = bar(resp,fUP);
hold on
h2 = bar(resp,-fDOWN);
set(h2,'FaceColor','none')
set(gca,'TickDir','out','FontSize',14,'Box','off');
xlabel('Spike count')
ylabel('Relative frequency')
tck = get(gca,'YTick');
tck = round(100*tck) / 100;
set(gca,'YTick',tck,'YTickLabel',num2str(abs(tck')),'XLim',[0 42])
s = sprintf('Response distributions from DOWN neuron to %d%% coh, sorted by choice', coh);
title(s),set(get(gca,'Title'),'FontSize',12)


ChoiceProbabilityUP = rocN(CountsDOWN(choicesDOWN), CountsDOWN(choicesUP))

% Convince yourself that the responses in Figs 1 and 2 are actually not
% different from each other if we ignore the monkey's choices.  They are
% the UP neuron's responses to 0% coh motion and the DOWN neuron's responses 
% to 0% coh motion.  There's no difference, on average, in the way that the
% UP and DOWN preferring neurons respond to 0% coh motion. 
% All we're saying here is that if the monkey says "up" when the UP neuron
% responds more than the DOWN neuron, then the responses will tend to sort 
% themselves in this way.

% So what is the real situation?   The choice probability in MT is about 0.58. 
% That's a long way from 0.86.  Why?
% Well, the monkey is probably not making choices based on just one neuron.
% So let's follow the same line of thinking developed in sdtTutorial.
% Suppose the monkey pools the activity from many neurons. 
% Let's assume the variable responses from each neuron on each trial are all
% independent of one another.

poolsize = 50;
coh = 0
ntrials = 100
ExpectedCountUP = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*coh)
ExpectedCountDOWN = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerNCoh*coh)
% make matrices of the responses.  The rows are the trials.  The columns
% are the neurons.  We simulate two pools, UP and DOWN.
CountsUP = normrnd(ExpectedCountUP,sqrt(FanoFactor*ExpectedCountUP),ntrials,poolsize);
CountsDOWN = normrnd(ExpectedCountDOWN,sqrt(FanoFactor*ExpectedCountDOWN),ntrials,poolsize);

% The decision rule now depends on the average reponse of all the neurons in 
% the pool:
choicesUP = mean(CountsUP,2) > mean(CountsDOWN,2);  	
choicesDOWN = ~choicesUP;

% Now sort the responses from any 1 of the UP neurons, based on the monkey's
% choices

whichNeuron = 1
[h1,resp,fUP] = freqhist(CountsUP(choicesUP,whichNeuron),[0:2:40]);
[h2,resp,fDOWN] = freqhist(CountsUP(choicesDOWN,whichNeuron),[0:2:40]);
figure(1),
hold off
h1 = bar(resp,fUP);
hold on
h2 = bar(resp,-fDOWN);
set(h2,'FaceColor','none')
set(gca,'TickDir','out','FontSize',14,'Box','off');
xlabel('Spike count')
ylabel('Relative frequency')
tck = get(gca,'YTick');
tck = round(100*tck) / 100;
set(gca,'YTick',tck,'YTickLabel',num2str(abs(tck')),'XLim',[0 42])
s = sprintf('Response distributions from 1 UP neuron to %d%% coh, sorted by choice, poolsize=%d',...
  coh, poolsize);
title(s),set(get(gca,'Title'),'FontSize',12)


% Notice the subtle difference in these distributions has more or less
% vanished.  I'm assuming you used a poolsize larger than 10.

% The mean response from the UP neuron on UP choice trials is
mean(CountsUP(choicesUP,whichNeuron))
% The mean response from the UP neuron on DOWN choice trials is
mean(CountsUP(choicesDOWN,whichNeuron))

% What is the choice probability in this case?  
% I wrote a tool that computes ROC area for each of the poolsize neurons
% We'll take the mean.
ChoiceProbabilityUP = mean(nanroc(CountsUP(choicesUP,:), CountsUP(choicesDOWN,:)))

% If you chose poolsize of about 20, then you got a choice probability of 
% about 0.56.  If you choose poolsize of 100 you should get down below 0.54

% This is looking good.  We could, in principle, find the poolsize that predicts
% the measured choice probability.  We ought to be pleased that the size
% is larger than one.  How could we have possibly found the one neuron that
% the monkey uses to base judgments of up?  Really!  
% On the other hand, when we have a lot of neurons in the pool, we would 
% expect an improvement in sensitivity.  That's not good!  The single neurons
% in MT are awfully sensitive.  Remember, the neurometric function is 
% a pretty good match for the psychometric function.  If we pool lots 
% of neurons, the sensitivity gets fantastic and we can no longer account
% for the monkey's performance (threshold).  That's unacceptable.  It implies
% that our decision rule is wrong!   
% In fact, we would like to account for both sensitivity (i.e., threshold) and 
% choice probability with the same rule.  
% That turns out to be a tall order.  More neurons reduces the impact of any
% one on the behavior trial-to-trial, but increases sensitivity to weak 
% motion.  We'll come back to this.

% Remember for the sdtTutorial, that if the responses of the neurons that 
% comprise the pools are *not* independent, then the benefits of pooling are
% curtailed.  Let's look at this.

% let's choose a level of correlation:
rbar = 0.2

% To make weakly correlated responses, we start with 0-mean, unit-variance
% normal deviates.
xUP = normrnd(0,1,ntrials,poolsize);
xDOWN = normrnd(0,1,ntrials,poolsize);
% notice that these values are independent.  The mean r value from all 
% the pairs should be very close to 0.  LEt's convince ourselves.
% There are lots of pairwise r vals, poolsize*(poolsize-1) / 2
% Plot a frequency histogram.
rmatrix = corrcoef(xUP);
rmatrix(logical(eye(size(rmatrix)))) = nan;
figure(1),hold off, freqhist(rmatrix);
set(gca,'TickDir','out','FontSize',14,'Box','off');
set(gca,'XLim',[-1 1])
xlabel('r_{ij}')
ylabel('Relative frequency')
% or take the mean of the off diagonal terms of the correlation matrix
meanR(xUP)
meanR(xDOWN)

% We can correlate the rows of xUP as follows.
% Treat each of the rows as a column vector (xUP')

% generate a matrix which is the square root matrix of
% the desired covariance matrix.  I don't know a good way to do
% this so I designed a brute force method.  I'm sure there are better ways, 
% but this works.  You can look at 
% 
[C Q] = qrancorrelmtx(poolsize,rbar,rbar,1);

% Notice that Q*Q' approximates C.  Q is the matrix square root.

CountsUP = ExpectedCountUP + sqrt(FanoFactor*ExpectedCountUP)* (Q*xUP')';
CountsDOWN = ExpectedCountDOWN + sqrt(FanoFactor*ExpectedCountDOWN)* (Q*xDOWN')';

% Confirm that the pairwise correlation is about rbar

rmatrix = corrcoef(CountsUP);
rmatrix(logical(eye(size(rmatrix)))) = nan;
figure(1),hold off, freqhist(rmatrix);
set(gca,'TickDir','out','FontSize',14,'Box','off');
set(gca,'XLim',[-1 1])
xlabel('r_{ij}')
ylabel('Relative frequency')
% or take the mean of the off diagonal terms of the correlation matrix
meanR(CountsUP)
meanR(CountsDOWN)

% So now we have matrices of responses.  Each row is a trial.
% Each  column is the response from 1 neuron.

% What's the choice probability?

% The decision rule is 
choicesUP = mean(CountsUP,2) > mean(CountsDOWN,2);  	
choicesDOWN = ~choicesUP;

% Now sort the responses from any 1 of the UP neurons, based on the monkey's
% choices

whichNeuron = 1
[h1,resp,fUP] = freqhist(CountsUP(choicesUP,whichNeuron),[0:2:40]);
[h2,resp,fDOWN] = freqhist(CountsUP(choicesDOWN,whichNeuron),[0:2:40]);
figure(3),
hold off
h1 = bar(resp,fUP);
hold on
h2 = bar(resp,-fDOWN);
set(h2,'FaceColor','none')
set(gca,'TickDir','out','FontSize',14,'Box','off');
xlabel('Spike count')
ylabel('Relative frequency')
tck = get(gca,'YTick');
tck = round(100*tck) / 100;
set(gca,'YTick',tck,'YTickLabel',num2str(abs(tck')),'XLim',[0 42])
s = sprintf('Response distributions from 1 UP neuron to %d%% coh, sorted by choice; r=%.3f, poolsize=%d',...
  coh, rbar, poolsize);
title(s);set(get(gca,'Title'),'FontSize',12)

% Here's the choice probability (the mean value for each of the poolsize
% neurons.  The answer should be around 0.67, depending on poolsize

ChoiceProbabilityUP = mean(nanroc(CountsUP(choicesUP,:), CountsUP(choicesDOWN,:)))


% This is getting interesting.  If many neurons are weakly correlated
% then two things hold.  We learned in the sdtTutorial that the expected improvement
% in sensitivity is curtailed.  Now we learn that any one of these neurons
% retains a relationship with the decision.

% Convince yourself that larger poosizes than 50 or so do not lead to 
% big changes in the choice probability.  Remember that the improvement in sensitivity
% reaches asymptotic value with weakly correlated pools of responses.  There
% is an analogous statement about choice probability.  As poolsize increases
% the effect of one neuron on the pooled response lessens, but only to a 
% point.  Again, by 50-100 neurons, the choice probability approaches 
% an asymptotic value.  This is an important observation.  The correlation we 
% implemented here is very weak and probably realistic.  Putting this another 
% way, were it not for correlation, we would probably not measure a choice
% probability.

% So how far off are we?  We now have a substantial covariation between 
% single neuron and monkey choice -- too large in fact.  We also expect that
% pools of neurons will out perform single neurons, leading to lower predicted
% thresholds (better sensitivity).  Let's confirm this and get a sense of what
% it will take to remedy the discrepancy.

% First, compute a psychometric function for 1 neuron
correct = zeros(size(cohvect));
for i = 1:length(cohvect)
	coh = cohvect(i);
	
	ExpectedCountUP = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*coh);
	ExpectedCountDOWN = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerNCoh*coh);

	CountsUP = normrnd(ExpectedCountUP,sqrt(FanoFactor*ExpectedCountUP),ntrials,1);
	CountsDOWN = normrnd(ExpectedCountDOWN,sqrt(FanoFactor*ExpectedCountDOWN),ntrials,1);

	choicesUP = CountsUP>CountsDOWN;  	% here's the decision rule
	% choicesDOWN = ~choicesUP;
	correct(i) = sum(choicesUP) / ntrials;
end	
data = [cohvect correct ntrials*ones(size(cohvect))];
[thresh slope] = quickfit(data);
x = logspace(-2,0,100)';
pmf = 1 - .5 * exp( -(x/thresh).^slope );
% plot it
figure(1)
clf
plot(x,pmf),hold on
plot(cohvect,correct,'bo')
set(gca,'TickDir','out','FontSize',14,'Box','off');
set(gca,'XScale','log','XTick',[.025 .05 .1 .2 .4 .8],'XLim',[.0125 1])
xlabel('Motion strength (coherence)')
ylabel('Probability correct')
s = sprintf('Predicted psychometric function from poolsize=1, r=0: thresh=%.3f', thresh)
title(s),set(get(gca,'Title'),'FontSize',12)


% Depending on eccentricity, monkeys perform near about 0.1 and neurons
% in MT have neurometric thresholds just greater than this.
% you can adjust the slope terms at the beginning of this tutorial if
% you want to get this better.  

% So now we're ready to ask about pools of neurons
poolsize = 50
rbar = 0.2
[C Q] = qrancorrelmtx(poolsize,rbar,rbar,1);

correct = zeros(size(cohvect));
for i = 1:length(cohvect)
	coh = cohvect(i);
	ExpectedCountUP = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerPCoh*coh);
	ExpectedCountDOWN = Duration * (SpikesPerSecAtCoh0 + SpikesPerSecPerNCoh*coh);
	xUP = normrnd(0,1,ntrials,poolsize);
	xDOWN = normrnd(0,1,ntrials,poolsize);
	CountsUP = ExpectedCountUP + sqrt(FanoFactor*ExpectedCountUP)* (Q*xUP')';
	CountsDOWN = ExpectedCountDOWN + sqrt(FanoFactor*ExpectedCountDOWN)* (Q*xDOWN')';
	choicesUP = mean(CountsUP,2) > mean(CountsDOWN,2);  	
	% choicesDOWN = ~choicesUP;
	correct(i) = sum(choicesUP) / ntrials;
	if coh==0
		ChoiceProbabilityUP = mean(nanroc(CountsUP(choicesUP,:),...
		CountsUP(choicesDOWN,:)))
	end
	

end	
data = [cohvect correct ntrials*ones(size(cohvect))];
[thresh slope] = quickfit(data)
x = logspace(-2,0,100)';
pmf = 1 - .5 * exp( -(x/thresh).^slope );
% plot it
figure(1)
hold on
plot(x,pmf,'r'),hold on
plot(cohvect,correct,'ro')
set(gca,'TickDir','out','FontSize',14,'Box','off');
set(gca,'XScale','log','XTick',[.025 .05 .1 .2 .4 .8],'XLim',[.0125 1])
xlabel('Motion strength (coherence)')
ylabel('Probability correct')
s = sprintf('Predicted psychometric function from poolsize=1, r=0: thresh=%.3f, choiceprob=%.3f', thresh,ChoiceProbabilityUP);
title(s)
set(get(gca,'Title'),'FontSize',12)

% The threshold should be about 0.07.  That's better than the single 
% neuron, no doubt about it, but it's not a whole lot better.  Why not?  
% Answer: weak correlation among the pool members.  The choice probability is 
% a bit high, but not too high (about 0.6). That's promising because a little noise 
% might align both predictions with the measurements (threshold and choice
% probability).  Remember, without correlation we were in trouble.  We either
% had to have few neurons in the pools to get a reasonable predicted threshold, 
% or we predicted a very high choice probability.  Had we added noise to 
% such a model we could conceivably lower the choice probability and 
% the choice probability, but the strategy fails to satisfy both
% experimental constraints.  Of course, the values we used to model
% MT responses were not taken from real cells.  If you would like to
% explore these issues further, using real values for MT response, 
% try the mtModelDemo.m. 


