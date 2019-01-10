%
% Copyright 2018-2019 University of Padua, Italy
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% Author: Nicola Ferro (ferro@dei.unipd.it)

%opening all trec results and saving them into .mat structures for further
%operations
ID = fopen('map1.txt');
A = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('map2.txt');
B = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('map3.txt');
C = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('map4.txt');
D = textscan(ID, '%s %u %f');
fclose(ID);
measure = [A{3} B{3} C{3} D{3}];

%defining my runs and obtaining the numbers of each topic
%respectively: "StopPorterBM25", "StopPorterTFIDF", "NonStopPorterBM25", "NonStopNonPorterTFIDF"
runID = ["SPB", "SPT", "NPB", "NNT"];
topicID = [A{2}];

save map.mat topicID runID measure

ID = fopen('Rprec1.txt');
E = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('Rprec2.txt');
F = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('Rprec3.txt');
G = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('Rprec4.txt');
H = textscan(ID, '%s %u %f');
fclose(ID);
measure = [E{3} F{3} G{3} H{3}];

save rprec.mat topicID runID measure

ID = fopen('p101.txt');
I = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('p102.txt');
L = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('p103.txt');
M = textscan(ID, '%s %u %f');
fclose(ID);
ID = fopen('p104.txt');
N = textscan(ID, '%s %u %f');
fclose(ID);
measure = [I{3} L{3} M{3} N{3}];

save p10.mat topicID runID measure

%union in an array of all the obtained maps, for the cicle
mat = ["map.mat", "rprec.mat", "p10.mat"];

%subplot per topic
figure;
subplot(311);
x = [A{3} B{3} C{3} D{3}];
graph1 = bar(x);
title('Map');
subplot(312);
y = [E{3} F{3} G{3} H{3}];
graph2 = bar(y);
title('RPrec');
subplot(313);
z = [I{3} L{3} M{3} N{3}];
graph3 = bar(z);
title('P10');
leg1 = legend([graph1, graph2, graph3], {'StopPorterBM25', 'StopPorterTFIDF', 'NonStopPorterBM25', 'NonStopNonPorterTFIDF'});
set(leg1,'Position', [0.82 0.92 0.01 0.01]);

%subplot per run
figure;
subplot(221);
w = [A{3} E{3} I{3}];
graph4 = bar(w);
title('StopPorterBM25');
subplot(222);
q = [B{3} F{3} L{3}];
graph5 = bar(q);
title('StopPorterTFIDF');
subplot(223);
p = [C{3} G{3} M{3}];
graph6 = bar(p);
title('NonStopPorterBM25');
subplot(224);
l = [D{3} H{3} N{3}];
graph7 = bar(l);
title('NonStopNonPorterTFIDF');
leg2 = legend([graph4, graph5, graph6, graph7], {'Map', 'RPrec', 'P10'});
set(leg2,'Position', [0.5 0.5 0.01 0.01]);

%%
for i = 1:mat.length()
    %%
    load('C:\Users\Riccardo\Desktop\IR\' + mat(i))

    m = mean(measure);
    
    % sort in descending order of mean score
    [~, idx] = sort(m, 'descend');
    
    % re-order runs by ascending mean of the measure
    % needed to have a more nice looking box plot
    measure = measure(:, idx);
    runID = runID(idx);
    
    % perform the ANOVA
    [~, tbl, sts] = anova1(measure, runID, 'off');
    
    % display the ANOVA table
    tbl
    
    % perform
    figure;
    c = multcompare(sts, 'Alpha', 0.05, 'Ctype', 'hsd');
    
    % display the multiple comparisons
    c
    
    %% plots of the data
    
    % get the Tukey HSD test figure
    currentFigure = gcf;
    
    ax = gca;
    ax.FontSize = 20;
    ax.XLabel.String = 'Average Precision (AP)';
    ax.YLabel.String = 'Run';
    
    currentFigure.PaperPositionMode = 'auto';
    currentFigure.PaperUnits = 'centimeters';
    currentFigure.PaperSize = [42 22];
    currentFigure.PaperPosition = [1 1 40 20];
    
    print(currentFigure, '-dpdf', 'ap-tukey.pdf');
    
    
    % box plot
    currentFigure = figure;
    % need to reverse the order of the columns to have bloxplot displayed
    % as the Tukey HSD plot
    boxplot(measure(:, end:-1:1), 'Labels', runID(end:-1:1), ...
        'Orientation', 'horizontal', 'Notch','off', 'Symbol', 'ro')
    
    ax = gca;
    ax.FontSize = 20;
    ax.XLabel.String = 'Average Precision (AP)';
    ax.YLabel.String = 'Run';
    
    currentFigure.PaperPositionMode = 'auto';
    currentFigure.PaperUnits = 'centimeters';
    currentFigure.PaperSize = [42 22];
    currentFigure.PaperPosition = [1 1 40 20];
    
    print(currentFigure, '-dpdf', 'ap-boxplot.pdf');
    
    disp('Press a key to continue to the next statistic or to end the file...');
    pause;
end

close all;


