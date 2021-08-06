function corr_mat = make_corr_mat(data,datasplit,do_cocktail_blank,cocktail_approach)
%{
arm Jun 22 2021 Function designed to take in data and return a correlation
matrix (corr_mat) across the conditions for that data. data - fMRI surface

data - matrix, surface nodes x condition x run (e.g. 300 nodes x 21 conditions x 8 runs)
datasplit - string, 'evenodd' or 'leaveoneout'. default is evenodd.
%}

% default datasplit is evenodd
if ~exist('datasplit','var')
    datasplit = 'evenodd';
end

% default is not to cocktail blank
if ~exist('do_cocktail_blank','var')
    do_cocktail_blank = '0';
end

switch datasplit
    case 'evenodd'
        odd = data(:,:,[1:2:8]); % nvoxels x nconditions x nruns
        even = data(:,:,[2:2:8]);
        if size(even) ~= size(odd)
            error('even and odd matrices are different sizes')
        end
        if do_cocktail_blank % subtract the mean pattern, i.e. the mean across conditions for each voxel, from each response pattern
            [cb_odd,cb_even] = cocktail_blank(odd,even,cocktail_approach);
            
            % averaging across runs within even and odd
            mean_odd = mean(cb_odd,3); % nodes x condition (e.g. 300 nodes x 21 conditions)
            mean_even = mean(cb_even,3);
            
        else % no cocktail blank
            % averaging across runs within even and odd
            mean_odd = mean(odd,3);
            mean_even = mean(even,3);
        end
        
        %{
        make corr_mat symmetrical - each index represents how correlated
        the mean response from even runs for a set of nodes of
        condition i are to the mean response from odd runs for a set of
        nodes from condition j
        %}
        corr_mat = (corr(mean_odd, mean_even, 'type', 'spearman') + corr(mean_even, mean_odd, 'type', 'spearman'))/2;
        
    case 'halfcombos'
        nruns = size(data,3);
        nconds = size(data,2);
        
        % splits are run x split mtx
        half1_splits = nchoosek(1:nruns,nruns/2);
        half1_splits = half1_splits(1:size(half1_splits,1)/2,:); % take unique splits only 
        half2_splits = nan*zeros(size(half1_splits));
        for i = 1:size(half1_splits,1)
            half2_splits(i,:) = setdiff(1:nruns,half1_splits(i,:));
        end
        nsplits = size(half1_splits,1);
        corr_mat_all = zeros(nconds, nconds, nsplits);
        for i = 1:nsplits % i is the index of a split, e.g. [1 2 3 4]
            half1 = data(:,:,half1_splits(i,:));
            half2 = data(:,:,half2_splits(i,:));
            
            if do_cocktail_blank % subtract the mean pattern, i.e. the mean across conditions for each voxel, from each response pattern
                [cb_half1,cb_half2] = cocktail_blank(half1,half2,cocktail_approach);
                
                % averaging across runs within even and odd
                mean_half1 = mean(cb_half1,3); % nodes x condition (e.g. 300 nodes x 21 conditions)
                mean_half2 = mean(cb_half2,3);
                
            else % no cocktail blank
                % averaging across runs within even and odd
                mean_half1 = mean(half1,3);
                mean_half2 = mean(half2,3);
            end
            corr_mat_all(:,:,i) = (corr(mean_half1, mean_half2, 'type', 'spearman') + corr(mean_half2, mean_half1, 'type', 'spearman'))/2;
        end
        corr_mat = mean(corr_mat_all,3); % average across splits
        
end % end datasplit
end % end function

function [cb_a,cb_b] = cocktail_blank(a,b,cocktail_approach)
%{
Perform cocktail blank demeaning on two data sets, each nvoxels x
nconditions x nruns. Cocktail approach specifies whether cocktail blanking
occurs across all runs (most common in resting state), by split (e.g. even
- mean(even), odd - mean(odd)) or per run.
%}

switch cocktail_approach
    case 'global'
        mean_across_conditions = mean(data,[2 3]);
        cb_a = a - mean_across_conditions;
        cb_b = b - mean_across_conditions;
    case 'bysplit'
        cb_a = a-mean(a,[2,3]);
        cb_b = b-mean(b,[2,3]);
    case 'perrun' % seems to eventually produce the same thing as bysplit;
        cb_a = nan*zeros(size(a));
        cb_b = nan*zeros(size(b));
        for r = 1:size(a,3)
            cb_a(:,:,r) = a(:,:,r) - mean(a(:,:,r),2);
            cb_b(:,:,r) = b(:,:,r) - mean(b(:,:,r),2);
        end
end
end