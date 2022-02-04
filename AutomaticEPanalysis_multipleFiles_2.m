function AutomaticEPanalysis_multipleFiles

path = uigetdir('.','Input directory');
out = uigetdir('.','Output directory');

files = dir(fullfile(path,'*.atf'));

for f = files'
    infile = fullfile(path,f.name);
    assignin('base','infile',infile);

    publish('EPanalysis.m','outputDir',fullfile(out,[f.name(1:end-4) ' report']));

    logfile=fullfile(out,'logfile.txt');
    averages=evalin('base','averages');
    logAverages(infile, averages,logfile);

    close all
end

function logAverages(infile, averages,logfile)

if ~exist(logfile,'file')
    fd=fopen(logfile,'w');
    varnames=averages.Properties.VariableNames;
    fprintf(fd,['filename ' sprintf('%s\t',varnames{:}) '\r\n']);
    fclose(fd);
end


fd=fopen(logfile,'a');
fprintf(fd,['"%s" ' num2str(table2array(averages)) '\r\n'],infile);
fclose(fd);
