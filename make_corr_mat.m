function corr_mat = make_corr_mat(data,do_cocktail_blank,cocktail_approach)
%{
arm Jun 22 2021 Function designed to take in data and return a correlation
matrix (corr_mat) across the conditions for that data. data - fMRI surface

data - matrix, surface nodes x condition x run (e.g. 300 nodes x 21 conditions x 8 runs)

%}

% default is not to cocktail blank
if ~exist('do_cocktail_blank','var')
    do_cocktail_blank = '0';
end

nruns = size(data,3); % note that even/odd split isn't going to work with odd number of runs
odd = data(:,:,[1:2:nruns]); % nvoxels x nconditions x nruns
even = data(:,:,[2:2:nruns]);

if do_cocktail_blank % subtract the mean pattern, i.e. the mean across conditions for each voxel, from each response pattern
    
    switch cocktail_approach
        case 'global'
            mean_across_conditions = mean(data,[2 3]);
            cb_odd = odd - mean_across_conditions;
            cb_even = even - mean_across_conditions;
        case 'bysplit'
            cb_odd = odd-mean(odd,[2,3]);
            cb_even = even-mean(even,[2,3]);
    end
    
    % averaging across runs within even and odd
    mean_odd = mean(cb_odd,3); % nodes x condition (e.g. 300 nodes x 21 conditions)
    mean_even = mean(cb_even,3);
    
else % no cocktail blank
    mean_odd = mean(odd,3);
    mean_even = mean(even,3);
end

% make the corrmat symmetrical
corr_mat = (corr(mean_odd, mean_even, 'type', 'spearman') + corr(mean_even, mean_odd, 'type', 'spearman'))/2;

end % end function