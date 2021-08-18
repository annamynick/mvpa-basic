function plot_mvpa_within_across(plot_mats,roilabels)

% find out whether an image is more correlated with itself than with the
% average of all the other images
addpath('../sigstar') % need this if you don't have it https://www.mathworks.com/matlabcentral/fileexchange/39696-raacampbell-sigstar

% perform setup
nsubjects = size(plot_mats,4); % m1, m2, hemi, roi, subject
mdim = size(plot_mats,1);
nrois = size(plot_mats,3);

% calculate within v. across for each subject
wa_mat = nan*zeros(nsubjects,2,nrois); % subject x [within across] x roi
sig_mat = nan*zeros(nrois,1); % holds the p-values resulting from t-tests that compare within v. across for each roi. 

for r = 1:nrois
    for s = 1:nsubjects
        wa_mat(s,:,r) = calculate_within_across(plot_mats(:,:,r,s));   % [within, across]
    end % end subjects
    
    % do t-test between within and across
    [~,sig_mat(r),~,~] = ttest2(wa_mat(:,1,r),wa_mat(:,2,r));
end

% Plot within and across seperately
C = [102, 162, 204; 221, 237, 170] / 255; % custom colors
labels = {'within','across'};

figure(2)
for r = 1:nrois
    nexttile
    b = bar([1 2],mean(wa_mat(:,:,r)));
    sigstar({[1,2]},[sig_mat(r)])
    b.FaceColor = 'flat';
    b.CData(1,:) = C(1,:);
    b.CData(2,:) = C(2,:);
    hold on
    plot(wa_mat(:,:,r)','Marker','o','Color',[.5 .5 .5 .5]);   
    xticks([1:numel(labels)])
    xticklabels(labels)
    ylim([min(wa_mat(:,:,r),[],'all') max(wa_mat(:,:,r),[],'all')])    
    set(gca,'FontSize',12)    
    title(roilabels{r},'FontSize',12)       
    axis square
end % end rois
set(gcf, 'Position',  [0, 0, 1000, 1000]);

% Plot within - across difference scores
figure(3)
for r = 1:nrois
    nexttile
    set(gca,'FontSize',12)
    dif_scores = wa_mat(:,1,r)-wa_mat(:,2,r);
    b = bar([1],mean(dif_scores));
    sigstar({[1 1]},[sig_mat(r)])
    b.FaceColor = 'flat';
    b.CData(1,:) = C(1,:);    
    hold on
    scatter(ones(1,numel(dif_scores)),dif_scores,50,'filled','MarkerFaceAlpha',.4)    
    xticks([1])
    xticklabels('within - across')
    extra = 1.5;
    ylim([min(dif_scores)*extra max(dif_scores)*extra])    
    title(roilabels{r},'FontSize',12)       
    axis square
end % end rois
set(gcf, 'Position',  [0, 0, 1000, 1000]);

end % end function
