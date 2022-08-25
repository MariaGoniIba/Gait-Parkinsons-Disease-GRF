function s = delete_outliers(s)
% An outlier in a distribution is a number that is more than 1.5 times the length of the box away from either 
% the lower or upper quartiles. Specifically, if a number is less than Q1 - 1.5×IQR or greater than 
% Q3 + 1.5×IQR, then it is an outlier.

Q1=prctile(s,25);
Q3=prctile(s,75);
IQR=iqr(s);

% I will detect "far away" values (3) instead of outliers (1.5)
low=Q1-3*IQR;
high=Q3+3*IQR;

outliers=zeros(size(s));
outliers(find(s<low))=1;
outliers(find(s>high))=1;

s(find(outliers))=[];
