function [within_across] = calculate_within_across(corr_mat)
% arm Jun 2021
% given a correlation matrix, calculate the within versus across values,
% and return a 2x1 array with [within across]
mdim = size(corr_mat,1);
within = mean(corr_mat(find(eye(mdim))));
across = mean(corr_mat(find(~eye(mdim))));
within_across = [within across];
end
