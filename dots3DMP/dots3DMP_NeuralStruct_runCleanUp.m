function dataStruct_clean = dots3DMP_NeuralStruct_runCleanUp(dataStruct,parSelect,minRate,minTrs)

% fprintf('Cleaning up data, resaving\n')

% parSelect - list of experimental paradigms *Unlike initial generation of
% dataStruct, this will mean only units recorded in ALL paradigms in
% parSelect will be kept.
% e.g. {'dots3DMPtuning','dots3DMP'};

% minRate - minimum global/coarse firing rate of the unit in spikes/s
% across valid trials
% minTrs - minimum number of trials per unique condition 
%       TODO - make sure minTrs works for mapping paradigms too


dataStruct_clean = dataStruct;
removeEntireSession = false(size(dataStruct));

for s = 1:length(dataStruct)
    clear parUnits numSpikes numTrials enoughTrials

    % sessions that don't have all pars in parSelect get marked for
    % removal, i.e. unit for sure was not recorded in all selected pars!
    % % but do it at the end so as not to mess up the loop counter
    if ~all(isfield(dataStruct(s).data,parSelect))
        removeEntireSession(s) = true;
        continue
    end

    for par = 1:length(parSelect)

        units  = dataStruct(s).data.(parSelect{par}).units;
        events = dataStruct(s).data.(parSelect{par}).events;

        parUnits(par,:)  = units.cluster_id;
        numSpikes(par,:) = cellfun(@length,units.spiketimes);
        numTrials(par,:) = length(events.trStart);

        if contains(parSelect{par},'dots3DMP')
            stimCondList = [events.heading; events.modality; events.coherence; events.delta]';
        end

        if par==1
            enoughTrials = nan(length(parSelect,length(units.cluster_id)));
        end

        for u = 1:length(units.cluster_id)

            if ~isempty(units.spiketimes{u})
                [~,t] = min(abs(events.trStart-units.spiketimes{u}(1)));
                if ~isempty(t), itr_start=t; end
                [~,t] = min(abs(events.trStart-units.spiketimes{u}(end)));
                if ~isempty(t), itr_end=t; end
            end

            [uStimConds,~,ic]    = unique(stimCondList(itr_start:itr_end,:),'rows');
            [nTrConds,~]         = hist(ic,unique(ic));
            enoughTrials(par,u)  = all(nTrConds>=minTrs);
        end

    end

    numTrials       = repmat(numTrials,1,size(parUnits,2));

    parSpikeRate = numSpikes ./ numTrials;

    removeThese = any(parSpikeRate<minRate | ~enoughTrials,1);

    for par = 1:length(parSelect)
        
        units  = dataStruct(s).data.(parSelect{par}).units;
        units.cluster_id(removeThese) = [];
        units.cluster_type(removeThese) = [];
        units.spiketimes(removeThese) = [];

        % overwrite
        dataStruct_clean(s).data.(parSelect{par}).units = units;
    end
end

dataStruct_clean(removeEntireSession) = [];
% dataStruct = dataStruct_clean;
% 
% file = [subject '_' num2str(dateRange(1)) '-' num2str(dateRange(end)) '_neuralData_clean.mat'];
% save([localDir(1:length(localDir)-length(subject)-7) file], 'dataStruct');