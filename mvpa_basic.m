%{
Written by Anna Mynick Jun 2021 using MATLAB 2019b
Individual image MVPA analysis, originally written for iscrabble
contextPerceptionA and contextPerceptionB data, using a within > across
test.
%}

addpath('../cbrewer/') % need this if you don't have it: https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab

datasplit = 'evenodd'; % evenodd, leaveoneout
roitype = 'tstat';
do_cocktail_blank = 1;
cocktail_approach = 'bysplit'; % global (global pattern across all splits) or bysplit (subtract even for even, odd for odd)

select_roi_inds = [1 2 3 4 5 6 8];
select_roi_labels = controlStruct.roiLabels(select_roi_inds);

select_cond_inds = [1:20]; % unfamiliar is #21
select_cond_labels = controlStruct.conditions(select_cond_inds);
nconds = numel(select_cond_inds); % 20

scene_info = readtable('neighborhood_list.xlsx');
hemis = {'lh','rh'}; % this probably shouldn't need to be hard-coded

% Collect all the relevant data and put it in a matrix
corr_mats = nan*zeros(nconds, nconds, 2, numel(controlStruct.roiLabels),numel(SUBJNUMBERS)); % mdim mdim hemi roi subject
for s = 1:numel(SUBJNUMBERS)
    for h = 1:2
        for r = select_roi_inds % all non-relevant rois will stay NaNs
            data = subjs{s,h}.rois.(eval('roitype')){r}; % node x condition x run
            
            % skip if no data
            if size(subjs{s,h}.rois.(eval('roitype')){r},1) == 0
                disp(['Missing data for uno' SUBJNUMBERS{s} ' ' hemis{h} ' ' controlStruct.roiLabels{r}])
                continue
            end
            
            % add to the correlation matrix stack for this: subject, hemisphere, roi
            corr_mats(:,:,h,r,s) = make_corr_mat(data(:,select_cond_inds,:),do_cocktail_blank,cocktail_approach);
        end
    end
end

% make a stack of plot_mats (matrices to plot)
plot_mats = squeeze(nanmean(corr_mats,[3 5])); % mdim mdim roi 
plot_mats_subjs = squeeze(nanmean(corr_mats,[3])); % mdim mdim roi subject (keep subjects individual)
labels = controlStruct.conditions(select_cond_inds);

% Plots start here --------------------------------------------------------

% 1. Plot correlation matrices, one for each roi
figure(1)
for r = select_roi_inds
    nexttile
    plot_mvpa(plot_mats(:,:,r),cellfun(@(x) strrep(x,'_', ' '), labels, 'UniformOutput', false), controlStruct.roiLabels{r});
end
set(gcf, 'Position',  [0, 0, 1000, 1000]);
h1 = gcf;
saveas(h1,['~/Desktop/' controlStruct.experiment '_' roitype '_' datasplit '_mat.png']);

% 2. Plot bar plots showing difference within / across a single condition
plot_mvpa_within_across(plot_mats_subjs(:,:,select_roi_inds,:,:),select_roi_labels)
h2 = figure(2);
h3 = figure(3);
saveas(h2,['~/Desktop/' controlStruct.experiment '_' roitype '_' datasplit '_wa.png']);
saveas(h3,['~/Desktop/' controlStruct.experiment '_' roitype '_' datasplit '_wa_dif.png']);
