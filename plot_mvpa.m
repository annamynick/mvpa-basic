function plot_mvpa(data,labels,plot_title)

addpath('./cbrewer')

limit = max(abs(data),[],'all');

imagesc(data,[-limit limit])
colorbar

xticklabels(labels)
xticks([1:numel(labels)])
xtickangle(45)

yticklabels(labels)
yticks([1:numel(labels)])


set(gca,'FontSize',10)

imagescmap=cbrewer('div', 'RdBu',100); 
imagescmap = imagescmap(end:-1:1,:); % inverts the color map so that red = high correlation, blue = low correlation
colormap(imagescmap)

title(plot_title,'FontSize',8)
axis square
end