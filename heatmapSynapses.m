function fig = heatmapSynapses(aggData, normDataHeatInput, resultsFolder, g)
% expects aggData and normDataAgg as inputs

% find image size data and ptsx
mouseID = aggData.mouseID;
slicename = aggData.slicename;
spinallevel = aggData.spinallevel;

if ~isfield(aggData, 'ptsx')
    r = aggData.imgsize(1);
    c = aggData.imgsize(2);
    numBins = ceil(sqrt(c));
    ptsx = linspace(0, c, numBins);
else
    ptsx = aggData.ptsx;
    r = aggData.imgsize(1);
end

% smooth data and create heat map
fig = figure('Name','Heat Map Results');
density = conv2(normDataHeatInput, g, 'same');
imagesc(ptsx, ptsx, density);  
set(gca, 'XLim', ptsx([1 end]), 'YLim', [1 r], 'YDir', 'reverse');
colorbar;

% save plot
% Save Figure as Tiff Files (Not Compressed)
heatMapName = [mouseID '_' spinallevel '_' slicename '_' 'heatmap'];
print(fig,[resultsFolder filesep heatMapName],'-dtiffn');

end 