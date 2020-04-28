% offline analysis wrapper for PLDAPS data, dots3DMP paradigm
% CF started it 10-3-18

clear all; close all

conftask=1; % 1=colorbars, 2=PDW
RTtask = 1;
normalize = 0;

% % these will specify which (previously saved) mat file to load
% subject = 'human';
% paradigm = 'dots3DMP';
% dateRange = 20190612:20191231; % everything

subject = 'human';
paradigm = 'dots3DMP';
dateRange = 20200213:20200308;

folder = '/Users/chris/Documents/MATLAB/PLDAPS_data/';
file = [subject '_' num2str(dateRange(1)) '-' num2str(dateRange(end)) '.mat'];
load([folder file], 'data');

% struct data has fields:
% filename
% subj: subject code
% choice: 1=left, 2=right, nan = fixation break or otherwise invalid
% heading: angle in deg relative to straight ahead, positive = rightward
% coherence: dot motion coherence aka visual reliability
% modality: stimulus modality: 1=ves, 2=vis, 3=comb
% delta: conflict angle in deg, positive means visual right, vestib left
% correct: was the choice correct, 1 or 0
% conf: confidence rating via saccadic end-point to color-bar target
%       (or in other datasets, PDW)


%% new 04/2020: selecting 'good' data (esp RT)

% some new useful vars
for k = 1:length(data.filename)
    data.date(k,1) = str2double(data.filename{k}(9:16));
    data.subjDate{k,:} = [data.subj{k} data.filename{k}(9:16)];
end

% quick look at blocks, for when some need to be excluded
blocks = unique(data.filename);
nTrialsByBlock = nan(length(blocks),1);
for u = 1:length(blocks)
    nTrialsByBlock(u) = sum(ismember(data.filename,blocks(u)));
end

% would be nice to have a variable that indexes good data...
% for the time being we'll have to manually exclude by block or subj+date

% we can be pretty sure blocks with <N trials (say, 30) are to be discarded
removethese = ismember(data.filename,blocks(nTrialsByBlock<30));

% other manual excludes (e.g., RT training)
excludes_filename = {'humanIPQ20200227dots3DMP0904','humanVZC20200229dots3DMP1239'};
excludes_subjDate = {'FRK20200216','FRK20200223','NKT20200215','VZC20200222'};
removethese = removethese | ismember(data.filename,excludes_filename) | ismember(data.subjDate,excludes_subjDate);
fnames = fieldnames(data);
for F = 1:length(fnames)
    eval(['data.' fnames{F} '(removethese) = [];']);
end

% now this should reflect only good data, per spreadsheet:
blocks = unique(data.filename)


%% choose subjects to include based on 3-letter code

subjs = unique(data.subj); % all

% subjs = {'AAW'}; % the best single subject
% subjs = {'LLV'};
% subjs = {'IWT'};
% subjs = {'CXD'};
% subjs = {'EMF'};

% subjs = {'AAW' 'LLV' 'IWT'};
% subjs = {'AAW' 'IWT' 'CXD'};
% subjs = {'AAW' 'LLV' 'IWT' 'EMF'};
% subjs = {'AAW' 'LLV' 'IWT' 'CXD' 'EMF'};



