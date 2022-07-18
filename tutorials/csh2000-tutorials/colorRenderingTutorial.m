% colorRenderingTutorial
%
% This tutorial introduces some standard colormetric
% calculations.  To do so, it takes you through the
% process of simulating a set of surfaces under some
% illuminant.
%
% This tutorial was created by updating an existing
% tutorial provided by David Heeger.
%
% See also: colorSpaceTutorial
%
% Dependencies:
%               a) Psychophysics Toolbox:PsychColorimetricData
%               b) colorFunctions subfolder
%
% 06/14/98  dhb   Updated Heeger version for CSH '98.
%			dhb	  Use Psychophysics Toolbox data and functions
%                 when possible.  Change data structures to
%                 match Psychophysics Toolbox conventions.
%
% 06/13/00 GDLH   Eliminated dependency on imShow.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Introduction
%
% In this tutorial, we will introduce some basic spectral
% calculations that we can use to understand color vision,
% surface reflectances, illuminants, photoreceptor encoding, and
% linear models of surface spectra.
%
% You will notice that much of the work below involves matrix
% algebra.  We suggest that you pull out a pad of paper and draw
% matrix tableaus as we proceed to help you follow the
% calculations.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Initialize
%
clear
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Read in a set of surfaces
%
% The Macbeth Color Checker is a set of 24 surfaces commonly used
% to evaluate color balancing systems.  The materials in the
% Color Checker were selected to have the same surface
% reflectance functions as various important surfaces that are
% commonly used in television and film images.  We will read in a
% matrix of data.  Each column of the matrix is the reflectance
% function of one of the Macbeth surfaces, measured at each of 81
% samples in the visible spectrum.  (Most of the visible spectrum
% is in the 380-780 nanometers wavelength region, and we sample
% this region at 5 nm intervals.  Thus we get a 81 by 24
% matrix of surface spectra.  This matrix is called sur_macbeth.
% The file also contains a 3 by 1 row vector S_macbeth. This
% specifies the wavelength sampling in the form [start delta number].
load sur_macbeth
S = S_macbeth; clear S_macbeth
start = S(1); delta = S(2); number = S(3);
spectrum = (start:delta:(start+(number-1)*delta))';

% The 6th column of this matrix is a surface that typically looks
% greenish.  We plot the fractional reflectance (as a function of
% wavelength) for this surface.
%
% These functions were not measured over the full 380-780 nm
% range.  Outside the range of the original measurements,
% the data were set (arbitrarily) to zero.
greenIndex = 6;
figure(1); clf
plot(spectrum,sur_macbeth(:,greenIndex),'g');
xlabel('Wavelength (nm)');
ylabel('Surface Reflectance');
title('Reflectance of Macbeth Surfaces');
drawnow;

% For example, about 63% of the light at wavelength 500 nm is
% reflected by the "green" surface.
green_500 = sur_macbeth(find(spectrum==500),greenIndex);
fprintf('\nPercent of "green" surface reflected at 500 nm: %g\n\n',...
	100*green_500);
	
% Here is a red surfacefigure(1);
figure(1);
redIndex = 9;
hold on
plot(spectrum,sur_macbeth(:,redIndex),'r');
hold off
drawnow;

% And here is a gray surface
figure(1);
grayIndex = 20;
hold on
plot(spectrum,sur_macbeth(:,grayIndex),'k');
hold off
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Read in an illuminant
%
% The illuminant is D65, a standard illuminant which
% represents a mix of blue sky and clouds.  It is
% represented as a column vector and the light is
% again sampled at 81 points in the visible spectrum.
load spd_D65
illuminantSpectrum = spd_D65;

% Make a plot of D65.  Note that the power units are
% arbitrary.
figure(1); clf
plot(spectrum,illuminantSpectrum,'b');
xlabel('Wavelength (nm)');
ylabel('Power (arbitrary units)');
title('Power spectrum of CIE D65 Illimunant');
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Calculate the spectral signal resulting when D65 illuminate
% the Macbeth color checker.
%
% The spectral signal is the pointwise product of the incident
% light and the reflectance of the surface at the each
% wavelength.  This can be expressed as a matrix product, where
% the surface matrix is multiplied by a big diagonal matrix with
% the light intensities at each wavelength along the diagonal.
% So, we get a 81 by 24 matrix with the spectral signal.
spectralSignals = diag(illuminantSpectrum)*sur_macbeth;

% Note that this same calculation could have been written
%   spectralSignals = illuminantSpectrum.*sur_macbeth;
% We do it using the diag command because this format will
% be useful when we think about computational color constancy.

% As examples, plot the spectral signal coming off the green, red,
% and gray Macbeth surfaces under D65
figure(1); clf
plot(spectrum,spectralSignals(:,greenIndex),'g');
hold on
plot(spectrum,spectralSignals(:,redIndex),'r');
plot(spectrum,spectralSignals(:,grayIndex),'k');
hold off
xlabel('Wavelength (nm)');
ylabel('Reflected Power (arbitrary units)');
title('Reflected power of surfaces under CIE D65')
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Read in estimates of the human cone spectral sensitivities.
% 
% Now we want to estimate the photoresponses of the human cones to
% these stimuli.  The human cone spectral sensitivities have been
% estimated and correspond closely with behavioral color matching
% data known for many years.  We now read in a matrix of containing
% estimates of the human cone sensitivities.  There are three classes
% of cone, the so-called L,M, and S cones ((L)ong-, (M)iddle-, and
% (S)hort-wavelength peak sensitivities). Again, we represent each
% cone by its sensitivity at each of 81 sample wavelengths in the
% spectrum.  Each of these estimates is placed in one row (not
% column) of an 81 by 3 matrix.  By putting sensitivities in
% the rows of a matrix rather than in columns, we remind ourselves
% that sensitivities and spectral power distributions are different
% physical entities.
%
% The sensitivities we load are the Smith-Pokorny estimates.  These
% are derived from the Judd-Vos modified XYZ color matching functions.
% Each cone sensitivity is normalized to a maximum of 1.
load T_cones_sp
T_cones = T_cones_sp;

% Look at the three cone classes superimposed.  Notice how close
% the L and M cones are in terms of their peak sensitivities.
figure(1); clf;
plot(spectrum,T_cones(1,:)','r');
hold on
plot(spectrum,T_cones(2,:)','g');
plot(spectrum,T_cones(3,:)','b');
xlabel('Wavelength (nm)');
ylabel('Relative Sensitivity');
title('Cone Spectral Sensitivity Functions');
hold off
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Calculate responses of these cones.
% 
% We can describe the receptor encoding as a matrix multiplication
% too. The matrix product of the receptor sensitivites and the
% spectral signals gives the rate of photoisomerizations in
% each receptor class due to each of the surfaces seen under
% D65. Hence, we have a 3x24 matrix of cone coordinates.
coneSignals = T_cones*spectralSignals;

% Print out values for red, green, gray.  Because the scale of
% our cone sensitivities is arbitrary (we normalized each peak
% to one), it is not possible to compare meaningfully the
% absolute values of the L, M, S values of the cone signals.
fprintf('Green L: %g, M: %g, S: %g,\n',...
	coneSignals(1,greenIndex),coneSignals(2,greenIndex),coneSignals(3,greenIndex));
fprintf('Red L: %g, M: %g, S: %g,\n',...
	coneSignals(1,redIndex),coneSignals(2,redIndex),coneSignals(3,redIndex));	
fprintf('Gray L: %g, M: %g, S: %g,\n\n',...
	coneSignals(1,grayIndex),coneSignals(2,grayIndex),coneSignals(3,grayIndex));
	
% As a final note on units, note that if we were working with real units,
% we would have to take into account the wavelength sampling interval
% when computing cone signals from spectral signals.  There are a 
% couple of conventions that can handle this.  In the Psychophysics
% Toolbox, spectral power units are always specified in terms of
% power per wavelength sampling band, rather than in terms of power
% per nanometer.  As long as this convention is faithfully observed,
% it is not necessary to explictly multiply by the wavelength sampling
% interval.  Other equally good conventions are possible.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Render the surfaces so that they look right.
% 
% To do this, we need to know some calibration information
% about our monitor.  What we'll do is to produce signals
% on the monitor that have produced the same photoisomerization
% rates as the surfaces seen under D65.

% Load phosphor spectra of a "typical" monitor.  Each column
% of the matrix contains the spectral power distribution of
% on monitor phosphor.
load B_monitor
phosphors = B_monitor;

% Plot the spectral phosphor power distributions
figure(1);clf
plot(spectrum,phosphors(:,1),'r');
hold on
plot(spectrum,phosphors(:,2),'g');
plot(spectrum,phosphors(:,3),'b');
hold off
xlabel('Wavelength (nm)');
ylabel('Power (arbitrary units');
title('Spectral power distributions of typical monitor phosphors');
drawnow;

% Next we calculate the linear red, green, and blue monitor phosophor
% intensities required to generate the *same* receptor responses in your
% eye that the Macbeth surfaces generate under daylight.  To do so, we
% first find the linear tranform that gives the cone responses due to
% the different monitor spectra.  To understand this calculation, try
% pulling out a  piece of paper and convincing yourself that this is
% the way to get cone responses from the phosphor intensities.
M_RGBToCones = T_cones*phosphors;

% The inverse of this matrix tells us how to set the
% phosphors to achieve any desired cone responses.
% The units of the RGB intensities are relative to
% the maximum possible output of each phosphor.  Thus
% a value of 1 means set the phosphor to its maximum,
% 0.5 means set it to half its maximum, etc.
M_ConesToRGB = inv(M_RGBToCones);
linearRGBSignals = M_ConesToRGB*coneSignals;

% Sometimes the above calcluation leads to linear RGB values
% that are out of gamut, that is greater than 1 or less than 0.
%
% Values greater than 1 mean that the monitor can't produce enough
% light to match the desired value.  This would not be surprising
% in our case, since we have not paid any attention to our units
% of power.  To handle this, we will simply scale all of the
% RGB values so that the maximum we get is 1.  For serious
% work, you'd have to put actual units on the light power and
% simulate illuminant intensities that are commensurate with
% what the monitor can produce.
maxSignal = max(linearRGBSignals(:));
fprintf('\nDividing linear RGB values by %g to bring into range\n',maxSignal);
linearRGBSignals = linearRGBSignals/maxSignal;

% Values less than 0 mean that we're trying to simulate
% a color that is outside the gamut of our monitor's phosphors.
% We handle this case by simply setting these values to 0.
% There are more interesting ways to handle this
% "gamut mapping problem".
index = find(linearRGBSignals < 0);
if (~isempty(index))
	fprintf('Setting %g out of gamut intensities to 0\n',length(index));
	linearRGBSignals(index) = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Actually display the image
% 
% First we rearrange the data to put it into a form
% that can be displayed.  Expand is a function that
% is part of the Psychophysics Toolbox, but is
% included in the subdirectory colorFunctions to
% make this tutorial self-contained.
clear colorImage
pixelsPerSquare = 25;
redPlane = Expand(reshape(linearRGBSignals(1,:),6,4)',pixelsPerSquare);
greenPlane = Expand(reshape(linearRGBSignals(2,:),6,4)',pixelsPerSquare);
bluePlane = Expand(reshape(linearRGBSignals(3,:),6,4)',pixelsPerSquare);
colorImage(:,:,1) = redPlane;
colorImage(:,:,2) = greenPlane;
colorImage(:,:,3) = bluePlane;
clear redPlane greenPlane bluePlane

% One last problem.  Most monitors have a non-linear relation
% between what you pass to the display routine and what
% actually comes out of the monitor.  To make our rendering
% accurate, we have to correct for this.  As we write this
% tutorial, we don't know what computer you are running on,
% so we can't do this properly.  (For that matter, we assumed
% "typical" monitor phosphors, and yours may not be.)
%
% A very quick and dirty way to gamma correct is just
% to raise the linear intensities to a power of about
% 0.5, but this will be at best an approximation.
colorImage = colorImage.^0.5;

% And now we display it. 

figure(1); clf;
image(colorImage);

% If you compare the appearance of the simulated surfaces
% to an actual Macbeth Color Checker, you will see that
% it is approximately correct, except for the last three
% squares of the third row.  Somewhere along the line,
% the reflectance data for these squares got munged.
% We will have fix this up next time we have a radiometer
% and a color checker in the same place.

% You should simulate the appearance of the same surfaces under
% a different illuminant.
%
% At the stage where the illuminants
% are loaded, simply load another one and then assign
% the loaded illuminant (which has the same name as the file)
% to the variable illuminantSpectrum.
% 
% Some available illuminants:
%  spd_CIEA: a standard tungsten
%  spd_flourescent: some flourescent light
%  spd_xenonFlash: some xenon flash
%
% Do the rendered surfaces look the same?  Why or why not?
