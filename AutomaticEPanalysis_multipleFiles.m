function AutomaticEPanalysis_multipleFiles

% Prompt the user for a .atf file
path = uigetdir('.','Input directory');
out = uigetdir('.','Output directory');

% Get the list of files
files = dir(fullfile(path,'*.atf'));

for f = files'
    % Assign it to the global workspace (needed for the publish function)
    infile = fullfile(path,f.name);
    assignin('base','infile',infile);

    % Create the report and get the path to the HTML file
    publish('EPanalysis.m','outputDir',fullfile(out,[f.name(1:end-4) ' report']));

    % Get the `averages` variable
    logfile=fullfile(out,'logfile.txt');
    averages=evalin('base','averages');
    
    % Store it in the logfile
    logAverages(infile, averages,logfile);

    close all
end

function logAverages(infile, averages,logfile)

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
