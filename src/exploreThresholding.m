% This script uses the eigen value map of the images to obtain regions of
% interest (ROI). It also evaluates the results of ROI detection using the
% provided ground-truth markings.
tic

% Inizialization
ImageNumber = 1;

circle_coord = struct([]);
TP = zeros(39,8);
FN = zeros(39,8);
FP = zeros(39,8);

for nf = 1 : 1%5
    
    % Change DBFolder to appropriate location on your computer.
    DBFolder = ['C:\Users\Paola\Documents\MATLAB\ENTERPRISE\Pilot\training_tiff_part1\0',num2str(nf),'\'];
    
    f_tiff = dir([DBFolder,'*.tif']);
    f_csv = dir([DBFolder,'*.csv']);
    
    for n = 39 : 39%length(f_tiff)
        disp(['Folder ',num2str(nf),'/Image ',num2str(n)])
        
        % n indicates the number 'name' of image
        % nf indicates the number 'name' of the folder
        
        % Read the n-th .tif file in the nf-th folder
        TIFF_fileName = f_tiff(n).name;
        CSV_fileName = f_csv(n).name;
        Im = imread([DBFolder,TIFF_fileName]);
        
        % Staining normalization
        ImNorm = normalizeStaining(Im);
        
        % Read the coordinates of the centers of the mitosis
        coord = csvread([DBFolder,CSV_fileName]);
        
        % Compute the coordinates of the perimeter of radius 30 pixels centered at
        % the provided coordinates - coord
        
        % Get the size of the image
        [row,col] = size(Im(:,:,1));
        
        % Compute the coordinates of the ground truth circles of radius 30
        % pixels
        for i = 1 : size(coord,1)
            
            circle1 = zeros(row,col);
            circle1(coord(i,1),coord(i,2)) = 1;
            [p1,p2] = find(bwdist(circle1)<30,1,'first');
            circle_coord(i).vec = bwtraceboundary(bwdist(circle1)<30,[p1 p2],'E');
            clear circle1 p1 p2
        end
        
        %% Parameter 1: Image component
        
        % Save the gray-scale images with 6 different combinations of color
        % components
        % ImVariousComponent is a struct that contains 6 fields; one for
        % each R and B component, their average
        % and their normalized counter parts (1-R, 2-B, 3-(R+B)/2, 4-R_norm,
        % 5-B_norm, 6-(R_norm+B_norm)/2 ).

        % Average of Red and Blue components
        ImVariousComponents(1).im = .5*(im2double(imcomplement(Im(:,:,1))) + im2double(imcomplement(Im(:,:,3))));
        
        %ImVariousComponents(1).im = .5*(im2double(imcomplement(ImNorm(:,:,1))) + im2double(imcomplement(ImNorm(:,:,3))));
     
        % Set the ranges of the remaining parameters to explore
        
        %% Parameter 2: standard deviation of the Gaussian filter
        Std_Gaussian_Range = [4 10 16] ;
        
        %% Parameter 3: size of the averaging filter
        Size_Box_Range = 8;
        
        for s = 1 : length(Std_Gaussian_Range)
            
            Std_value = Std_Gaussian_Range(s);
            
            Eigs = EigenvaluesMap_Computation(ImVariousComponents(1).im,Std_value,Size_Box_Range);
            
            % Label the regions in the Eigs image that are nonzero
            L = bwlabel(Eigs > 0);
            Eigs_norm = ((Eigs - min(Eigs(:)>0)) / (max(Eigs(:)>0) - min(Eigs(:)>0)));
            % Compute the mean of each nonzero region that is obtained from the
            % previous step
            eigv_mv = zeros(max(L(:)),1);
            for l = 1 : max(L(:))
                bw_l = L == l;
                %eigv_mv(l) = .5*(mean(ImVariousComponents(1).im(bw_l>0)) + mean(Eigs_norm(bw_l>0)));
                eigv_mv(l) = mean(Eigs_norm(bw_l>0));
                
            end
            
            % Normalized the average intensties of the all the regions (note,
            % this is a vector)
            eigv_norm = ((eigv_mv - min(eigv_mv)) / (max(eigv_mv) - min(eigv_mv)));
            
            % Assign the mean values of each region to all the pixels in that
            % region
            Eigs_norm = zeros(size(Eigs));
            for l = 1 : max(L(:))
                bw_l = L == l;
                Eigs_norm(L == l) = eigv_norm(l);
            end
            
            % Obtain a suitable threshold using Otsu's method by streching the
            % normalized values from 0 to 255 and binarize the original image based on
            % the obtained threshold
            
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
            thresholdingMethodName = {'moments','ridler-calvard','RATS','OTSU'...
                ,'OTSU-Stretched','concavity' ...
                ,'ISO','entropy'};
            
            for k = 1:length(thresholdingMethodName)
                
                BW = im2bw(Eigs_norm,getThreshold( eigv_norm, thresholdingMethodName(k), 0, 0, 0 ));
                
                
                
                % Save the binary mask including the detected ROIs
                % obtained using the Red components (Normalized and not Normalized)
                % to perform union of the detected ROIs with the ones
                % obtained with the Blue components (Normalized and not Normalized)
                % Save the related results (TP FN FP)
                
                % Evaluate performance given the obtained binary masks,
                % BW, including the detected ROIs and the coordinates of the perimeter of the
                % actual mitosis, circle_coord.
                [tpSingle, fnSingle, fpSingle] = evaluate_performance(BW,circle_coord,1);
                
                TP(ImageNumber, s, k) = tpSingle;
                
                FN(ImageNumber, s, k) = fnSingle;
                
                FP(ImageNumber, s, k) = fpSingle;
                
                % %                     % Mix the results obtained from the Red and Blue
                % %                     % components
                % %                     switch Parameter1
                % %
                % %                         case 1
                % %
                % %                             BWcomponent1 = BW;
                % %
                % %                         case 2
                % %                             % Union of the results obtained with the Red and Blue components
                % %                             BWUnion = or(BWcomponent1,BW);
                % %                             [tp_SingleUnion, fn_SingleUnion, fp_SingleUnion] = evaluate_performance(BWUnion,circle_coord,0);
                % %
                % %                             TP(9).data(Parameter2,Parameter3,ImageNumber) = tp_SingleUnion;
                % %                             FN(9).data(Parameter2,Parameter3,ImageNumber) = fn_SingleUnion;
                % %                             FP(9).data(Parameter2,Parameter3,ImageNumber) = fp_SingleUnion;
                % %
                % %                         case 4
                % %
                % %                             BWcomponent1Norm = BW;
                % %                         case 5
                % %                             % Union of the results obtained with the Red and Blue components normalized
                % %                             BWUnionNorm = or(BWcomponent1Norm,BW);
                % %
                % %                             [tp_SingleUnionNorm, fn_SingleUnionNorm, fp_SingleUnionNorm] = evaluate_performance(BWUnionNorm,circle_coord,0);
                % %
                % %                             TP(10).data(Parameter2,Parameter3,ImageNumber) = tp_SingleUnionNorm;
                % %                             FN(10).data(Parameter2,Parameter3,ImageNumber) = fn_SingleUnionNorm;
                % %                             FP(10).data(Parameter2,Parameter3,ImageNumber) = fp_SingleUnionNorm;
                % %
                % %                     end
                
                
                
            end
            
            ImageNumber = ImageNumber + 1;
        end
    end
    
    
    
    % Removing unwanted variables from memory. [ssalehia: removed
    % ImVariousComponents due to memory issues after first test run]
    clear coord circle_coord row col BW BWUnion BWcomponent1 BWUnionNorm ImVariousComponents
%     save(sprintf('%d', ImageNumber), 'Eigs_norm', 'BW'); 
end


toc

%% Parameter1: Input Image

% 1: Red Component
% 2: Blue Component
% 3: Average of Red and Blue Components
% 4: Red Normalized Component
% 5: Blue Normalized Component
% 6: Average of Red and Blue Normalized Component
% 7: Green Component
% 8: Green Normalized Component
% 9: Union of the results obtained with the Red and Blue components
% 10: Union of the results obtained with the Normalized Red and Blue components

% 10 x 10 x 11

% % Inizialization
% precision = struct([]);
% recall = struct([]);
% f1_score = struct([]);
% 
% precisonBest = zeros(10,1);
% recallBest = zeros(10,1);
% f1_scoreBest = zeros(10,1);
% 
% 
% for Parameter1 = 1 : 10
%     
%     precision(Parameter1).data = sum( TP(Parameter1).data,3 ) ./( sum(TP(Parameter1).data,3) + sum(FP(Parameter1).data,3));
%     precisonBest(Parameter1) = max(max(precision(Parameter1).data));
%     
%     % Recall is the same as sensitivity
%     recall(Parameter1).data = sum( TP(Parameter1).data,3 ) ./ ( sum(TP(Parameter1).data,3) + sum(FN(Parameter1).data,3));
%     recallBest(Parameter1) = max(max(recall(Parameter1).data));
%     
%     f1_score(Parameter1).data = (2 * sum( TP(Parameter1).data,3 )) ./ ( (2 * sum( TP(Parameter1).data,3 ) )+ sum( FP(Parameter1).data,3 ) + sum( FN(Parameter1).data,3 ));
%     f1_scoreBest(Parameter1) = max(max(f1_score(Parameter1).data));
%     
% end


