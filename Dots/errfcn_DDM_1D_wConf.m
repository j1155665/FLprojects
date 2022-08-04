function [err,fit,parsedFit] = errfcn_DDM_1D_wConf(param, guess, fixed, data, options)
    
tic

global call_num

param = getParam(param, guess, fixed);

k = param(1);
B = abs(param(2)); % don't accept negative bound heights
theta = abs(param(3)); %or negative thetas
theta2 = theta; % allows expanded model with separate thetas for each choice (currently unused)
alpha = param(4); % base rate of low-conf choices
Tnd = param(5); % non-decision time (ms)

%%%% scriptified this for the time being, to standardize between sim and fit
makeLogOddsMap_1D
%%%%


% accumulate log likelihood
expectedPright = nan(size(data.scoh));
expectedPrightHigh = nan(size(data.scoh));
expectedPrightLow = nan(size(data.scoh));
expectedPhigh = nan(size(data.scoh));
expectedPhighCorr = nan(size(data.scoh));
expectedPhighErr = nan(size(data.scoh));
expectedRT = nan(size(data.scoh));
expectedRThigh = nan(size(data.scoh));
expectedRTlow = nan(size(data.scoh));
t_ms = (1:size(Ptb,1))';
pRight_model = nan(length(coh_set),1);
pHigh_model = nan(length(coh_set),1);
pHighCorr_model = nan(length(coh_set),1);
pHighErr_model = nan(length(coh_set),1);
pRightHigh_model = nan(length(coh_set),1);
pRightLow_model = nan(length(coh_set),1);
meanRT_model = nan(length(coh_set),1);
meanRThigh_model = nan(length(coh_set),1);
meanRTlow_model = nan(length(coh_set),1);
try
    n = 0;
    LL = 0;
    for c = 1 : length(coh_set)

        Ptb = Ptb_coh(:,:,c); % time * bound
        Pxt = Pxt_coh(:,:,c); % xmesh * time
        
        % calculate probabilities of the four outcomes: right/left x high/low,
        % as a function of time (dur)
        PrightHigh = cumsum(Ptb(:,2).*(bet_high_tb(:,2)==1)) + ...
                    sum(Pxt(xmesh>0,:).*(bet_high_xt(xmesh>0,:)==1),1)' + ...
                    0.5*(Pxt(xmesh==0,:).*(bet_high_xt(xmesh==0,:)==1))'; % half the probability of dv=0 (assuming a 50/50 guess when that happens)
        PrightLow = cumsum(Ptb(:,2).*(bet_high_tb(:,2)==0)) + ...
                    sum(Pxt(xmesh>0,:).*(bet_high_xt(xmesh>0,:)==0),1)' + ...
                    0.5*(Pxt(xmesh==0,:).*(bet_high_xt(xmesh==0,:)==0))';
        PleftHigh = cumsum(Ptb(:,1).*(bet_high_tb(:,1)==1)) + ...
                    sum(Pxt(xmesh<0,:).*(bet_high_xt(xmesh<0,:)==1),1)' + ...
                    0.5*(Pxt(xmesh==0,:).*(bet_high_xt(xmesh==0,:)==1))';
        PleftLow =  cumsum(Ptb(:,1).*(bet_high_tb(:,1)==0)) + ...
                    sum(Pxt(xmesh<0,:).*(bet_high_xt(xmesh<0,:)==0),1)' + ...
                    0.5*(Pxt(xmesh==0,:).*(bet_high_xt(xmesh==0,:)==0))';

        %ensure total prob sums to one
        Ptot = PrightHigh + PrightLow + PleftHigh + PleftLow;
        if any(abs(Ptot-1)>1e-3)
            warning('the probabilities do not add up to one!\n\tPtot=%f (for c= %d)\n', min(Ptot), c);
            PrightHigh = PrightHigh./Ptot;
            PrightLow = PrightLow./Ptot;
            PleftHigh = PleftHigh./Ptot;
            PleftLow = PleftLow./Ptot;
        end

        % adjust the probabilities for the base rate of low-conf bets:
        % the idea is that Phigh and Plow each get adjusted down/up in
        % proportion to how close they are to 1 or 0, respectively
        Phigh = PrightHigh + PleftHigh;
        Phigh_wAlpha = Phigh - alpha*Phigh;

        % now recover the corresponding right/left proportions;
        % these will only be used for pHigh conditioned on correct/error
        PrightHigh_wAlpha = (PrightHigh./Phigh) .* Phigh_wAlpha;
        PleftHigh_wAlpha = (PleftHigh./Phigh) .* Phigh_wAlpha;
        
        % calculate expected p(right) and P(high), given the durs
        I = data.scoh==coh_set(c);
        dur = data.dur(I);
        expectedPright(I) = (PrightHigh(dur) + PrightLow(dur)) ./ (PrightHigh(dur) + PrightLow(dur) + PleftHigh(dur) + PleftLow(dur));
            pRight_model(c) = mean(expectedPright(I)); % taking the mean feels wrong here.. (shouldn't matter for RT, where dur is always max_dur)
                               % ****** %
        expectedPhigh(I) = Phigh_wAlpha(dur) ./ (PrightHigh(dur) + PrightLow(dur) + PleftHigh(dur) + PleftLow(dur)); % only this one should take alpha into account!
                               % ****** %
            pHigh_model(c) = mean(expectedPhigh(I));
        expectedPrightHigh(I) = PrightHigh(dur) ./ (PrightHigh(dur) + PleftHigh(dur)); % NOT simply PrightHigh as a quaternary outcome, because it's Pright *conditioned* on high
            pRightHigh_model(c) = mean(expectedPrightHigh(I));
        expectedPrightLow(I) = PrightLow(dur) ./ (PrightLow(dur) + PleftLow(dur));
            pRightLow_model(c) = mean(expectedPrightLow(I));
                        
        % pHigh conditioned on correct/error; uses the 'withAlpha' versions in the numerator
        if coh_set(c)>=0 % rightward motion
            expectedPhighCorr(I) = PrightHigh_wAlpha(dur) ./ (PrightHigh(dur) + PrightLow(dur));
            expectedPhighErr(I) = PleftHigh_wAlpha(dur) ./ (PleftHigh(dur) + PleftLow(dur));
        else % leftward motion
            expectedPhighCorr(I) = PleftHigh_wAlpha(dur) ./ (PleftHigh(dur) + PleftLow(dur));
            expectedPhighErr(I) = PrightHigh_wAlpha(dur) ./ (PrightHigh(dur) + PrightLow(dur));
        end            
        pHighCorr_model(c) = mean(expectedPhighCorr(I));
        pHighErr_model(c) = mean(expectedPhighErr(I));

        
        % compute mean RT (not currently used for fitting; effectively this
        % is a fit-then-predict strategy for RT tasks)
        dI = double(coh_set(c)>=0)+1; % index for this dir (L=1, R=2)
        tHi = 1:TBint(dI)-1; % time range over which bound crossing leads to high bet
        tLo = TBint(dI):size(Ptb,1); % time range over which bound crossing leads to low bet
        % TBint is 'theta-bound intersection', see makeLogOddsMap_1D

        % compute weighted average: P(hit) * <P(RT|hit)> + P(~hit) * <P(RT|~hit)> (the latter is simply maxdur)
        Phit = sum(sum(Ptb));
        Pnohit = 1-Phit;
        RThit = sum((Ptb(:,1)+Ptb(:,2)) .* t_ms) / Phit;
        RTnohit = max_dur;
        RT_weightedAvg = Phit*RThit + Pnohit*RTnohit;
        expectedRT(I) = RT_weightedAvg/1000 + Tnd; % change to s and add Tnd
            meanRT_model(c) = mean(expectedRT(I));

        % repeat for high and low bets
        Phit_high = sum(Ptb(tHi,1)+Ptb(tHi,2));
        Pnohit_high = sum(Pxt(xmesh>0,end).*(bet_high_xt(xmesh>0,end)==1),1) + sum(Pxt(xmesh<0,end).*(bet_high_xt(xmesh<0,end)==1),1); % the portion of PRightHigh and PLeftHigh within the bounds
        RThit_high = sum((Ptb(tHi,1)+Ptb(tHi,2)) .* t_ms(tHi)) / Phit_high;
        RTnohit_high = max_dur; 
        RT_weightedAvg_high = (Phit_high*RThit_high + Pnohit_high*RTnohit_high) / (Phit_high + Pnohit_high); % this time, weighted avg is normalized by total P(High), which is of course not 1
        expectedRThigh(I) = RT_weightedAvg_high/1000 + Tnd; % change to s and add Tnd
            meanRThigh_model(c) = mean(expectedRThigh(I));

        Phit_low = sum(Ptb(tLo,1)+Ptb(tLo,2));
        Pnohit_low = sum(Pxt(xmesh>0,end).*(bet_high_xt(xmesh>0,end)==0),1) + sum(Pxt(xmesh<0,end).*(bet_high_xt(xmesh<0,end)==0),1); % the portion of PRightLow and PLeftLow within the bounds
        RThit_low = sum((Ptb(tLo,1)+Ptb(tLo,2)) .* t_ms(tLo)) / Phit_low;
        RTnohit_low = max_dur;
        RT_weightedAvg_low = (Phit_low*RThit_low + Pnohit_low*RTnohit_low) / (Phit_low + Pnohit_low); % this time, weighted avg is normalized by total P(Low), which is of course not 1
        expectedRTlow(I) = RT_weightedAvg_low/1000 + Tnd; % change to s and add Tnd
            meanRTlow_model(c) = mean(expectedRTlow(I));
            
        % update log-likelihood
        % *this is incomplete, as it only takes into account p(right),
        % conditioned on pdw, and (I think) treats each of the four
        % outcomes as binomially distributed instead of a single
        % multinomial
        % **it also does not take into account RT, but that's okay for this
        % model
        
        dur_rightHigh = data.dur(I & data.choice==1 & data.PDW_preAlpha==1);
        dur_rightLow = data.dur(I & data.choice==1 & data.PDW_preAlpha==0);
        dur_leftHigh = data.dur(I & data.choice==0 & data.PDW_preAlpha==1);
        dur_leftLow = data.dur(I & data.choice==0 & data.PDW_preAlpha==0);
        minP = 1e-300;
        LL = LL + sum(log(max(PrightHigh(dur_rightHigh),minP))) + sum(log(max(PrightLow(dur_rightLow),minP))) + ...
                  sum(log(max(PleftHigh(dur_leftHigh),minP)))   + sum(log(max(PleftLow(dur_leftLow),minP)));
        n = n + length(dur_rightHigh) + length(dur_rightLow) + length(dur_leftHigh) + length(dur_leftLow);
    end
    
    % copy trial params to data struct 'fit', then replace data with model vals
    fit = data;
    fit = rmfield(fit,'choice');
    try fit = rmfield(fit,'correct'); end %#ok<TRYNC>
    fit.pRight = expectedPright;
    if options.conftask==1 % SEP
        keyboard % not ready
    %     fit.conf = conf_model_trialwise;
    %     fit.PDW = nan(size(fit.conf));
    elseif options.conftask==2 % PDW
        fit.conf = expectedPhigh;
        fit.PDW = expectedPhigh; % legacy
        fit.pRightHigh = expectedPrightHigh;
        fit.pRightLow = expectedPrightLow;
    end
    if options.RTtask            
        fit.RT = expectedRT;
        fit.RThigh = expectedRThigh;
        fit.RTlow = expectedRThigh;
    end
    
    % also stored the 'parsed' values, for later plotting
    parsedFit = struct();
    parsedFit.pRight = pRight_model;
    if options.conftask==1 % SEP
        keyboard % not ready
%         parsedFit.confMean = meanConf_model;
    elseif options.conftask==2 % PDW
        parsedFit.pHigh = pHigh_model;        
        parsedFit.pHighCorr = pHighCorr_model;
        parsedFit.pHighErr = pHighErr_model;
        parsedFit.pRightHigh = pRightHigh_model;
        parsedFit.pRightLow = pRightLow_model;
    end
    if options.RTtask
        parsedFit.RTmean = meanRT_model;
        parsedFit.RTmeanHigh = meanRThigh_model;
        parsedFit.RTmeanLow = meanRTlow_model; 
    end

catch Error
    fprintf('\n\nERROR!!!\n'); fprintf('run %d\n', call_num);
    fprintf('\tk= %g\n\tB= %g\n\ttheta= %g\n\talpha= %g\n', k, B, theta, alpha);
    fprintf('c= %d\n', c);
    for i = 1 : length(Error.stack)
        fprintf('entry %d of error stack\n', i);
        fprintf('\tfile: %s\n', Error.stack(i).file);
        fprintf('\tfunction: %s\n', Error.stack(i).name);
        fprintf('\tline: %d\n', Error.stack(i).line);
    end
    rethrow(Error);
end

err = -LL;
%     fit = data; % fit isn't needed here, but keep for consistency w 2D

%print progress report
if options.feedback
    fprintf('\n\n\n****************************************\n');
    fprintf('run %d\n', call_num);
    fprintf('\tk= %g\n\tB= %g\n\ttheta= %g\n\talpha= %g\n', k, B, theta, alpha);
    fprintf('err: %f\n', err);
    fprintf('number of processed trials: %d\n', n);
end

if options.feedback==2 && strcmp(options.fitMethod,'fms')
    figure(options.fh);
    plot(call_num, err, '.','MarkerSize',14);
    drawnow;
end
call_num = call_num + 1;
toc

    
end



% retrieve the full parameter set given the adjustable and fixed parameters 
function param2 = getParam(param1, guess, fixed)
  param2(fixed==0) = param1(fixed==0);       %get adjustable parameters from param1
  param2(fixed==1) = guess(fixed==1);   %get fixed parameters from guess
end

