%measures the amplitude data using adaptive mean 
clear individ master 

%directory where .ept files are located
wrkdir = '/Users/peterclayson/Desktop/forPeter';

%directory and name of spreadsheet (use .xlsx... I don't think macs can 
%save in .xlsx format so you may have to try a different one. try .csv)
savefile = '/Users/peterclayson/Desktop/test.csv';

%specify polarity of ERP component
pol = -1; %(1 = positive component, -1 = negative component)

baseline = 50; %in samples
samp.min = baseline + 50; %in samples (minimum window to use for adaptive mean)
samp.max = baseline + 100; %in samples (maximum window to use for adaptive mean)

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
            [peakamp6, peaklat6] = max(EPdata.data(6, ...
                samp.min:samp.max, j)); 
            [peakamp7, peaklat7] = max(EPdata.data(7, ...
                samp.min:samp.max, j));
            [peakamp106, peaklat106] = max(EPdata.data(106, ...
                samp.min:samp.max, j));
            [peakamp129, peaklat129] = max(EPdata.data(129, ...
                samp.min:samp.max, j));

            peakamp = mean([peakamp6 peakamp7 peakamp106 peakamp129]);
            peaklat = mean([peaklat6 peaklat7 peaklat106 peaklat129]);
            
            %extract amplitude measurement from around peak latency
            adpmean6 = mean(EPdata.data(6, (samp.min+peaklat6- ...
                sizeadpmean):(samp.min+peaklat6+sizeadpmean), j));
            adpmean7 = mean(EPdata.data(7, (samp.min+peaklat7- ...
                sizeadpmean):(samp.min+peaklat7+sizeadpmean), j));
            adpmean106 = mean(EPdata.data(106, (samp.min+peaklat106- ...
                sizeadpmean):(samp.min+peaklat106+sizeadpmean), j));
            adpmean129 = mean(EPdata.data(129, (samp.min+peaklat129- ...
                sizeadpmean):(samp.min+peaklat129+sizeadpmean), j));
            
            adpmean = mean([adpmean6 adpmean7 adpmean106 adpmean129]);
            
        elseif pol == -1
            
            %extract most positive peak latency for the given channel 
            %and time window
            [peakamp6, peaklat6] = min(EPdata.data(6, ...
                samp.min:samp.max, j)); 
            [peakamp7, peaklat7] = min(EPdata.data(7, ...
                samp.min:samp.max, j));
            [peakamp106, peaklat106] = min(EPdata.data(106, ...
                samp.min:samp.max, j));
            [peakamp129, peaklat129] = min(EPdata.data(129, ...
                samp.min:samp.max, j));

            peakamp = mean([peakamp6 peakamp7 peakamp106 peakamp129]);
            peaklat = mean([peaklat6 peaklat7 peaklat106 peaklat129]);
            
            %extract amplitude measurement from around peak latency
            adpmean6 = mean(EPdata.data(6, (samp.min+peaklat6- ...
                sizeadpmean):(samp.min+peaklat6+sizeadpmean), j));
            adpmean7 = mean(EPdata.data(7, (samp.min+peaklat7- ...
                sizeadpmean):(samp.min+peaklat7+sizeadpmean), j));
            adpmean106 = mean(EPdata.data(106, (samp.min+peaklat106- ...
                sizeadpmean):(samp.min+peaklat106+sizeadpmean), j));
            adpmean129 = mean(EPdata.data(129, (samp.min+peaklat129- ...
                sizeadpmean):(samp.min+peaklat129+sizeadpmean), j));
            
            adpmean = mean([adpmean6 adpmean7 adpmean106 adpmean129]);
        end
        
        meanamp6 = mean(EPdata.data(6, (samp.min):(samp.max), j));
        meanamp7 = mean(EPdata.data(7, (samp.min):(samp.max), j));
        meanamp106 = mean(EPdata.data(106, (samp.min):(samp.max), j));
        meanamp129 = mean(EPdata.data(129, (samp.min):(samp.max), j));
        
        meanamp = mean([meanamp6 meanamp7 meanamp106 meanamp129]);
        
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
