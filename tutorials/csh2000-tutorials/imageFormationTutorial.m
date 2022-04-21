%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ImageFormationTutorial
%
% Author: Wandell (1/2/96)
% Modified for CSHL '98 by Heeger (6/98)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Visual Angle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To think about the effect of an image on the eye, we must
% specify the image in terms of degrees of visual angle.  As an
% example for how to compute spacing in terms of degrees of
% visual angle, consider a printer whose dots occupy (dots per inch)
dpi = 600

% Suppose we read the paper at a viewing distance (inches)
viewingDistance = 12

% The viewing angle, phi (in radians), corresponding to 1 inch
% (600 dots) on the page satisfies;
%        tan(phi) = (opposite/adjacent)
rad2deg = 360/(2*pi)
phi = atan(1/viewingDistance)*rad2deg

% There are 600 dots per inch, so that each dot occupies
DegPerDot = phi/dpi

% There are 60 min of visual angle per deg,
MinPerDot = 60*DegPerDot

% and 60 sec of visual angle per min,
SecPerDot = 60*MinPerDot

% Experiments have shown that people can localize the position of
% a line to a spatial position of roughly 6 sec of visual angle.
% Hence, at this viewing distance and with this many dots per
% inch, the dot spacing is wider than the spacing that can be
% just discriminated by the human eye.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The Westheimer linespread function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Westheimer calculated that the linespread function of the human
% eye, specified in terms of minutes of arc and using a 3mm
% pupil, should be approximated using the following formula
%
% LineSpread = 0.47*exp(-3.3 *(x.^2)) + 0.53*exp(-0.93*abs(x));
%

% Suppose we wish to plot the function by defining the spatial
% variable, x, in terms of seconds of arc,
xSec = -300:1:300;	
xMin = xSec/60;
lsa = 0.47*exp(-3.3 *(xMin.^2)) + 0.53*exp(-0.93*abs(xMin));
lsa = lsa / sum(lsa);

figure
plot(xSec,lsa)
set(gca,'xlim',[-240 240],'xtick',[-240:60:240]), grid  on
xlabel('Arc sec'), ylabel('Responsivity'), title('Westheimer Linespread')

% From our previous calculation, we observed that the dots in a
% 600 dpi printer, viewed at 12 inches, are spaced 28.5819 sec of
% visual angle apart.  At this distance, the linespread has
% fallen to about one-half of its peak value.

% Hence, if we could control the intensity and color of the
% printed dots -- which we cannot do on conventional laser
% printers -- then at this viewing distance we would be able to
% produce images that were very realistic in their appearance.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Convolution of the image and linespread
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We can estimate the visual image created by an image printed at
% 600 dpi using the following simple convolution
% calculation. Let's create an image that spans 0.2 deg and has a
% line every 30 sec.

secPerDeg = 60*60;
x = 1:0.5*secPerDeg;
im = zeros(1,length(x));
im(1:30:length(im)) = ones(size(im(1:30:length(im))));
plot(im)

% Each line in the physical image adds a unit linespread to the
% retinal image.  We can compute the retinal image by forming the
% convolution of the image with the Westheimer linespread
% function.  Remember: we sampled the linespread once every sec
% of arc. So, we can simply convolve the image and the linespread
% function now as:

retIm = conv2(lsa,im,'same');
figure
plot(retIm),grid on
title('The one-dimensional retinal image')
xlabel('Sec of arc'), ylabel('Image intensity')

% While the original image varies from black to white, after
% blurring by the eye's optics, there is only a small amount of
% residual variation (small ripples in intensity) in the retinal
% image.  Because of the blurring, the retinal image is much more
% like the image of a wide bar than it is the image of a set of
% individual lines.

% The question you might ask yourself now is this: will those
% small ripples be detectable by the observers?  How can we tell?
% You might also ask what will happen when we view the page at 6
% inches, or at 24 inches.  What if we increase the printer
% resolution to 1200 dpi?  What if we introduce some ability to
% modulate the density of the ink and hence the light scattered
% back to the eye?

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Looking at defocus in the frequency domain
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First, make a new linespread function that is smaller and
% easier to compute with.  Have it extend over 1 deg (60 min) so
% the Fourier Transform is easier to interpret

xMin = -30:1:29;	
lsa = 0.47*exp(-3.3 *(xMin.^2)) + 0.53*exp(-0.93*abs(xMin));
lsa = lsa / sum(lsa);

