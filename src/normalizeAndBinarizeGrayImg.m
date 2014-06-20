function bwImg = normalizeAndBinarizeGrayImg( grayImg, thresholdingMethod, gammaCorrectionFlag, gammaValue, histEqFlag )
% Usage: bwImg = normalizeAndBinarizeGrayImg( grayImg, thresholdingMethod, gammaCorrectionFlag, gammaValue, histEqFlag )
%
% Normalize a grayscale image (grayImg) and then threshold it using one of
% the following methods (thesholdingMethod):
% 'moments': Moment-preserving threshold.
% 'ridler-calvard': Ridler-Calvard threshold.
% 'RATS': RATS threshold.
% 'OTSU': Otsu's threshold.
% 'concavity': Concavity-based threshold.
% 'ISO': ISO data threshold.
% 'entropy': Max. entropy threshold.



MAX = max(grayImg(mask==1));
MIN = min(grayImg(mask==1));
normGrayImg = (grayImg-MIN)./(MAX-MIN);

% normGrayImg = normGrayImg * 255;

if gammaCorrectionFlag
    normGrayImg = normGrayImg.^gammaValue;
end

if histEqFlag
    normGrayImg = histeq(normGrayImg,255);
end

if strcmp(thresholdingMethod,'moments')
    
    bwImg = im2bw(normGrayImg,moments(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'ridler-calvard')
    
    bwImg = im2bw(normGrayImg,Ridler_Calvard(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'RATS')
    
    bwImg = im2bw(normGrayImg,RATS(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'concavity')
    
    bwImg = im2bw(normGrayImg,concavityfunction(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'ISO')
    
    bwImg = im2bw(normGrayImg,isodata(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'entropy')
    
    bwImg = im2bw(normGrayImg,maxentropy(255*normGrayImg));
    
elseif strcmp(thresholdingMethod,'OTSU')
    
    bwImg = im2bw(normGrayImg,graythresh(255*normGrayImg));     
  
else
    
    errordlg('The specified thresholding method is not recognized');
    
end


end

