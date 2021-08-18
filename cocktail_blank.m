ons function [cb_a,cb_b] = cocktail_blank(a,b,cocktail_approach)
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