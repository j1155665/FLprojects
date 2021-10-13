function [nexPDS,nexClean,exitflag] = dots3DMP_nexonarCleanUp(nex,PDS)
% cleans up nexonar data struct via cross-ref with matching PDS
% SJ 08-2021
%
% OUTPUTS:
% nexPDS - just the nexonar data, lined up with PLDAPS trials
% nexClean - cleaned-up nexonar struct
% exitflag - 0 if good, 1 if there still seem to be some corrupted trials
% in nexClean
%
% why is this helpful?
%
% on each trial, PLDAPS sends trial info (pldaps.iTrial, stim conditions),
% and later, the trial outcome info (choice, RT etc), via UDP buffer to the
% nexonar computer. this is done to make cross-referencing the two more reliabel, 
% and intended to enable nex struct to suffice for stand-alone analyses on nexonar data

% BUT...on some trials, the information for one or both of these seems to be
% copied from the previous trial, which is obviously screwing up
% conditional analyses, because the match with nex.nexdata is lost
% I guess this is because the UDP packet on a given trial is dropped, and
% the way the FLnexonar.cs code was written, it would still have the
% previous trial's info in the workspace

% another thing to be careful about - nexonar data streaming only starts at the motion state,
% so trials with early breakfixes will never be streamed to Nexonar and therefore not exist in nex, 
% but trials with breakfixes during motion or choice periods will...
% ...so also make a nexPDS struct that matches the length of PDS, which
% we can add to the data struct later


% nexClean will be the same as nex, but corrected
% nexPDS contains just the nexdata, with the same length as PDS.data
nexClean = nex;
nexPDS = cell(1,length(PDS.data));

% badOutcomeTrials = diff(nexClean.behavior.RT)==0;
badInfoTrials    = diff(nexClean.pldaps.trialSeed)==0;

badInfoTrialsIndex = find(badInfoTrials)+1;

% reassign the trial index as needed, if the next trial was a good one in
% PDS, or there are no more possible breakfixes until the next 'good Info' trial
for t=1:length(badInfoTrialsIndex)
    done=0;
    tr = nexClean.pldaps.iTrial(badInfoTrialsIndex(t))+1;
    while ~done
        if PDS.data{tr}.behavior.goodtrial || (nexClean.pldaps.iTrial(tr) == tr+1)
            nexClean.pldaps.iTrial(badInfoTrialsIndex(t)) = tr;
            done = 1;
        end
        tr = tr+1;
    end
end

for t=1:length(PDS.data)
    
    tr = nexClean.pldaps.iTrial==t;
    if any(tr)
        nexPDS{t} = nex.nexdata{tr};
    else
        nexPDS{t} = [];
    end
end

% now that iTrial in nex.pldaps is actually correct, assign condition and
% behavioral data from PDS to the relevant trial in nex
nexTrs = length(nexClean.pldaps.iTrial); 
cond_fnames  = fieldnames(nexClean.conditions);
behav_fnames = fieldnames(nexClean.behavior);

for tr=1:nexTrs
    iTrial = nexClean.pldaps.iTrial(tr);
    
    for f=1:length(cond_fnames)
        nexClean.conditions.(cond_fnames{f})(tr) = PDS.conditions{iTrial}.stimulus.(cond_fnames{f});
    end

    for f=1:length(behav_fnames) 
        if strcmp(behav_fnames{f},'conf') && isfield(PDS.data{iTrial}.behavior,'PDW')
            nexClean.behavior.(behav_fnames{f})(tr) = PDS.data{iTrial}.behavior.PDW;
        else
            nexClean.behavior.(behav_fnames{f})(tr) = PDS.data{iTrial}.behavior.(behav_fnames{f});
        end
    end
end


% sanity check
badOutcomeTrials = diff(nexClean.behavior.RT)==0;

% 0 if good, 1 if bad
exitflag = sum(badOutcomeTrials)>0;

if sum(badOutcomeTrials)>0
    disp('Something went wrong, corrupted trials still remaining')
    keyboard
end