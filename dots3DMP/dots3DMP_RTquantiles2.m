function dots3DMP_RTquantiles2(data,conftask,plotOption)

if conftask==0, error('Need confidence task to make this figure worthwhile'); end
if nargin<3, plotOption = 2; end

% 2 figures, each with 3x2 config (all mods, ves, visLo, visHigh, combLo,
% combHigh)

% plotOption == 0 - plot errors/low bet only
% plotOption == 1 - plot correct/high bet only
% plotOption == 2 - plot correct/error or high/low bet separately
% plotOption == -1 - plot all trials

% 1 - P(High Bet) as function of RT quantiles
  
% loop over 'conditions' indexed as [modality coherence], with the
% familiar manual kluge necessary to avoid invalid combinations:
ucoh = unique(data.coherence);
ucond = [1 ucoh(1); 2 ucoh(1); 2 ucoh(2); 3 ucoh(1); 3 ucoh(2)];
titles = {'Ves';'Vis-lo';'Vis-hi';'Comb-lo';'Comb-hi';'All'};

nbins = 5; % number of bins for RT
uhdg  = unique(abs(data.heading));

if conftask==1
    confdata = data.conf>=median(data.conf);
    disp('doing a gross median conf split for now...')
    errfun   = @(x,n) std(x) / sqrt(n);
    
elseif conftask==2
    confdata = data.PDW;
    errfun   = @(x,n) sqrt( (x.*(1-x)) ./ n);
end

xRange = prctile(data.RT,[0.5 99]);
% xRange = [min(data.RT) max(data.RT)];

for c = 1:size(ucond,1)+1 % the extra one is for all conditions pooled
    
 
    for h = 1:length(uhdg)
        if c==size(ucond,1)+1
            I = abs(data.heading)==uhdg(h);
        else
            I = abs(data.heading)==uhdg(h) & data.modality==ucond(c,1) & data.coherence==ucond(c,2);
        end
        
        if plotOption==-1
            theseRT = data.RT(I);
            theseConf = confdata(I);
            theseCorr = data.correct(I);
            
            rtQ = [0 quantile(theseRT,nbins-1) inf]; 
            for q = 1:length(rtQ)-1
                J = theseRT>=rtQ(q) & theseRT<rtQ(q+1);
                X(c,h,q) = mean(theseRT(J));
                Y(c,h,q) = mean(theseConf(J));
                Yc(c,h,q) = mean(theseCorr(J));
                
                Ye(c,h,q) = errfun(Y(c,h,q),sum(J));
                Yce(c,h,q) = errfun(Yc(c,h,q),sum(J));
            end

        else
            
            % RTs for correct and error trials under each condition
            corrRT   = data.RT(I & (data.correct | data.heading==0));
            errRT    = data.RT(I & (~data.correct | data.heading==0));
            
            % RTs for high and low bets under each condition
            highRT   = data.RT(I & confdata==1);
            lowRT    = data.RT(I & confdata==0);
            
            % PDW for correct and error under each condition
            corrConf = data.PDW(I & (data.correct | data.heading==0));
            errConf  = data.PDW(I & (~data.correct | data.heading==0));
            
            % accuracy for high and low bets under each condition
            highCorr  = data.correct(I & confdata==1);
            lowCorr   = data.correct(I & confdata==0);
            
            rtQ_corr  = [0 quantile(corrRT,nbins-1) inf];
            rtQ_err   = [0 quantile(errRT,nbins-1) inf];
            rtQ_high  = [0 quantile(highRT,nbins-1) inf];
            rtQ_low   = [0 quantile(lowRT,nbins-1) inf];
            
            for q = 1:length(rtQ_corr)-1
                J = corrRT>=rtQ_corr(q) & corrRT<rtQ_corr(q+1);
                X(c,h,q,1) = mean(corrRT(J));
                Y(c,h,q,1) = mean(corrConf(J));
                Ye(c,h,q,1) = errfun(Y(c,h,q,1),sum(J));
                
                J = errRT>=rtQ_err(q) & errRT<rtQ_err(q+1);
                X(c,h,q,2) = mean(errRT(J));
                Y(c,h,q,2) = mean(errConf(J));
                Ye(c,h,q,2) = errfun(Y(c,h,q,2),sum(J));

                J = highRT>=rtQ_high(q) & highRT<rtQ_high(q+1);
                Xc(c,h,q,1) = mean(highRT(J));
                Yc(c,h,q,1) = mean(highCorr(J));
                Yce(c,h,q,1) = errfun(Yc(c,h,q,1),sum(J));

                J = lowRT>=rtQ_low(q) & lowRT<rtQ_low(q+1);
                Xc(c,h,q,2) = mean(lowRT(J));
                Yc(c,h,q,2) = mean(lowCorr(J));
                Yce(c,h,q,2) = errfun(Yc(c,h,q,2),sum(J));

            end
            
            
        end
        
    end
end

if plotOption==2
    Ye = zeros(size(Ye));
    Yce = zeros(size(Yce));
end
                    
    
%% plotting


subplotInd = [2 3 4 5 6 1];
mcols = {'Greys','Reds','Reds','Blues','Blues','Purples'};
fsz = 16;

figure(16);
set(gcf,'Color',[1 1 1],'Position',[200 200 270*2 170*3],'PaperPositionMode','auto');