figure
plot(xMin,lsa), grid on
xlabel('Min of arc'),ylabel('Linespread value')

% Now, consider the retinal image that is formed by some simple
% harmonic functions.  Here is a sinusoid that varies at 1 cycle
% per degree of visual angle.

nSamples = length(xMin);
f = 1;
harmonic = cos(2*pi*f*xMin/nSamples);

figure
plot(xMin,harmonic), grid on
title('Sampled cosinusoid')
xlabel('Arc sec'), ylabel('Intensity')

% Now, we will show what happens to cosinusoids at different
% spatial frequencies.  Notice that the amplitude of the
% cosinusoid falls off as the spatial frequency increases.  We
% will store the amplitude of the cosinusoid in the variable
% "peak".

peak = []; freq =[1 5 10 15]; 
for i = 1:length(freq)
 harmonic = cos(2*pi*freq(i)*xMin/nSamples);
 retIm = cconv(harmonic,lsa,length(lsa));
 subplot(2,2,i)
 plot(retIm), grid on, set(gca,'ylim',[-1 1],'xlim',[0 64]);
 xlabel('Arc sec')
 peak = [peak max2(retIm)];
end

% We can plot the amplitude of the retinal cosinusoid, and its
% amplitude decreases with the input frequency.  I put in the
% fact that at f = 0 the amplitude is 1 (because the area under
% the linespread function is 1).

figure
plot([0 freq],[1 peak],'-')
set(gca,'ylim',[0 1])
xlabel('Spatial freq (cpd)'), ylabel('Transfer')

% Let's compare the values we obtain from the convolution with
% the values we obtain by calculating the amplitude of the
% Fourier Transform of the linespread function.  Remember, the
% linespread was built so that it spans 1 deg, hence frequency is
% in cycles per degree.

mtf = abs(fft(lsa));
hold on, plot(freq,mtf(freq + 1),'ro');
hold off

% The values we obtain from convolution are plotted as solid line,
% whereas the amplitude of the Fourier Transform of the linespread
% function is plotted as a red circles at each frequency.

% The functions match, which should give you some intuition about
% what the amplitude of the Fourier Transform represents.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Comparison of the pointspread and linespread
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% When working with two-dimensional inputs, we must consider the
% pointspread function, that is the response to an input that is
% a point of light. A standard formula for the cross-section of
% the pointspread function of the human eye for a 3mm pupil is
% also provided by Westheimer.  We can compare the linespread and
% the cross-section of the pointspread in the following graphs.

xSec = -300:300;
xMin = xSec/60;
lsa = 0.47*exp(-3.3 *(xMin.^2)) + 0.53*exp(-0.93*abs(xMin));
ps = 0.952*exp(-2.59*abs(xMin).^1.36) + 0.048*exp(-2.43*abs(xMin).^1.74);

figure
p = plot(xSec,ps,'r-',xSec,lsa,'b--'), grid on
set(gca,'xlim',[-180 180])
xlabel('Arc sec'), ylabel('LS or PS amplitude')
legend(p,'Pointspread','Linespread')

% You should be able to figure out why they are different from one another.

% Next, we can create a graph of the pointspread.  First, create
% a matrix whose entries are the distance from the origin

xSec = -240:10:240;
xMin = xSec/60;
X = xMin(ones(1,length(xMin)),:); Y = X';
D = X.^2 + Y.^2; D = D.^0.5;

% Render the distance from the origin as a grey level image:
displayImage(D);

% Then, compute the pointspread function in terms of the distance from the origin 
% and plot a surface graph picture of it
ps = 0.952*exp(-2.59*abs(D).^1.36) + 0.048*exp(-2.43*abs(D).^1.74);
figure
colormap(cool(64)), mesh(ps)

% To see the pointspread as a grey level image
displayImage(D);

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Chromatic aberration:  How the linespread varies with wavelength
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The linespread varies quite strongly with wavelength.  When the
% eye is in good focus at 580 nm (yellow-part of the spectrum)
% the light in the short-wavelength (400-450nm) is blurred quite
% strongly and light in the long-wavelength part of the spectrum
% is blurred, too, though somewhat less.  We can calculate the
% linespread as a function of wavelength (Marimont and Wandell,
% 1993) from basic principles.  The linespreads at various
% wavelengths are contained in the data file:

