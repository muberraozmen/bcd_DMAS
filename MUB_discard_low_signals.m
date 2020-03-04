function [IND, selected_antenna_pairs] = MUB_discard_low_signals(baseline_raw, signals_raw, wrt, n)
% if wrt = 1 select with respect to baseline scan 
% if wrt = 2 select with respect to tumour scan 
% n: number of antenna pairs to select

if wrt == 1
    data = baseline_raw;
elseif wrt == 2
    data = signals_raw; 
end

max_amplitute = max(data,[],3);
[~, linIndex] = sort(max_amplitute(:), 'descend');
IND = linIndex(1:n);
s = [16,16];
[TX, RX] = ind2sub(s, IND); % selected antenna pairs 

selected_antenna_pairs = [TX RX];

end