%-------------------------------------------------------------% Principle Components Analysis Tutorial for NeuBeh/PBIO 545%% This tutorial introduces Principle Components Analysis.  The aims are:% (1) introduce dimensional reduction and its importance% (2) introduce the covariance and covariance matrix% (3) show how the eigensystem of the covariance matrix helps rank dimensions of%	  a probability distribution by the amount of variance they capture% (4) illustrate these concepts with a couple examples%% This builds on two key concepts introduced earlier in the course: probability % distributions and eigensystems.  If you are uncomfortable with either of those% take another pass through the appropriate sections of the stochastic processes% and/or linear algebra tutorials.%% Created 2/03 Fred Rieke% Revised%-------------------------------------------------------------%-------------------------------------------------------------% Motivation for dimensional reduction%%	What do we mean by dimensional reduction and why should you care% about it?  With finite experimental data we always face a tradeoff between% trying to identify all the important structure in the data while not being% misled by randomness introduced because we don't have an infinite number of % samples.  A common example is construction of a post-stimulus time histogram % for spike responses to a repeated stimulus: in choosing the time bin for the % histogram we face a tradeoff of smoothing over temporal structure in the spike % train and avoiding lots of spurious structure due to finite data.  % Here's an example of a set of spike responses from a retinal ganglion cell to a % dim flash of light:  load rgc-spike-response% plot several examplesfigure(1);clf;plot(0);hold on;for resp=1:10	plot([-1:.001:2.999], RGCSpikes(resp, :)/1.2 + resp)endhold offxlabel('time (sec)')ylabel('trial')% This data is discretized into 1 msec time bins - so we have already thrown some% information about spike times away.  Still a psth without any extra smoothing looks% pretty ugly:figure(1)subplot(1, 2, 1)plot([-1:.001:2.999], mean(RGCSpikes))xlabel('time (sec)')ylabel('spike probability')% You can at least see there is an extra density of spikes after the flash, but you also % have some sense that most of the structure in the histogram is just noise.  In effect % we are retaining too many variables - in this case each of the 4000 time bins that% specify the spike times.  This is equivalent to representing each spike train % in a 4000 dimensional space, where each dimension corresponds to one time bin.% Let's resample the data to produce larger time bins and repeatResampleFactor = 100;		% 100 msec binsclear ResampledRGCSpikes;for resp=1:size(RGCSpikes, 1)	ResampledRGCSpikes(resp, :) = decimate(RGCSpikes(resp, :), ResampleFactor, 1);endsubplot(1, 2, 2)plot([-1:.001*ResampleFactor:2.999], mean(ResampledRGCSpikes));xlabel('time (sec)')ylabel('spike probability')% this certainly looks better.  Now we are in effect using a 40 dimensional space, with% each dimension a 100 msec time bin.  But we might start to worry that we are smoothing% too much and losing some real structure.  Part of the problem here is unavoidable: with finite % data there is only so much structure we can identify and separate from sampling errors.% But we would like to make the best use possible of our finite data - i.e. we would % like to reduce the number of dimensions describing the data as effectively as possible.% PCA is about finding a relatively low dimensional representation of % a set of data - and doing so systematically rather than using some ad hoc% procedure.  In the example above, the strategy of smoothing over bins % to produce a better looking psth is somewhat arbitrary and is not guided% by the structure of the cell's responses itself.  What PCA will do is provide% a set of components (think of this as a set of axes in the space the data is % represented in - our 4000 dimensional space above).  Importantly, PCA tells us how% much structure in the data is captured by each dimension.  We will make this more% concrete below.%-------------------------------------------------------------% Part 1: Covariance and covariance matrix%%	Consider a signal characterized by two variables, x and y.  The covariance % matrix for x and y is defined as:%	Covar = [<xx>-<x><x>  <xy>-<x><y>%			 <xy>-<x><y>  <yy>-<y><y>]% where <x> is the average of x, etc.  The diagonal elements contain% the variances of x (upper left) and y (lower right).  The off diagonal terms% contain the correlation between x and y.  Note that each element is% corrected for the expectation based on the mean values alone - i.e. we % take <xy> and subtract what we expect from the averages of x and y along - <x><y>.%% Let's look at some examples.%% Example 1: x and y independent% each row of Dist contains a separate x-y pair, x is the first column, y the secondclear Dist;Dist(:, 1) = normrnd(0,0.3,10000, 1);			Dist(:, 2) = normrnd(0,1,10000, 1);figure(1)clfsubplot(1, 2, 1)plot(Dist(:, 1), Dist(:, 2), '.');axis([-3 3 -3 3])axis squarexlabel('x')ylabel('y')% construct the covariance matrix explicitlyvarx = mean(Dist(:, 1).^2) - mean(Dist(:, 1))^2;vary = mean(Dist(:, 2).^2) - mean(Dist(:, 2))^2;covarxy = mean(Dist(:, 1) .* Dist(:, 2)) - mean(Dist(:, 1)) * mean(Dist(:, 2));Covar = [varx 		covarxy		 covarxy 	vary]		 % alternatively Matlab has a covariance commandcov(Dist)% In this case the diagonal of the covariance matrix is the variance of x and y,% and the off diagonal elements are small (and due to the finiteness of our sample set -% rerun the code above several times to convince yourself of this). %% The lack of covariance is what we might expect from the shape of the plotted distribution.  % The spread of points along the x axis appears uncorrelated with the spread along the % y axis - or in other words, if I told you the x axis value, you could not predict the% y axis value.  % Example 2: x and y correlatedclear Dist;Dist(:, 1) = normrnd(0,0.3,10000, 1);			Dist(:, 2) = normrnd(0,1,10000, 1) + 1.5 * Dist(:, 1);figure(1)subplot(1, 2, 2)plot(Dist(:, 1), Dist(:, 2), '.');axis([-3 3 -3 3])axis squarexlabel('x')ylabel('y')% construct the covariance matrix varx = mean(Dist(:, 1).^2) - mean(Dist(:, 1))^2;vary = mean(Dist(:, 2).^2) - mean(Dist(:, 2))^2;covarxy = mean(Dist(:, 1) .* Dist(:, 2)) - mean(Dist(:, 1)) * mean(Dist(:, 2));Covar = [varx 		covarxy		 covarxy 	vary]cov(Dist)% Now note that the distribution shows a correlation between x and y - i.e. the % distribution is angled in the x-y plane.  Correspondingly the covariance has off % diagonal elements.  % You can think of lots of cases where x and y might be correlated.  For example, % x might be fraction of lectures Mike gives, and y might be fraction of lectures% containing superfluous PowerPoint `features.'  Maybe a better example is two cells% with common input and hence correlated spike trains: x could be the firing rate % in one cell and y the firing rate in the other.  If the cells are correlated, when% cell x generates a high firing rate, so does cell y.  Hence the value of x gives% you some ability to predict y.% This generalizes to higher dimensions as well.  Let's consider a could more examples:% Example 3: 6-d, no correlation between any componentsclear Dist;NumDim = 6for dim = 1:NumDim	Dist(:, dim) = normrnd(0,dim,10000, 1);			endcov(Dist)% Again in this case the covariance matrix is diagonal, with elements equal to the % variance, and the off diagonal elements are small and not systematically different% from 0 (run again to convince yourself of that).% Example 4: 6-d, some elements correlatedclear Dist;NumDim = 6for dim = 1:NumDim	Dist(:, dim) = normrnd(0,dim,10000, 1);				if (dim > 1)		Dist(:, dim) = Dist(:, dim) + 0.5 * Dist(:, dim-1);				endendcov(Dist)% Like the simple 2-d example, when we create a correlation between the variables% corresponding to the different axes or dimensions of the data, we introduce% non-zero off diagonal components.% Keep this picture of the covariance matrix in mind when we turn to applications% to problems in neuroscience below.% Question set #1:%	(1) Explain the value of the components of the 2 dimensional covariance matrix in %		Example 2 above.  %	(2) Which of the off diagonal elements in the covariance matrix for Example 4 above%		are nonzero?  Why?%-------------------------------------------------------------% Part 2: Eigensystem of the covariance matrix%%	The eigenvectors of the covariance matrix turn out to provide a useful coordinate system.% In particular, the eigenvalues determine how much of the variance of the distribution falls% along the associated eigenvector.  Let's look at this for our 2d cases above:% Example 1: x,y independentclear Dist;Dist(:, 1) = normrnd(0,0.3,10000, 1);			Dist(:, 2) = normrnd(0,1,10000, 1);C = cov(Dist);[EigVec, EigVal] = eig(C);% remember EigVec is a square matrix whose columns are the eigenvectors, and EigVal% is a diagonal matrix with the eigenvalues along the diagonal. % superimpose eigenvectors on distributionfigure(1)clfsubplot(1, 2, 1)hold onplot(Dist(:, 1), Dist(:, 2), '.');axis([-3 3 -3 3])axis squarexlabel('x')ylabel('y')PlotVector(EigVec(:, 1), 'r');PlotVector(EigVec(:, 2), 'g');hold off% So the first eigenvector (red) points along the x-axis and the second% along the y-axis.  Look at the associated eigenvalues:EigVal% They are equal to the variance associated with each eigenvector - i.e. the variance along % the x and y axes in this example.% Example 2: x,y correlatedclear Dist;Dist(:, 1) = normrnd(0,0.3,10000, 1);			Dist(:, 2) = normrnd(0,1,10000, 1) + 1.5 * Dist(:, 1);C = cov(Dist);[EigVec, EigVal] = eig(C);figure(1)subplot(1, 2, 2)hold onplot(Dist(:, 1), Dist(:, 2), '.');axis([-3 3 -3 3])axis squarexlabel('x')ylabel('y')PlotVector(EigVec(:, 1), 'r');PlotVector(EigVec(:, 2), 'g');hold off% now the eigenvectors no longer point along the x and y axis.  Instead, the% eigenvector with the largest eigenvalue (green in this case) points in the % direction along which the cloud of points is the most extended.  The second% eigenvalue points in an orthogonal direction.  And again the amount of % variance associated with each axis is given by the eigenvalue.  Let's check this% last statement.  We will project each point along each of the two eigenvectors% and measure the associated variance:% remember each row of Dist is an x-y pair (i.e. specifies the x and y components% of the vector pointing to that data point).  Thus we can compute the projections% along the eigenvectors by multiplying the Dist matrix by each eigenvector:Proj1 = Dist * EigVec(:, 1);Proj2 = Dist * EigVec(:, 2);% now check the variance of each set of projectionsvar(Proj1)var(Proj2)% this should be equal to the associated eigenvaluesEigVal% this again extends to higher dimensions:clear Dist;NumDim = 6for dim = 1:NumDim	Dist(:, dim) = normrnd(0,dim,10000, 1);				if (dim > 1)		Dist(:, dim) = Dist(:, dim) + 0.5 * Dist(:, dim-1);				endendC = cov(Dist);[EigVec, EigVal] = eig(C);EigVal% so in this case we see that the last eigenvector is associated with the most variance.  Again we can% check that the associated eigenvalues are indeed equal to the variance:for dim = 1:NumDim	fprintf(1, 'Eigenvector %d: variance = %d\n', dim, var(Dist*EigVec(:, dim)));end% Why is all this useful?  Remember that the eigenvectors provide a coordinate system% or a set of axes to represent the space spanned by the columns of a matrix.  But this% is not an arbitrary coordinate system.  The eigensystem is providing a coordinate system% for our data where each axis is ranked in terms of how much variance is associated with% it.  It is this ranking of the axes that provides a systematic way to reduce the number% of dimensions describing some piece of data.  %-------------------------------------------------------------% Applications% Example 1: current trajectories leading to spike%	start with collection of current trajectories triggered on spike%	look at mean% 	look at covariance%	look at PCs: identify 'mean' and 'derivative'% Example 2: single photon responses