load lineSpread;

% This loads 3 variables:
%   wave (1x361) lists the wavelengths from 370-730 in 1 nm steps
%   xDim (1x65) lists positions in degs from -1 to 1
%   linespread (361x65) are the linespread functions at each wavelength

% We select three wavelengths and plot their linespread functions
% together. Notice that for the shorter wavelength, the
% linespread function is much more spread-out than for the middle
% and long wavelengths.

figure
plot(xDim, lineSpread(80, :), 'b-', xDim, lineSpread(200,:), ...
      'k:', xDim, lineSpread(361, :), 'r--' );
legend('wavelength 450', 'wavelength 570','wavelength 730');
xlabel('Degrees'); ylabel('Image Intensity');
title('Linespread functions for three wavelengths');

%  Look at the line spread functions for all wavelengths

lw = 1:10:length(wave);
figure
colormap(cool(32));
mesh(xDim, wave(lw), lineSpread(lw,:)); 
set(gca,'xlim',[-1 1],'ylim',[350 730])
ylabel('wavelength (nm)'); xlabel('degrees'); zlabel('intensity');

% Different wavelength components of an image are blurred to
% different extents by the eye.  We use a set of lines again as
% an example.  For this computation, we will assume that the
% input begins with equal energy at all wavelengths from 370 to
% 730 nm.

% Here, we create and display the image of sample lines.

im = reshape([0 0 0 1 0 0 0 0]' * ones(1, 16), 1, 128);
plot(im);


% To calculate the retinal image for this pattern, we
% convolve each wavelength component of the image with the
% appropriate linespread function.  The routine conv2 takes the
% input image (im, size(im) = 1 128) and convolves it with each
% of the linespread functions in lineSpread size(lineSpread =
% 361,65).  This results in 361 images (one for each
% wavelength).  

retIm = conv2(im, lineSpread, 'full');

% We must remember the size (in deg) of each sample point this way.
X = [-size(retIm,2)/2 : size(retIm, 2)/2-1] / 64;

% We can plot the retinal image corresponding to two wavelengths
% this way.

figure

subplot(2,1,1)
plot(X,retIm(200,:),'g-')
set(gca,'ylim',[0 0.5])
grid on

subplot(2,1,2)
plot(X,retIm(50,:),'b-')
set(gca,'ylim',[0 0.5])
grid on

% Notice that the two images have the same mean, they only differ
% in terms of the contrast:  the green image has a lot more
% contrast, but the same mean.

mean(retIm(50,:)')
mean(retIm(200,:)')

% The short wavelength (420 nm) component is blurred much more than
% the longer wavelength component of the image.  Hence, the image
% has very low amplitude ripples, and appears almost like a
% single, uniform bar.  The 570nm component, however, has high
% amplitude ripples that are quite distinct.  Hence, the
% short-wavelength variation would be very hard to detect in the
% retinal image, while the 570 nm component would be quite easy
% to detect.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Chromatic aberration in the frequency domain
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Finally, let's make a few graphs of the modulation transfer
% function of the eye's optical system for individual
% wavelengths.  For short wavelength lights, high spatial
% frequency contrast is attenuated a lot by the optical path of
% the eye.

% Load the MTFs for wavelengths from 370-730nm.  These were
% calculated using the methods in Marimont and Wandell.

load combinedOtf;

% This again loads 3 variables:
%   wave (1x361)
%   sampleSF (1x33) lists spatial frequencies from 0-32 in cyc/deg
%   combinedOtf (361x33) are the optical transfer functions at each wavelength

% Here is a graph of a few of the OTFs

figure
plot(sampleSf, combinedOtf(80, :), 'b-', ...
	sampleSf, combinedOtf(200,:), ...
	'k:', sampleSf, combinedOtf(361, :), 'r--' );
legend('wavelength 450', 'wavelength 570','wavelength 730');
xlabel('Frequency (CPD)'); ylabel('Scale factor'); grid on
title('Modulation transfer functions for 3 wavelengths');

% Notice that the amplitude of the short-wavelength becomes
% negative. This occurs because the blurring is so severe that
% the harmonic function is reproduced in the opposite phase
% compared to the input harmonic.  Hence, the amplitude is
% represented by a negative number.  This is called "spurious
% resolution."






