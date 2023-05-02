function fig = scatterSynapses(aggData,resultsFolder)
% expects aggData as input, but one cell at a time
% expects resultsFolder Path as input

mouseID = aggData.mouseID;
slicename = aggData.slicename;
spinallevel = aggData.spinallevel;
x = aggData.x;
y = aggData.y;

if ~isfield(aggData, 'ptsx')
    r = aggData.imgsize(1);
    c = aggData.imgsize(2);
    numBins = ceil(sqrt(c));
    ptsx = linspace(0, c, numBins);
else
    ptsx = aggData.ptsx;
    r = aggData.imgsize(1);
end

fig = figure('Name','Scatter Plot Results');
sz = 0.25;
scatter(x, y, sz, 'r.');
set(gca, 'XLim', ptsx([1 end]), 'YLim', [1 r], 'YDir', 'reverse');
grid on;

% Save Figure as Tiff Files (Not Compressed)
scatterPlotName = [mouseID '_' spinallevel '_' slicename '_' 'scatterplot'];
print(fig,[resultsFolder filesep scatterPlotName],'-dtiffn');

end 