%% Batch script for SynapseQuantAnalysis
% 

% get the directory to quantification results
basepath = uigetdir('select animal folder');
[filepath, mouseID, ~] = fileparts(basepath);
respath = [basepath, filesep, '_results'];
if ~exist(respath, 'dir')
    mkdir(respath);
end

% check if aggData.mat exists in directory, if yes load it to workspace
if exist([respath filesep,'aggData.mat'],'file')
    aggData = load([respath filesep,'aggData.mat']);
    r = size(aggData.raw,2);
    d = r+1; % where to start filling the matrix
else 
    d = 1;
end

spinalLevels = dir(basepath);


for sp = 3:(size(spinalLevels,1))
    spinalpath = [basepath filesep spinalLevels(sp).name];
    
    sliceNames = dir(spinalpath);
    
    for sl = 3:(size(sliceNames,1))
        slicepath = [spinalpath filesep sliceNames(sl).name];
        
        if ~exist([slicepath filesep '__ObjectData.csv'], 'dir') 
            warning(['No quantification data, skipping ', slicepath])
            continue
        elseif ~exist([slicepath filesep '__outline_overlay_c1.zip'], 'dir')
            warning(['No image data, skipping ', slicepath])
            continue
        end
        
        % assign variables to be used in SynapseQuantAnalysis
        quantResCsv = dir([slicepath filesep '__ObjectData.csv']);
        csvData = readtable([slicepath filesep '__ObjectData.csv' filesep quantResCsv(3).name]);
        
        quantResImg = dir([slicepath filesep '__outline_overlay_c1.zip']);
        quantResImg = {quantResImg.name};
        zipIx = find(contains(quantResImg, 'zip'));
        imgName = unzip([slicepath filesep '__outline_overlay_c1.zip' filesep quantResImg{zipIx}], ...
            [slicepath filesep '__outline_overlay_c1.zip']);
        pic = Tiff(string(imgName));
        imgData = read(pic);
        [numRows, numCols] = size(imgData);
         
        % bin data and create array containing raw histogram data 
        x = table2array(csvData(:,5));
        y = table2array(csvData(:,6)); 
        numBins = ceil(sqrt(numCols));
        ptsx = linspace(0,numCols,numBins);
        N = histcounts2(y(:), x(:), ptsx, ptsx); % raw binned data
        
        aggData(d).raw = N;
        aggData(d).x = x;
        aggData(d).y = y;
        aggData(d).imgsize = [numRows numCols];
        aggData(d).ptsx = ptsx;
        aggData(d).slicename = sliceNames(sl).name;
        aggData(d).spinallevel = spinalLevels(sp).name;
        aggData(d).mouseID = mouseID;
        
        rawDataAgg.raw{d} = N;
        
        d = d+1;  % index for new data
        
    end
 
end

% get the directory to save results in correct folder
resultsFolder = uigetdir(matlabroot, 'select resuts folder');
save ([resultsFolder filesep mouseID 'aggData'], 'aggData'); %save aggregated data as .mat file
save ([resultsFolder filesep mouseID 'rawDataAgg'], 'rawDataAgg'); %save raw aggregated data in format for normalization as .mat file
%% normalization

% find min and max value in all raw data
minNum = 0;
for m = 1: size(rawDataAgg.raw,2)
    maxM(m) = max(rawDataAgg.raw{m}(:));
end
maxNum = max(maxM);

% check if normData.mat exists in directory, if yes load it to workspace
if exist([respath filesep,'normData.mat'],'file')
    normData = load([respath filesep,'normData.mat']);
    rR = size(normData.raw,2);
    dD = rR+1; % where to start filling the matrix
else 
    dD = 1;
end

% do the normalization, if aggData.mat exists, redo normalization
for n = 1: size(rawDataAgg.raw,2)
    
    normDataAgg.norm{n} = rescale((rawDataAgg.raw{n}),minNum,maxNum);
    
    dD = dD+1; % index for new data
end    

save ([resultsFolder filesep mouseID 'normDataAgg'], 'normDataAgg'); %save normalized data as .mat file
%% create gaussian filter, scatter plot, & heat map

% ask user for sigma to create gaussian filter
prompt = {'Enter sigma for gaussian filter'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'2.5'};
userInputSigma = inputdlg(prompt,dlgtitle,dims,definput); 
[xG, yG] = meshgrid(-5:5);
sigma = str2num(string(userInputSigma));
g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
g = g./sum(g(:));

save ([resultsFolder filesep mouseID 'user_defined_sigma'], 'sigma'); %save user defined sigma

% show and save scatter plots
for i = 1: size(aggData,2)
    scatterSynapses(aggData(i), resultsFolder);
end
    
% show and save heat maps
for iI = 1:size(normDataAgg.norm,2)
    normDataHeatInput = (normDataAgg.norm{n});
    heatmapSynapses(aggData(iI), normDataHeatInput, resultsFolder, g);
end