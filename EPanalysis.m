%% Analyze the data matrix 'a'
% The format of 'a' is a table, where the first column contains the
% timestamps and the other columns are the signals to be analyzed

% What file are we analyzing?
evalin('base','infile')

% Read in the data
data=importdata(infile,'\t',11);
a=data.data;

% Break down the matrix
t = a(:,1)*1000;
V = a(:,2:end);
nsig=size(V,2);

%%
% 
% * AP peak voltage
% * Maximum diastolic polarization
% * AP amplitude
% 
[pv, ipv] = max(V);
AP_peak_voltage = pv'
[dv, idv] = min(medfilt1(V,10));
AP_max_diastolic_polarization = dv'
AP_max_diastolic_polarization_time = t(idv);
AP_amplitude = AP_peak_voltage-AP_max_diastolic_polarization
AP_peak_voltage_time = t(ipv);

%% Estimate dVdT max 
% Estimation through local smoothing and Gaussian fitting

%%
% The smoothed derivative kernel
hT=t(2)-t(1);
k=[1 0 -1]'/2/hT;
ks=[1 2 1]'/4;
kk=conv(k,ks)
kl2=.5*(length(kk)-1);

% Perform the convolution and determine the dV/dT max
dV = conv2(V,kk,'valid');
tdV = t((1+kl2):end-kl2);

% Only look in a region before the peak
imdV0 = max(ipv);
ok = 1:imdV0;
[mdV, imdV] = max(dV(ok,:));

% Use a Gaussian fitting function to fine tune the position 
dVdTmaxTime=tdV(imdV);
dVdTmaxAmplitude=mdV';
dVdTmaxTime_fitted=zeros(nsig,1);
dVdTmaxAmplitude_fitted=zeros(nsig,1);
gauss=@(pars,x) pars(1)*exp(-pars(2)*(x-pars(3)).^2);
for i=1:nsig
    ok=imdV(i)+(-40:40);
    
    fit = lsqcurvefit(gauss,[dVdTmaxAmplitude(i) 1 dVdTmaxTime(i)],tdV(ok),dV(ok,i));
    dVdTmaxTime_fitted(i)=fit(3);
    dVdTmaxAmplitude_fitted(i)=fit(1);
    
    % Plot the fit
    xf=tdV(ok);
    yf=gauss(fit,xf);
    yo=dV(ok,i);
    figure;plot(xf,yo,'.',xf,yf,dVdTmaxTime_fitted(i),dVdTmaxAmplitude_fitted(i),'x',dVdTmaxTime(i),dVdTmaxAmplitude(i),'+');
    MSE=mean((yf-yo).^2);
    title(sprintf('Sweep N.%d    MSE:%.2f (%d)',i,MSE,round(length(xf))))
    xlabel('Time (ms)');
    ylabel('dVoltage (V/s)');
    legend('data','Gaussian fit','\delta V / \delta T_{max,fitted}','\delta V / \delta T_{max}');
end

dVdTmaxTime_fitted
dVdTmaxAmplitude_fitted


%% APDs
% Here we estimate where the signal reaches APD levels specified here:
APDs_targets=[10 30 40 70 80 90]

%% 
% Find the 

ntargets=length(APDs_targets);
APDs=zeros(nsig,ntargets);
inOrder=zeros(nsig,1);
for isig=1:nsig
    for itarget=1:ntargets
        % Only the signal after the peak is of interest
        after_peak=t>AP_peak_voltage_time(isig);
        sig=V(after_peak,isig);
        
        % Calculate the target voltage
        tar=APDs_targets(itarget);
        tarV=AP_max_diastolic_polarization(isig)+AP_amplitude(isig)*(1-APDs_targets(itarget)/100);
        
        % Find the values within a window of +-2mV
        td=t(after_peak); 
        reg=abs(sig-tarV)<2;
        
        preDPeak=td<AP_max_diastolic_polarization_time(isig);
        if sum(preDPeak)>0
            reg=reg&preDPeak;
        end
        
        % Remove outliers (more than 10 irregular consecutive points)
        tdr=td(reg);
        maxtdri = find(diff(tdr)>10,1);
        if ~isempty(maxtdri) && tar>60
            reg = reg & td<=tdr(maxtdri);
        end
        
        % Check if enough points for robust fit
        if sum(reg)>5
            sig=sig(reg);
            td=td(reg);
            
            % Robust linear fit of the windowed signal
            coef=robustfit(td,sig);

            APDs(isig,itarget)=(tarV-coef(1))/coef(2)-dVdTmaxTime_fitted(isig);                 
        else
            APDs(isig,itarget)=mean(td)-dVdTmaxTime_fitted(isig);
        end
            
    end
    
    % Perform a sanity check: are APDs in order?
    inOrder(isig) = all(APDs(isig,:)==sort(APDs(isig,:)));
    if ~inOrder(isig)
        warning('These APDs are not in order!!!')
    end
end

% The resulting APDs are
APDs_targets
APDs


%% RESULTS SUMMARY
% A table with the requested results and a series of plots
% with the various interest points.

for isig=1:nsig
    figure;
    plot(t,V(:,isig))
    hold
    plot(dVdTmaxTime_fitted(isig)+APDs(isig,:),AP_max_diastolic_polarization(isig)+AP_amplitude(isig)*(1-APDs_targets/100),'rx')
    set(refline(0,AP_max_diastolic_polarization(isig)),'Color','red','LineStyle',':')
    set(refline(0,AP_peak_voltage(isig)),'Color','red','LineStyle',':')
    line(ones(1,2)*tdV(imdV(isig)),[AP_max_diastolic_polarization(isig) AP_peak_voltage(isig)],'Color','red','LineStyle',':')
    line(dVdTmaxTime_fitted(isig)+ones(1,2)*APDs(isig,end),[AP_max_diastolic_polarization(isig) AP_peak_voltage(isig)],'Color','red','LineStyle',':')
    title(sprintf('Sweep N.%d',isig))
    xlabel('Time (ms)');
    ylabel('Voltage (mV)');
    if ~inOrder(isig)
        set(gca,'XColor','r')
        set(gca,'YColor','r')
    end
end

for itar=1:ntargets
    assignin('base',sprintf('APD%d',APDs_targets(itar)),APDs(:,itar));
end

sweepID=(1:nsig)';

resultsTable = table(sweepID,AP_peak_voltage,AP_max_diastolic_polarization,dVdTmaxAmplitude_fitted,dVdTmaxTime_fitted,dVdTmaxAmplitude,dVdTmaxTime,AP_amplitude,APD90,APD10,APD30,APD40,APD70,APD80)

%% AVERAGE AND RATIO ANALYSIS 
% It only uses the sweeps for which APD are in increasing order

% Averages
averages = array2table(mean(resultsTable{find(inOrder),2:end},1),...
    'VariableNames',resultsTable.Properties.VariableNames(2:end))

%%
% Using sweeps
find(inOrder)

%%
% The APD40-APD30/APD80-APD70 ratio based on the averages
averages.shape = (averages.APD40-averages.APD30)/(averages.APD80-averages.APD70)
infile=evalin('base','infile');


