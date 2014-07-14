function thresholdResult = normalizeAndBinarizeGrayImg( grayImg, thresholdingMethod, gammaCorrectionFlag, gammaValue, histEqFlag )
% Usage: thresholdResult = normalizeAndBinarizeGrayImg( grayImg, thresholdingMethod, gammaCorrectionFlag, gammaValue, histEqFlag )
%
% Normalize a grayscale image (grayImg) and then threshold it using one of
% the following methods (thesholdingMethod):
% 'moments': Moment-preserving threshold.
% 'ridler-calvard': Ridler-Calvard threshold.
% 'RATS': RATS threshold.
% 'OTSU': Otsu's threshold without stretching. 
% 'OTSU-Stretched': Otsu's threshold with streching, with 0.5 multiplier.
% 'concavity': Concavity-based threshold.
% 'ISO': ISO data threshold.
% 'entropy': Max. entropy threshold.



% MAX = max(grayImg(mask==1));
% MIN = min(grayImg(mask==1));
% Disabled normalization for now
normGrayImg = grayImg;

% normGrayImg = normGrayImg * 255;

if gammaCorrectionFlag
    normGrayImg = normGrayImg.^gammaValue;
end

if histEqFlag
    normGrayImg = histeq(normGrayImg,255);
end

if strcmp(thresholdingMethod,'moments')
    
    thresholdResult = moments(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'ridler-calvard')
    
    thresholdResult = Ridler_Calvard(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'RATS')
    
    thresholdResult = RATS(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'concavity')
    
    thresholdResult = concavityfunction(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'ISO')
    
    thresholdResult = isodata(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'entropy')
    
    thresholdResult = maxentropy(255*normGrayImg);
    
elseif strcmp(thresholdingMethod,'OTSU')
    
    thresholdResult = graythresh(normGrayImg);
    
elseif strcmp(thresholdingMethod,'OTSU-Stretched')
    
    thresholdResult = 0.5 * graythresh(255*normGrayImg); 
  
else
    
    errordlg('The specified thresholding method is not recognized');
    
end


end

