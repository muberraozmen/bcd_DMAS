function [data, clock, start_pt]= MARK_load_data(DATA_DIR, folder, nSamples,start_pt)
%
% Load data from text files
%
% Inputs: 
% DATA_DIR & folder: these combine to form the directory where the text files are located
% nSamples: the number of samples to read for each signal
% start_pt [optional] : the start point (offset) for generating each signal
%
% If start_pt is not provided, the starting point is calculated by
% determining the value where a smoothed absolute value exceeds 1.5 * the
% mean absolute value of the signal
%

nSensors = 16;


data  = zeros(nSensors,nSensors,nSamples);
clock = zeros(nSensors,nSensors,nSamples);
rd = zeros(nSensors,nSensors,2*nSamples);

% Initialize a variable to keep track of start of signal
vgr_min = nSamples+1;

for TXAntenna = 1:16
    for RXAntenna = 1:16
        if TXAntenna ~= RXAntenna
            % construct a filename and import the data into "rawdata"
            filename = sprintf('sig_A%d_A%d_hw16.txt', TXAntenna, RXAntenna);
            filepath = [DATA_DIR folder filename];
            if isfile(filepath)
                rawdata = importdata(filepath);
                rawdata = rawdata(:, 1);
            else
                filename = sprintf('tx%02d_rx%02d.txt', TXAntenna, RXAntenna);
                filepath = [DATA_DIR folder filename];
                rawdata = importdata(filepath);
            end
            if nargin < 4 % no start_pt provided so estimate it
                % 
                rd(TXAntenna,RXAntenna,:) = rawdata(1:2*nSamples);
                % rd(TXAntenna,RXAntenna,:) = bandpass(rd(TXAntenna,RXAntenna,:),f_pass,f_s);
                % Calculate (approximately) the start of the signal
                % Exponentially weighted moving average to smooth signal
                % Identify first point where smoothed absolute value exceeds
                % 1.5 * mean absolute value of the demeaned signal
                %
                rv = rawdata(1:2*nSamples);
                rv = rv-mean(rv);
                vgx = mean(abs(rv))*ones(size(rv,1),1);
                vgr = find((ewma_py(abs(rv),'com',16)-1.5*vgx)>0,1);
                
                % Keep track of the first point across all of the data signals
                if vgr<vgr_min
                    vgr_min = vgr;
                end
            else
                %rd = bandpass(rawdata,f_pass,f_s);
                rd = rawdata;
                data(TXAntenna,RXAntenna,:)  = detrend(rd(start_pt:start_pt+nSamples-1));
            end
        end
    end
end

% If start_pt not provided, set the start_pt to be the identified signal start
% minus 64 to account for the time delay introduced by the smoothing
if nargin<4
    start_pt = max(1,vgr_min-64);
    
    for TXAntenna = 1:16
        for RXAntenna = 1:16
            data(TXAntenna,RXAntenna,:) = (squeeze(rd(TXAntenna,RXAntenna,start_pt:start_pt+nSamples-1)));
        end
    end
end