for c = 1:size(ucond,1)+1 % the extra one is for all conditions pooled
    
    cmap = flipud(cbrewer('seq',mcols{c},length(uhdg)*2));
    cmap = cmap(end-1:-2:1,:);
    subplot(3,2,subplotInd(c));
    
    clear g L
    for h = 1:length(uhdg)      
        
        if plotOption==-1 % plot all trials
            g(h) = errorbar(squeeze(X(c,h,:)),squeeze(Y(c,h,:)),squeeze(Ye(c,h,:)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        elseif plotOption==0 % plot error trials only
            if h<=3
                g(h) = errorbar(squeeze(X(c,h,:,2)),squeeze(Y(c,h,:,2)),squeeze(Ye(c,h,:,2)),'color',cmap(h,:),'LineWidth', 2,...
                    'LineStyle','--','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
            end
        elseif plotOption==1 % plot correct trials only
            g(h) = errorbar(squeeze(X(c,h,:,1)),squeeze(Y(c,h,:,1)),squeeze(Ye(c,h,:,1)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o', 'MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        else % plot correct and errors, separately
            if h<=3 % 
                g(h) = errorbar(squeeze(X(c,h,:,2)),squeeze(Y(c,h,:,2)),squeeze(Ye(c,h,:,2)),'color',cmap(h,:),'LineWidth', 2,...
                    'LineStyle','--','Marker','o','MarkerSize',6,'MarkerFaceColor','w'); hold on;
            end
            k(h) = errorbar(squeeze(X(c,h,:,1)),squeeze(Y(c,h,:,1)),squeeze(Ye(c,h,:,1)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        end
        xlim(xRange);
        ylim([0.3 1])
    end
    if c<size(ucond,1)+1
        if ucond(c,1)==3,xlabel('RT (s)');
        else, set(gca,'xticklabel',[]);
        end
        if ucond(c,1)==2 && ucond(c,2)==ucoh(1)
            if conftask==1, ylabel('Sacc EP'); else, ylabel('P(High Bet)'); end
        end
    else
        set(gca,'xticklabel',[]);
    end
    if mod(c,2)==1
        set(gca,'yticklabel',[]);
    end
    changeAxesFontSize(gca,fsz,fsz); tidyaxes(gca,fsz); set(gca,'box','off');
    set(gca,'ytick',0:0.25:1,'yticklabel',{'0','','.5','','1'});
    title(titles{c});
end
sh=suptitle('Confidence-RT'); set(sh,'fontsize',fsz,'fontweight','bold');

%%
figure(17);
set(gcf,'Color',[1 1 1],'Position',[200 200 270*2 170*3],'PaperPositionMode','auto');

for c = 1:size(ucond,1)+1 % the extra one is for all conditions pooled
    
    cmap = flipud(cbrewer('seq',mcols{c},length(uhdg)*2));
    cmap = cmap(end-1:-2:1,:);
    subplot(3,2,subplotInd(c));
    
    clear g L
    for h = 1:length(uhdg)      
        
        if plotOption==-1
            g(h) = errorbar(squeeze(Xc(c,h,:)),squeeze(Yc(c,h,:)),squeeze(Yce(c,h,:)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        elseif plotOption==0 
            if h<=3
                g(h) = errorbar(squeeze(Xc(c,h,:,2)),squeeze(Yc(c,h,:,2)),squeeze(Yce(c,h,:,2)),'color',cmap(h,:),'LineWidth', 2,...
                    'LineStyle','--','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
            end
        elseif plotOption==1
            g(h) = errorbar(squeeze(Xc(c,h,:,1)),squeeze(Yc(c,h,:,1)),squeeze(Yce(c,h,:,1)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o', 'MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        else
            if h<=3
                g(h) = errorbar(squeeze(Xc(c,h,:,2)),squeeze(Yc(c,h,:,2)),squeeze(Yce(c,h,:,2)),'color',cmap(h,:),'LineWidth', 2,...
                    'LineStyle','--','Marker','o','MarkerSize',6,'MarkerFaceColor','w'); hold on;
            end
            k(h) = errorbar(squeeze(Xc(c,h,:,1)),squeeze(Yc(c,h,:,1)),squeeze(Yce(c,h,:,1)),'color',cmap(h,:),'LineWidth', 2,...
                'LineStyle','-','Marker','o','MarkerSize',6,'MarkerFaceColor',cmap(h,:)); hold on;
        end
        xlim(xRange);
        ylim([0.2 1])
    end
    if c<size(ucond,1)+1 
        if ucond(c,1)==3,xlabel('RT (s)');
        else, set(gca,'xticklabel',[]);
        end
        if ucond(c,1)==2 && ucond(c,2)==ucoh(1)
            ylabel('Accuracy')
        end
    else
        set(gca,'xticklabel',[]);
    end
    if mod(c,2)==1
        set(gca,'yticklabel',[]);
    end
    changeAxesFontSize(gca,fsz,fsz); tidyaxes(gca,fsz); set(gca,'box','off');
    set(gca,'ytick',0:0.25:1,'yticklabel',{'0','','.5','','1'});
    title(titles{c});
end
sh=suptitle('Accuracy-RT'); set(sh,'fontsize',fsz,'fontweight','bold');
 