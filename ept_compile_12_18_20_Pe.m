%measures the amplitude data using adaptive mean 
clear individ master 

%directory where .ept files are located
wrkdir = '/Users/peterclayson/Desktop/forPeter';

%directory and name of spreadsheet (use .xlsx... I don't think macs can 
%save in .xlsx format so you may have to try a different one. try .csv)
savefile = '/Users/peterclayson/Desktop/test.csv';

%specify polarity of ERP component
pol = 1; %(1 = positive component, -1 = negative component)

baseline = 50; %in samples
samp.min = baseline + 100; %in samples (minimum window to use for adaptive mean)
samp.max = baseline + 150; %in samples (maximum window to use for adaptive mean)

%length of one shoulder of the adpative mean 
sizeadpmean = 4; %in samples


%%%%%%%%%%%%%%%%%%%%%%%%%%
%move to working directory
cd(wrkdir);

%load ept file paths and names
rawfilesloc = dir([wrkdir '/*.ept']); 
nSub = length(rawfilesloc);
files = struct2cell(rawfilesloc)';
files = files(:,1);

started = 0;
contcount = 0;
sczcount = 0;

%create global variables for use in ep_averageData function
global EPmain EPtictoc
EPmain.scrsz = [1 1 1680 1050];
EPmain.fontsize = 8;
EPmain.preferences.general.SMIsuffix = '_smi.txt';
EPmain.preferences.general.specSuffix = '_evt.txt';
EPmain.preferences.general.subjectSpecSuffix = '_sub.txt';
inputFormat = 'ep_mat';
averagingMethod = 'Average';
fileType = 'single_trial';
EPmain.preferences.average.trimLevel = 0;
EPmain.preferences.general.BVheader = [];
EPmain.preferences.general.noInternal = 0;
EPmain.average.dropBad = 0;
methodName = 'Mean';
smoothing = 0;
latencyName = [];
latencyMin = [];
latencyMax = [];
jitterChan = [];
jitterPolar = 1;
multiSessionSubject = [];
EPtictoc.start=[];
EPtictoc.step=1;
EPtictoc.stop=0;

for i = 1:nSub
    fileloc = fullfile(wrkdir,char(files(i)));
    
    %load ep dataset
    EPdata = ep_readData('file',fileloc,'format','ep_mat');
    
    %necessary to create a global variable for the ep_averageData function
    warning('off','MATLAB:colon:nonIntegerIndex');
    %     EPtmplt = ep_averageData({fileloc},inputFormat,fileType,...
    %         averagingMethod,trimLevel,methodName,smoothing,...
    %         latencyName,latencyMin,latencyMax,jitterChan,...
    %         jitterPolar,multiSessionSubject);
    EPtmplt=ep_averageData({fileloc},inputFormat,fileType,...
        averagingMethod,EPmain.preferences.average.trimLevel,...
        methodName,smoothing,[],[],[],'subject',[],3,0);
    warning('on','MATLAB:colon:nonIntegerIndex');
    

    
    %calculate noise estimate
    noiseestimates = sqrt(squeeze(mean(mean(mean(EPtmplt.noise.^2,1),2),5)))';
    
    subjid = char(files(i));
    
    %cycle through each trial
    for j = 1:length(EPdata.cellNames)
        
        event = EPdata.cellNames(j);
        
        if pol == 1
           
            %extract most positive peak latency for the given channel 
            %and time window
            [peakamp54, peaklat54] = max(EPdata.data(54, ...
                samp.min:samp.max, j)); 
            [peakamp55, peaklat55] = max(EPdata.data(55, ...
                samp.min:samp.max, j));
            [peakamp61, peaklat61] = max(EPdata.data(61, ...
                samp.min:samp.max, j));
            [peakamp62, peaklat62] = max(EPdata.data(62, ...
                samp.min:samp.max, j));
             [peakamp78, peaklat78] = max(EPdata.data(78, ...
                samp.min:samp.max, j));
            [peakamp79, peaklat79] = max(EPdata.data(79, ...
                samp.min:samp.max, j));

            peakamp = mean([peakamp54 peakamp55 peakamp61 peakamp62 peakamp78 peakamp79]);
            peaklat = mean([peaklat54 peaklat55 peaklat61 peaklat62 peaklat78 peaklat79]);
            
            %extract amplitude measurement from around peak latency
            adpmean54 = mean(EPdata.data(54, (samp.min+peaklat54- ...
                sizeadpmean):(samp.min+peaklat54+sizeadpmean), j));
            adpmean55 = mean(EPdata.data(55, (samp.min+peaklat55- ...
                sizeadpmean):(samp.min+peaklat7+sizeadpmean), j));
            adpmean61 = mean(EPdata.data(61, (samp.min+peaklat61- ...
                sizeadpmean):(samp.min+peaklat61+sizeadpmean), j));
            adpmean62 = mean(EPdata.data(62, (samp.min+peaklat62- ...
                sizeadpmean):(samp.min+peaklat62+sizeadpmean), j));
            adpmean78 = mean(EPdata.data(78, (samp.min+peaklat78- ...
                sizeadpmean):(samp.min+peaklat78+sizeadpmean), j));
            adpmean79 = mean(EPdata.data(79, (samp.min+peaklat79- ...
                sizeadpmean):(samp.min+peaklat79+sizeadpmean), j));
            
            adpmean = mean([adpmean54 adpmean55 adpmean61 adpmean62 adpmean78 adpmean79]);
            
        elseif pol == -1
            
           % took everything out since Pe will not be a negative component.
               
        end
        
        meanamp54 = mean(EPdata.data(54, (samp.min):(samp.max), j));
        meanamp55 = mean(EPdata.data(55, (samp.min):(samp.max), j));
        meanamp61 = mean(EPdata.data(61, (samp.min):(samp.max), j));
        meanamp62 = mean(EPdata.data(62, (samp.min):(samp.max), j));
        meanamp78 = mean(EPdata.data(78, (samp.min):(samp.max), j));
        meanamp79 = mean(EPdata.data(79, (samp.min):(samp.max), j));
        
        meanamp = mean([meanamp54 meanamp55 meanamp61 meanamp62 meanamp78 meanamp79]);
        
        %don't store data from the trial if the toolkit marked it as bad
        if EPdata.analysis.badTrials(j) == 0
            if started == 0
                master = table();
                master.subjid = cellstr(subjid);
                master.event = cellstr(event);
                master.adpmean = adpmean;
                master.peaklat = peaklat+samp.min;
                master.peakamp = peakamp;
                master.meanamp = meanamp;
                master.noise = noiseestimates;

                started = 1;
            else
                clear individ
                individ = table();
                individ.subjid = cellstr(subjid);
                individ.event = cellstr(event);
                individ.adpmean = adpmean;
                individ.peaklat = peaklat+samp.min;
                individ.peakamp = peakamp;
                individ.meanamp = meanamp;
                individ.noise = noiseestimates;

                master = vertcat(master,individ); %#ok<AGROW>

            end
        end
        
    end
end

writetable(master,savefile);