% remove invalid trials (fixation breaks (which gives nans), excluded subj,
% and obvious testing trials, signaled by very large confidence (saccade
% endpoint) values
removethese = isnan(data.choice) | ~ismember(data.subj,subjs) | data.conf>2 | isnan(data.conf);
fnames = fieldnames(data);
for F = 1:length(fnames)
    eval(['data.' fnames{F} '(removethese) = [];']);
end


%% parse data

mods = unique(data.modality); 

% [C,IA,IC] = unique(data.coherence)
% N = hist(data.coherence,unique(data.coherence))

cohs = unique(data.coherence); 
    % currently too many cohs in the dataset, so...

N = hist(data.coherence,unique(data.coherence))'
unique(data.coherence)


% ...lump coherences together (work in progress)

% % avery
% data.coherence(data.coherence<0.2) = 0.1;
% data.coherence(data.coherence>=0.2 & data.coherence<0.6) = 0.5;
% data.coherence(data.coherence>=0.6) = 0.9;
% cohs = [0.1 0.5 0.9];

% everyone else
data.coherence(data.coherence<=0.3) = 0.1;
data.coherence(data.coherence>0.3) = 0.5;
cohs = [0.1 0.5];


% remove the rest
removethese = ~ismember(data.coherence,cohs) & data.modality~=1;
for F = 1:length(fnames)
    eval(['data.' fnames{F} '(removethese) = [];']);
end
    
% the coh assigned to vestib trials (as a placeholder) depends on which
% cohs were shown in a particular block, so we need to standardize it:
data.coherence(data.modality==1) = cohs(1);

    
deltas = unique(data.delta); % aka conflict angle
hdgs = unique(data.heading);
      % same here.  the 1.5-12 range was only used rarely, and in fact is a
      % good signature of warmup or testing-mode trials to be excluded
%     hdgs = [-10 -5 -2.5 -1.25 0 1.25 2.5 5 10]';
    % some zero values were stored as +/- eps in an older version of the gui
    data.heading(abs(data.heading)<0.01) = 0;

% remove the rest
removethese = ~ismember(data.heading,hdgs);
for F = 1:length(fnames)
    eval(['data.' fnames{F} '(removethese) = [];']);
end

%% normalize confidence ratings, *within subject*

if normalize

data_orig = data;
usubj = unique(data.subj);
for s = 1:length(usubj)
    data = data_orig;
    removethese = ~strcmp(data.subj,usubj{s});
    for F = 1:length(fnames)
        eval(['data.' fnames{F} '(removethese) = [];']);
    end    
    
    % subtract min and divide by max
    % data.conf = (data.conf - min(data.conf)) / max((data.conf - min(data.conf)));

    % OR, subtract/divide by *means*
    dots3DMP_parseData
    minOfMeans = nanmin(nanmin(nanmin(nanmin(confMean))));
    data.conf = data.conf - minOfMeans;
    dots3DMP_parseData
    maxOfMeans = nanmax(nanmax(nanmax(nanmax(confMean))));
    data.conf = data.conf / maxOfMeans;

    % OR, rectify
    % data.conf(data.conf>1) = 1;
    % data.conf(data.conf>1) = 1;

    % append each subj to a new data struct
    if s==1
        data_new = data;
    else
        for F = 1:length(fnames)
            eval(['data_new.' fnames{F} '(end+1:end+length(data.date)) = data.' fnames{F} ';']);
        end
    end
end
data = data_new;

end

    
%% after settling on the above, run this script to generate summary data

dots3DMP_parseData


%% check sample sizes for each trial type

% reminder:
% n = nan(length(mods),length(cohs),length(deltas)+1,length(hdgs));
%                                % add extra column^ for pooling all trials irrespective of delta

% could reshape the 4D array to a column vector using sort(n(:)), but need
% to know the dim ordering.

% conceptually easier (if inelegant) to create arrays of same size as N
% which jointly identify the unique trial type. Then we can reshape them
% the same way and pass in the index array from sort(n(:)) to get trial type.
for m = 1:length(mods)
for c = 1:length(cohs)
for d = 1:length(deltas)+1 % add extra column for all trials irrespective of delta
for h = 1:length(hdgs)
    Mod(m,c,d,h) = m;
    Coh(m,c,d,h) = c;
    Delta(m,c,d,h) = d;
    Hdg(m,c,d,h) = h;    
end
end
end
end
Mod = Mod(:); Coh = Coh(:); Delta = Delta(:); Hdg = Hdg(:);

[ntrSorted,ind] = sort(n(:));

% first verify that indices with zero trials are only the invalid
% combinations:
zeroInds = ind(ntrSorted==0);
conds = [Mod(zeroInds) Coh(zeroInds) Delta(zeroInds) Hdg(zeroInds)];
condsWithZeroTr = sortrows(conds,[1 3]) % this should show that all zeroInd conds
                                        % are mod 1 or 2 and delta 1 or 3
                              
% now look at the conds with fewest trials to see if something's amiss
lowInds = ind(ntrSorted>0 & ntrSorted<30);
conds = [Mod(lowInds) Coh(lowInds) Delta(lowInds) Hdg(lowInds)];
condsWithLowN = sortrows(conds,[1 2 3 4]) % a random sprinkling of low-coh tr...
                                          % double check pldaps code


%% some plots

dots3DMP_plots



%% fit cumulative gaussians

cgauss = @(b,hdg) 1/2 * ( 1 + erf( (hdg-b(1))./(b(2)*sqrt(2)) ) );
    % for probabilities, error is negative log likelihood of observing the data, which is
    % [ log(Pright(hdg)) + log(1-(~Pright(hdg))) ]
cgauss_err = @(param,choice,hdg) -(sum(log(cgauss(param,hdg(choice))))+sum(log(1-cgauss(param,hdg(~choice))))); 

flippedGauss = @(b,hdg) 1 - ( min(max(b(1),0),1) .* exp(-(hdg-b(2)).^2 ./ (2*b(3).^2)) + b(4));
    % for continuous values, error is sum squared error
flippedGauss_err = @(param,SEP,hdg) sum((flippedGauss(param,hdg)-SEP).^2);


%%

unc = 0; % saves biases from fminunc instead of fminsearch (SEs always are fminunc, and plots are always fminsearch)

dots3DMP_plots_cgauss


%%
% dots3DMP_plots_cgauss_forTalk





