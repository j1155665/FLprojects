%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TWO-DIMENSIONAL FILTERING and DFT TUTORIAL.
%%%   Eero Simoncelli, 6/96.  Based on OBVIUS tutorial by Simoncelli/Heeger.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Prerequisites: linSysTutorial, samplingTutorial

clear all;
close all;

%% We have provided a function called showIm that displays a matrix as an
%% image.  It can also be used to display a pair of images: if the matrix is
%% complex, it displays the real and imaginary parts side by side with the same
%% scaling.  For example, consider two 2D sinusoidal gratings of different 
%% spatial frequency.  ShowIm allows us to display these next to each other
%% (with the same scaling) by combining them as the real and imaginary parts 
%% of a complex number:
showIm((mkSine(32,8,-pi/4)) + j*(mkSine(32,16,-pi/4)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sinusoids in 2D:

%% In two dimensions, sinusoids are characterized by amplitude, phase, and a
%% frequency 2-vector:
sz = 32;
ampl = 2; ph = pi/4; freq = 2*pi*[2 5]'/sz;
im = mkSine(sz, freq, ampl, ph);
subplot(1,2,1); showIm(im);

%% As in 1D, sinusoids are the eigenfunctions of (finite-length) linear
%% shift-invariant systems.  That is, convolution of a sinusoid with any filter
%% produces a sinusoid with the same frequency vector, but possibly different
%% amplitude and phase. Consider the convolution of a random 2D array with the
%% sinusoid given above:
filt = rand(5,5)/10;
res = conv2(im,filt,'valid');
subplot(1,2,2); showIm(res);
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2D DFT:

%% The DFT in two dimensions is an ARRAY of coefficients, and thus can be
%% viewed as an image.  Each coefficient is associated with a sinusoidal basis
%% function.  As in 1D, the (complex) magnitude and angle of the coefficient
%% give the amplitude and phase of the sinusoid.  The 2D vector specifying the
%% position of the coefficient within the array corresponds to its frequency
%% vector.  The direction of the vector is normal to the orientation of
%% sinusoid.  The length gives the frequency.

%% MatLab provides the function "fft2" to compute 2D DFTs efficiently.  As in
%% 1D, matlab places the origin ([0 0] frequency) in the first (upper left)
%% sample.  But it is customary to shift the array so that the origin is in the
%% center. For example, consider the DFT of a vertically oriented sinusoid:
freq = 2*pi*[0 3]'/sz;
im = mkSine(sz, freq, 1, 0, [1 1]);
figure, showIm(im);
figure, showIm(fftshift(fft2(im)));

% What do the various transform coefficients mean?  The center sample
% of the (shifted) DFT is the dc component (i.e., the average of the
% image).  The sinusoid given above is has a DFT that is non-zero only
% at one frequency.  Futhermore, the DFT is purely imaginary, since
% the imaginary part of the DFT represents the odd-symmetric part of
% any real function.  

% If we change the phase of the sinusoid, the real part will take on
% non-zero values.  But the nonzero values of the DFT will still be
% confined to the same frequency samples.  Furthermore, the sum of
% squares of the real and imaginary parts (i.e., the complex
% magnitude) will not change.

im = mkSine(sz, freq, 1, pi/3, [1 1]);
figure(1); showIm(im);
figure(2); showIm(fftshift(fft2(im)));

% If we increase the frequency  of the sinusoid, the nonzero samples
% will move away from the origin:

im2 = mkSine(sz, 2*freq, 1, pi/3, [1 1]);
figure(1); showIm(im2);
figure(2); showIm(fftshift(fft2(im2)));

% Rotating the sinusoid will rotate the position of the nonzero
% samples.  You'll also notice that the nonzero samples are no longer
% perfectly confined to a pair of samples.  Why?
ori = pi/4;
R = [cos(ori), sin(ori); -sin(ori), cos(ori)];  %Rotation matrix
im2 = mkSine(sz, R*freq);
figure(1); showIm(im2);
figure(2); showIm(fftshift(fft2(im2)));


% Now look at the DFT of a real image:
figure(1); clf;
al = pgmRead('einstein.pgm');
subplot(1,2,1); showIm(al)
alfft = fft2(al);
almag = fftshift(abs(alfft));
subplot(1,2,2); showIm(almag,'auto2');

% Note that you don't see much.  That's because the low frequency
% components are many orders of magnitude larger than the high
% frequency components.  Often, it is useful to display the log
% of the magnitude of the DFT:

showIm(log10(almag),'auto2');

%% A 1D slice through this function can be revealing.  In particular, for many
%% images, the Fourier magnitude falls as the inverse of the frequency
%% magnitude.  On a log-log plot, this shows up as being fairly close 
%% to  a straight line with a slope of one:
figure(2); clf
loglog(abs(pi*[-128:127]), almag(129,:))
hold on; plot(10.^[0.5,3], 10.^[6,3.5], 'r'); hold off
legend('Vert Fourier amplitude', 'c/|f|')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2D DFT Examples:

% Here we synthesize a number of test images and look at their
% power spectra.  In each case, try to guess what the power
% spectrum will look like before you compute it.

sz = 64;
im = ones(sz);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkImpulse(sz);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))),[0 2]);

