%% Automatic analysis of XL file
function AutomaticEPanalysis

[filename, path] = uigetfile('*.atf?');
infile = fullfile(path,filename);

assignin('base','infile',infile);

pathToFile = publish('EPanalysis.m');

close all

averages=evalin('base','averages');

logAverages(infile, averages, 'logfile.txt');

system(pathToFile)

function logAverages(infile, averages, logfile)

if ~exist(logfile,'file')
    fd=fopen(logfile,'w');
    varnames=averages.Properties.VariableNames;
    fprintf(fd,['filename ' sprintf('%s\t',varnames{:}) '\r\n']);
    fclose(fd);
end


fd=fopen(logfile,'a');
fprintf(fd,['"%s" ' num2str(table2array(averages)) '\r\n'],infile);
fclose(fd);



