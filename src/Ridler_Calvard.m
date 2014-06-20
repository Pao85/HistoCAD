function [ threshold ] = Ridler_Calvard( grayImg )
% This function finds a suitable threshold for binarization of the image,
% grayImg, based on the method Ridler-Calvard. 'grayImg' is required to
% have gray-level values in the range 0-255. 'mask' is an image indicating
% the effective area of the image.

grayImg = uint8(grayImg);

[binCounts,bins] = imhist(grayImg(:));
totalCounts = binCounts .* bins;


index = bins(1);
mu_L = 0;
mu_H = sum(totalCounts(2:end))/sum(binCounts(2:end));

threshold = (mu_L+mu_H)/2;

i = 2;

while index < threshold && i < length(bins)

    index = bins(i);
    mu_L = sum(totalCounts(1:i-1))/sum(binCounts(1:i-1));
    mu_H = sum(totalCounts(i+1:end))/sum(binCounts(i+1:end));
    
    threshold = (mu_L+mu_H)/2;
    i = i + 1;
    
end

threshold = threshold/255;



