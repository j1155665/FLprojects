% grabs PLDAPS data from NAS as specified, then loads desired variables
% from .PDS files into a simpler data structure

% CF, adapted from offline analysis wrapper born 10-3-18

% VERSION 2.0: 08-30-19

% requires password(s) to be entered if a auth key not available 
% see e.g.:
% https://www.howtogeek.com/66776/how-to-remotely-copy-files-over-ssh-without-entering-your-password/

clear all
close all

%% decide which files to load

paradigm = 'dots3DMP';
today = str2double(datestr(now,'yyyymmdd'));

% subject = 'lucio';
% dateRange = 20210614:20210805; % RT
% dateRange = 20210714;

subject = 'human';
% dateRange = 20190625:20191231; % non-RT
dateRange = 20200213:today; % RT

dateStr = num2str(dateRange(1));
for d = 2:length(dateRange)
    dateStr = [dateStr newline num2str(dateRange(d))];
end

localDir = ['/Users/stevenjerjian/Desktop/FetschLab/PLDAPS_data/' subject '/'];
% localDir = ['/Users/chris/Documents/MATLAB/PLDAPS_data/' subject '/'];
remoteDir = ['/var/services/homes/fetschlab/data/' subject '/'];

% localDir = ['/Users/stevenjerjian/Desktop/FetschLab/PLDAPS_data/' subject '/basic/'];
% remoteDir = ['/var/services/homes/fetschlab/data/' subject '/' subject '_basic/'];
addNexonarDataToStruct = 0; % SJ 08-2021

%% get PDS files from server -- DON'T FORGET VPN
% will skip files that already exist locally, unless overwrite set to 1

useVPN = 0;
overwriteLocalFiles = 0; % set to 1 to always use the server copy
getDataFromServer % now also includes pdsCleanup to reduce file size and complexity

%% get Nexonar files from server

if addNexonarDataToStruct
    localDir = ['/Users/stevenjerjian/Desktop/FetschLab/PLDAPS_data.nosync/' subject '/nexonar/'];
    remoteDir = ['/var/services/homes/fetschlab/data/' subject '/' subject '_nexonar/'];
    
    getDataFromServer % will skip pdsCleanup for nexonar data
    
    % rename localDirs for createDataStructure
    localDir = ['/Users/stevenjerjian/Desktop/FetschLab/PLDAPS_data/' subject '/basic/'];
    localDirNex = ['/Users/stevenjerjian/Desktop/FetschLab/PLDAPS_data/' subject '/nexonar/'];
end

%% create data structure

createDataStructure

%% optional: save data struct to a mat file so you don't have to repeat the time consuming step

if sum(diff(dateRange)>1)==0
    file = [subject '_' num2str(dateRange(1)) '-' num2str(dateRange(end)) '.mat'];
elseif sum(diff(dateRange)>1)==1
    file = [subject '_' num2str(dateRange(1)) '-' num2str(dateRange(diff(dateRange)>1)) '+' num2str(dateRange(find(diff(dateRange)>1)+1)) '-' num2str(dateRange(end)) '.mat'];
else
    warning('Multiple breaks in date range, could overwrite existing file with different intervening dates!');
    disp('Press a key to continue');
    pause
    file = [subject '_' num2str(dateRange(1)) '---' num2str(dateRange(end)) '.mat'];
end
    


try
data = rmfield(data,'dotPos'); % CAREFUL
catch
end

disp('saving...');
save([localDir(1:length(localDir)-length(subject)-1) file], 'data');

% otherwise for larger files will need: 
% save([localDir(1:length(localDir)-length(subject)-1) file], 'data','-v7.3');

disp('done.');

