%% Automatic analysis of XL file
function AutomaticEPanalysis

% Prompt the user for a .atf file
[filename, path] = uigetfile('*.atf?');
infile = fullfile(path,filename);

% Assign it to the global workspace (needed for the publish function)
assignin('base','infile',infile);

% Create the report and get the path to the HTML file
pathToFile = publish('EPanalysis.m');

close all

% Get the `averages` variable
averages=evalin('base','averages');

% Store it in the logfile
logAverages(infile, averages, 'logfile.txt');

% Open it with the default editor for TXT files
system(pathToFile)

function logAverages(infile, averages, logfile)

% If the file does not exist, create it and add column headings
if ~exist(logfile,'file')
    fd=fopen(logfile,'w');
    varnames=averages.Properties.VariableNames;
    fprintf(fd,['filename ' sprintf('%s\t',varnames{:}) '\r\n']);
    fclose(fd);
end

% Add the data to the end of the file
fd=fopen(logfile,'a');
fprintf(fd,['"%s" ' num2str(table2array(averages)) '\r\n'],infile);
fclose(fd);