im = mkSine(sz,2*pi*[3 8]/sz);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkGaussian(sz,15);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkGaussian(sz,2);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkGaussian(sz,[16,2]);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

% A Gabor function is the product of a Gaussian and a sinusoid:
im = mkGaussian(sz,6) .* mkSine(sz,8);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkGaussian(sz,6) .* mkSine(sz,4);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

im = mkGaussian(sz,2) .* mkSine(sz,8);
subplot(1,2,1); showIm(im);
subplot(1,2,2); showIm(fftshift(abs(fft2(im))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2D Filtering:

% Make a pair of orientation selective filters and look at their
% orientation selective responses:

hfilt = [[-0.107 0.0 0.107]; ...
         [-0.245 0.0 0.245]; ...
	 [-0.107 0.0 0.107]];

vfilt = [[-0.107 -0.245 -0.107]; ...
         [ 0.0    0.0    0.0  ]; ...
	 [ 0.107  0.245  0.107]];

disc = mkDisc(64);
showIm(disc);
showIm(conv2(disc,hfilt) + 1i*conv2(disc,vfilt));

% Let's look at the frequency responses of these two filters:

showIm(fftshift(abs(fft2(hfilt,64,64))) + ...
    i*fftshift(abs(fft2(vfilt,64,64))));

% These two filters were designed to tile (smoothly cover) the
% set of all orientations.  The sum of their squared frequency
% responses is an annulus of spatial frequencies:

showIm(fftshift(abs(fft2(hfilt,64,64))).^2 + ...
    fftshift(abs(fft2(vfilt,64,64))).^2);

% A zone plate is an image of a radially symmetric frequency
% sweep, cos(r^2).  Zone plates are another way to look at
% orientation and frequency selectivity.

zone = mkZonePlate(64);
showIm(zone);
showIm(conv2(zone,hfilt).^2 + i*conv2(zone,vfilt).^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Separable Filters:

% A separable function is one that can be written as the product
% of two functions, each of which depends on only one variable:
%
%        f(x,y) = f1(x) f2(y)
%
% This can be implemented in MatLab via an "outer product" of two
% vectors.

% An NxN non-separable convolution requires N^2 multiplications
% for each pixel.  For separable filters, we can do the
% convolutions more efficiently.  We convolve with two
% one-dimensional filters, one of them applied to the rows and
% the other applied to the columns.  This requires only 2N
% multiplications at each pixel.  When N is large, this savings
% is significant.

% The two filters "hfilt" and "vfilt" defined above can be
% expressed as separable filters.  The two-dimensional
% convolution kernel for hfilt can be expressed as the outer
% product of two vectors:
showIm(hfilt + i*([0.233 0.534 0.233]' * [-0.459 0.0 0.459]));

% Consequently, we can do the convolutions separably:
showIm(conv2(disc,hfilt) + ...
    i*conv2(conv2(disc,[-0.459 0.0 0.459]),[0.233 0.534 0.233]'));

% This works because convolution obeys the ASSOCIATIVE property:
%      (filt1 * filt2) * image = filt1 * (filt2 * image)
% Note also that convolution is COMMUTATIVE, so it doesn't matter
% which convolution is done first.

%% Functions that are separable have separable Fourier transforms and
%% non-separable functions have non-separable transforms.

[xramp,yramp] = meshgrid([-32:31],[-32:31]);

sep_fun = yramp .* exp( yramp.^2 / (-2 * 2^2) ) ...
    * xramp .* exp( xramp.^2 / (-2 * 2^2) );
subplot(1,2,1); showIm(sep_fun);
subplot(1,2,2); showIm(fftshift(abs(fft2(sep_fun))));

non_sep_fun = (yramp + xramp) .* exp( (yramp.^2 + xramp.^2) / (-2 * 2^2) );
subplot(1,2,1); showIm(non_sep_fun);
subplot(1,2,2); showIm(fftshift(abs(fft2(non_sep_fun))));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Non-Separable Filters:

% Separable filters aren't sufficient for certain applications.
% For example, % here's a a diagonal filter:

dfilt = [-0.2139 -0.2451 0.0; 
         -0.2451 0.0 0.2451; 
	 0.0 0.2451 0.2139];
showIm(dfilt);
showIm(conv2(disc,dfilt));

% This filter cannot be written separably.  To see this, look at the
% Fourier transform:

showIm(fftshift(abs(fft2(dfilt,64,64))));

% But nonseparable filters can (always) be expressed as a linear sum
% of separable filters.  Sometimes this is particularly easy to do.
% For example, our diagonal filter is just the sum of hfilt plus
% vfilt:

new_dfilt = hfilt + vfilt;
showIm(dfilt + i*new_dfilt);
imStats(dfilt,new_dfilt)

% Since convolution is associative over addition, we can compute
% the response of dfilt by adding the responses to hfilt and
% vfilt:
showIm(conv2(disc,vfilt) + conv2(disc,hfilt));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2D Subsampling:

% Everything we've learned about 1D subsampling applies in 2D as
% well.  We can perfectly reconstruct a subsampled image as long
% as the image is appropriately (according to the Nyquist
% sampling theorem) bandlimited.

% Here's a simple example:

gaussian = mkGaussian(64,10^2);
showIm(gaussian);
showIm(fftshift(abs(fft2(gaussian))));

impulses = zeros(64); impulses(1:4:64,1:4:64) = ones(16);
showIm(impulses,'auto2');

gauss_impulses = gaussian .*  impulses;
showIm(gauss_impulses);

dft_gauss_impulses = fftshift(fft2(gauss_impulses));
showIm(fftshift(abs(dft_gauss_impulses)));

% We get replicas of the original Fourier transform when we
% multiply by an impulse train in the spatial domain.  We can
% reconstruct the original image by pulling out the correct
% replica:

box = zeros(64); box(25:41,25:41) = 16*ones(17,17); box = fftshift(box);
reconstructed_gauss = real(ifft2(box.*dft_gauss_impulses));
showIm(reconstructed_gauss);
imStats(gaussian,reconstructed_gauss)

% In MatLab, downsampling and upsampling can be done by indexing
% into matrices:

down_gauss = gaussian(1:4:64,1:4:64);
up_down_gauss = zeros(64); up_down_gauss(1:4:64,1:4:64) = down_gauss;
imStats(gauss_impulses,up_down_gauss)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Filtering and Subsampling.

% When we use a pre-filter to bandlimit an image, the filtered
% image can be subsampled without aliasing.

% First look at the dft of an image that is not band limited:
al = al(61:188,51:178);
dft_al = fft2( al);
showIm(fftshift(abs(dft_al)),[0,3000]);

% Now blur the image to produce a (more or less) band limited result:
%blur_al = cconv2sep(al,[1/16 1/4 3/8 1/4 1/16],[1/16 1/4 3/8 1/4 1/16]');
blur_al = conv2(al,[1/16 1/4 3/8 1/4 1/16],'same');
blur_al = conv2(blur_al,[1/16 1/4 3/8 1/4 1/16]','same');
dft_blur_al = fft2(blur_al);
showIm(fftshift(abs(dft_blur_al)),[0,3000]);

% Now multiply the blurred image by impulses:
impulses = zeros(128); impulses(1:2:128,1:2:128) = ones(64);
sampled_blur_al = blur_al .* impulses;
dft_sampled_blur_al = fft2(sampled_blur_al);
showIm(abs(dft_sampled_blur_al),[0,3000]);

% Notice that the replicas in the Fourier domain don't overlap
% (at least not significantly).  So we can reconstruct blur-al
% from sampled-blur-al:
box = zeros(128); box(33:97,33:97) = 4*ones(65,65); box = fftshift(box);
reconstructed_blur_al = real(ifft2(box.*dft_sampled_blur_al));
showIm(reconstructed_blur_al);
imStats(blur_al,reconstructed_blur_al)

% Now we downsample (equivalent to multiplying by the impulses and then
% throwing away the zero values in between).
sub_blur_al = blur_al(1:2:128,1:2:128);
dft_sub_blur_al = fft2(sub_blur_al);
showIm(fftshift(abs(dft_sub_blur_al)),[0,2000]);

% And reconstruct:
reconstructed_dft_blur_al = zeros(128); 
reconstructed_dft_blur_al(33:96,33:96) = 4*fftshift(dft_sub_blur_al);
reconstructed_dft_blur_al = fftshift(reconstructed_dft_blur_al);
new_reconstructed_blur_al = real(ifft2(reconstructed_dft_blur_al));
showIm(blur_al+i*new_reconstructed_blur_al);
imStats(blur_al,new_reconstructed_blur_al);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Quadrature Pairs, Local Energy, and Local Phase:

% *** Add local phase

% A quadrature pair (also called a Hilbert transform pair) is a pair
% of filters that have the same frequency response magnitude, but that
% differ by 90 degrees in phase.  The Hilbert transform is a 90 deg
% phase shift: it keeps the Fourier magnitude the same but shifts the
% phase of each frequency component by 90 degrees.  For example, the
% Hilbert transform of a cosinusoid is a sinusoid.

% Here we construct two separable filters that respond to vertical
% image features.  The y-component of each filter is the same
% low-pass.  The x-components are different from one another.  One of
% them is even symmetric (0 phase) and the other one is odd symmetric
% (90 deg phase).

low1 = [7.598E-4 0.01759 0.1660 0.6383 1.0 ...
	0.6383 0.1660 0.01759 7.5987E-4];
even1 = [-0.009356 -0.1148 -0.3964 0.06010 0.9213 ...
	0.06010 -0.3964 -0.1148 -0.009356];
odd1 = [-0.01045 -0.06578 0.1063 0.8042 0.0 ...
	-0.8042 -0.1063 0.06578 0.01045];
vert_even = low1'*even1; 
vert_odd  = low1'*odd1;
showIm(vert_even + i*vert_odd);

% These two filters are not perfect Hilbert transforms of one another
% but they are pretty close.  Plot the 1D frequency responses,
% overlaid:

subplot(1,1,1);
plot(pi*[-31:32]/64,fftshift(abs(fft(even1,64))),'--', ...
     pi*[-31:32]/64,fftshift(abs(fft(odd1,64))),'-');

% Look at the responses to a zone plate:
zone_even = conv2(zone,vert_even);
zone_odd  = conv2(zone,vert_odd);
showIm(zone_even + i*zone_odd);

% Compute the sum of the squares of the even and odd phase
% responses.  We call this an "energy mechanism", because it
% responds to the "local Fourier energy" of the image, regardless
% of the "local phase":
zone_energy = zone_even.^2 + zone_odd.^2;
showIm(zone_energy,'auto2');

% To demonstrate why these energy mechanisms are useful, let's
% consider the problem of analyzing orientation in an image.
% We'd like to measure the local orientation for each small patch
% of the image.  As simple examples, let's consider a vertical
% bar and a vertical line.

edge = zeros(64); edge(:,1:32) = ones(64,32);
line = zeros(64); line(:,32) = ones(64,1);
showIm(edge + i* line,'auto2');

% Both of these images have the same (vertical) orientation, but
% their phases are different.  We want to measure the orientation
% of these image features without having to worry about what the
% phase is.  The energy mechanism gives us a response that is
% more or less phase independent.

% Even responses:
showIm(conv2(edge,vert_even,'valid') + ...
    i* conv2(line,vert_even,'valid'));

% Odd responses:
showIm(conv2(edge,vert_odd,'valid') + ...
    i* conv2(line,vert_odd,'valid'));

% Energy responses:
edge_energy = conv2(edge,vert_even,'valid').^2 + ...
    conv2(edge,vert_odd,'valid').^2;
line_energy = conv2(line,vert_even,'valid').^2 + ...
    conv2(line,vert_odd,'valid').^2;
showIm(edge_energy + i*line_energy,'auto2');

% Vertical energy on a real image:
venergy=(conv2(al,vert_even,'valid').^2 + conv2(al,vert_odd,'valid').^2);
showIm(sqrt(venergy));

% And the horizontal energy:
hor_even = even1'*low1;
hor_odd  = odd1'*low1;
henergy=(conv2(al,hor_even,'valid').^2 + conv2(al,hor_odd,'valid').^2);
showIm(sqrt(henergy));

% Here's another way to think about it.  Consider the pair of filters,
% taken together, as a single complex valued filter.  The odd kernel
% is the imaginary part of the complex filter and the even kernel is
% the real part of the complex filter.  The impulse response of this
% complex-valued filter (for a real valued input) is a complex-valued
% image:
vert_filt = vert_even + i * vert_odd;

% The frequency response is the DFT of its impulse response:
full_filt = zeros(64,64); full_filt(29:37,29:37) = vert_filt;
vert_freq_resp = fftshift(fft2(fftshift(full_filt)));
showIm(vert_freq_resp, 'auto2');

% Note that the frequency response of the complex filter is
% real-valued (the imaginary part is essentially zero):
imStats(real(vert_freq_resp));
imStats(imag(vert_freq_resp));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Steerable Filters:

% Consider our horizontal and vertical filters again:
hresponse = conv2(disc,hfilt);
vresponse = conv2(disc,vfilt);
showIm(hresponse + i*vresponse);

% Hfilt and vfilt are separably composed of two one-dimensional
% (sampled) functions.  One of those functions is a low-pass
% filters and the other is the first derivative of that low-pass
% filter.  Thus, we can consider these filter as computing the
% derivative of an image blurred by a separable application of
% the lowpass filter.

% To take derivatives in the other directions, we can use simple
% combinations of hfilt and vfilt.  For example, the derivative
% operators for the two diagonal orientations are:
pfilt = sqrt(1/2) * (hfilt + vfilt);
qfilt = sqrt(1/2) * (hfilt - vfilt);
showIm(pfilt + i*qfilt);

% Display their frequency responses:
showIm(fftshift(abs(fft2(pfilt,64,64))) + ...
    i*fftshift(abs(fft2(qfilt,64,64))));

% And the responses of these filters for a disc image:
presponse = conv2(disc, pfilt);
qresponse = conv2(disc, qfilt);
showIm(presponse + i*qresponse);

% Here we've convolved the original image with these two new
% filters.  The two new filters are just linear sums/differences
% of hfilt and vfilt.  We actually didn't have to do these
% convolutions since we had already computed hresponse and
% vresponse (the responses to hfilt and vfilt).  The responses to
% the diagonal filters are linear sums/differences of the
% responses to hfilt and vfilt:

imStats(presponse, sqrt(1/2)*(hresponse+vresponse));
imStats(qresponse, sqrt(1/2)*(hresponse-vresponse));

% This works because convolution is distributive across addition:
%    (hfilt * image) + (vfilt * image) = (hfilt + vfilt) * image
% These first derivative filters are examples of what we call
% "steerable" filters.  We start with a pair of "basis filters"
% (hfilt and vfilt) to compute a pair of "basis images"
% (hresponse and vresponse).  Then we can get derivatives in any
% other orientation by taking a linear combination of hresponse
% and vresponse.  For example:

angle = pi/6;
aresponse = cos(angle)*vresponse + sin(angle)*hresponse;
 showIm(aresponse);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 2nd Derivative Steerable Filters:

% The "steering" property is not restricted to first derivative
% filters.  It extends to any order derivative filters.  For a
% complete theoretical treatment of steerable filters see:
% Freeman and Adelson, The design and use of steerable filters,
% IEEE Trans. on Pattern Anal. and Mach. Intelligence,
% 13:891-906, 1991.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

