Written by Anna Mynick, Summer 2021 using MATLAB 2019b

mvpa-basic is a set of scripts designed as a "vanilla" MVPA analysis, which compares the pattern similarity in a pre-defined region of interest (ROI) within conditions versus across conditions. 

The script is currently configured to do an individual stimulus analysis (how much does one presentation of a stimulus resemble the other presentations of the same stimulus, compared to the other stimuli that have been shown?). 

mvpa_basic.m: The main code, where you dictate: 
- datasplit: string, even/odd runs or halfcombos (all possible combinations of different halves of the data)
- roitype: string, based on datastructures used in Adam Steel's fMRI data processing pipeline. 'tstat' gives all nodes in an ROI. 'tstatUniqueNodes' gives all non-overlapping nodes. 
- do_cocktail_blank: bool, whether to perform cocktail blank demeaning. 
- cocktail_approach: string, what type of cocktail blanking to do. 
- select_roi_inds: vector, dictates which ROIs to do analysis on, based on their ordering in the subjs{} datastructure based on Adam Steel's fMRI data processing pipeline. 

make_corr_mat.m: function called by mvpa_basic. Takes data for an individual (hemisphere, ROI, subject). Returns a nconditions x nconditions correlation matrix indicating how correlated each condition (i.e. individual image) is with each other condition (i.e. individual image). Also takes input for whether to do a cocktail blank demeaning (do_cocktail_blank), and which approach to use if so (cocktail_approach). 

plot_mvpa.m: function called by mvpa_basic. Takes a correlation matrix (in this case, of size nconditions x nconditions), the associated labels for that matrix (in a cell array), and the intended plot title. Returns a correlation matrix figure. N.b., the color scheme requires cbrewer, available here: https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab

plot_mvpa_within_across.m: function called by mvpa_basic. Takes a 4-dimension stack of nconditions x nconditions correlation matrices (nconditions x nconditions x roi x subject). Calculates the within- and across- correlation values for each subject (via calculate_within_across.m) and returns bar plots showing (1) within and across bars and (2) the difference between those bars, where within > across is positive. 

calculate_within_across.m: function called by plot_mvpa_within_across. Given a correlation matrix, calculate the average within versus across values (i.e. diagonal versus off diagonal), and return a 2x1 array [within across]. 

cocktail_blank.m: function called by make_corr_mat. Takes two sets of data (e.g. data from even runs (a), data from odd runs (b)) and performs cocktail_blank demeaning (subtracting each voxels' average response across conditions) and an approach: global (a and b get the same values subtracted), bysplit (even gets its own average subtracted, odd gets its own subtracted) or perrun (same as bysplit, but done on each run). Returns cocktail-blanked versions of datasets a and b.


  


