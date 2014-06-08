% This script uses the eigen value map of the images to obtain regions of
% interest (ROI). It also evaluates the results of ROI detection using the
% provided ground-truth markings.
tic

% Inizialization
ImageNumber = 1;

circle_coord = struct([]); 
TP = struct([]); 
FN = struct([]); 
FP = struct([]);

for nf = 1 : 1%5
    
    % Change DBFolder to appropriate location on your computer.
    DBFolder = ['C:\Mitosis Detection Challenge\training_tiff_part1\scratchTesting',num2str(nf),'\'];
    
    f_tiff = dir([DBFolder,'*.tif']);
    f_csv = dir([DBFolder,'*.csv']);
    
    for n = 2 : 4%length(f_tiff)
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
  
        % Red component
        ImVariousComponents(1).im = im2double(imcomplement(Im(:,:,1)));
        % Blue component
        ImVariousComponents(2).im = im2double(imcomplement(Im(:,:,3)));
        % Average of Red and Blue components
        ImVariousComponents(3).im = .5*(ImVariousComponents(1).im + ImVariousComponents(2).im);
        % Red component
        ImVariousComponents(4).im = im2double(imcomplement(ImNorm(:,:,1)));
        % Normalized Blue component
        ImVariousComponents(5).im = im2double(imcomplement(ImNorm(:,:,3)));
        % Average of Normalized Red and Blue components
        ImVariousComponents(6).im = .5*(ImVariousComponents(4).im + ImVariousComponents(5).im);
        % Green component
        ImVariousComponents(7).im = im2double(imcomplement(Im(:,:,2)));
        % Normalized Green component
        ImVariousComponents(8).im = im2double(imcomplement(ImNorm(:,:,2)));
      
      
        % Set the ranges of the remaining parameters to explore
        
        %% Parameter 2: standard deviation of the Gaussian filter
        Std_Gaussian_Range = 2 : 2 : 20;
        
        %% Parameter 3: size of the averaging filter
        Size_Box_Range = 10 : 2 : 30;
        
        for Parameter1 = 1 : 8
            
            for Parameter2 = 1 : length(Std_Gaussian_Range)
                
                for Parameter3 = 1 : length(Size_Box_Range)
                    
                    Eigs = EigenvaluesMap_Computation(ImVariousComponents(Parameter1).im,Std_Gaussian_Range(Parameter2),Size_Box_Range(Parameter3));
                    
                    % Label the regions in the Eigs image that are nonzero
                    L = bwlabel(Eigs > 0);
                    
                    % Compute the mean of each nonzero region that is obtained from the
                    % previous step
                    eigv_mv = zeros(max(L(:)),1);
                    for l = 1 : max(L(:))
                        bw_l = L == l;
                        eigv_mv(l) = mean(Eigs(bw_l>0));
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
                    BW = im2bw(Eigs_norm,graythresh(eigv_norm*255));
                   
                    % Save the binary mask including the detected ROIs
                    % obtained using the Red components (Normalized and not Normalized)
                    % to perform union of the detected ROIs with the ones
                    % obtained with the Blue components (Normalized and not Normalized)
                    % Save the related results (TP FN FP)
                    
                    % Evaluate performance given the obtained binary masks,
                    % BW, including the detected ROIs and the coordinates of the perimeter of the
                    % actual mitosis, circle_coord. 
                    % figure;imshow(BW);
                    
                    [tpSingle, fnSingle, fpSingle] = evaluate_performance(BW,circle_coord,0);
                    
                    TP(Parameter1).data(Parameter2,Parameter3,ImageNumber) = tpSingle;
                    
                    FN(Parameter1).data(Parameter2,Parameter3,ImageNumber) = fnSingle;
                    
                    FP(Parameter1).data(Parameter2,Parameter3,ImageNumber) = fpSingle;
                    
                    % Mix the results obtained from the Red and Blue
                    % components
                    switch Parameter1
                        
                        case 1
                            
                            BWcomponent1 = BW;
                            
                        case 2
                            % Union of the results obtained with the Red and Blue components
                            BWUnion = or(BWcomponent1,BW);
                            [tp_SingleUnion, fn_SingleUnion, fp_SingleUnion] = evaluate_performance(BWUnion,circle_coord,0);
                            
                            TP(9).data(Parameter2,Parameter3,ImageNumber) = tp_SingleUnion;
                            FN(9).data(Parameter2,Parameter3,ImageNumber) = fn_SingleUnion;
                            FP(9).data(Parameter2,Parameter3,ImageNumber) = fp_SingleUnion;
                            
                        case 4
                            
                            BWcomponent1Norm = BW;
                        case 5
                            % Union of the results obtained with the Red and Blue components normalized
                            BWUnionNorm = or(BWcomponent1Norm,BW);
                            
                            [tp_SingleUnionNorm, fn_SingleUnionNorm, fp_SingleUnionNorm] = evaluate_performance(BWUnionNorm,circle_coord,0);
                           
                            TP(10).data(Parameter2,Parameter3,ImageNumber) = tp_SingleUnionNorm;
                            FN(10).data(Parameter2,Parameter3,ImageNumber) = fn_SingleUnionNorm;
                            FP(10).data(Parameter2,Parameter3,ImageNumber) = fp_SingleUnionNorm;
                            
                    end
                    
                      
                   
                end
                
            end
        end
        
        ImageNumber = ImageNumber + 1;
        
        % Removing unwanted variables from memory. [ssalehia: removed
        % ImVariousComponents due to memory issues after first test run]
        clear coord circle_coord row col BW BWUnion BWcomponent1 BWUnionNorm ImVariousComponents
        
    end
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

% Inizialization
precision = struct([]); 
recall = struct([]); 
f1_score = struct([]); 

precisonBest = zeros(10,1);
recallBest = zeros(10,1);
f1_scoreBest = zeros(10,1);


for Parameter1 = 1 : 10
    
precision(Parameter1).data = sum( TP(Parameter1).data,3 ) ./( sum(TP(Parameter1).data,3) + sum(FP(Parameter1).data,3));
precisonBest(Parameter1) = max(max(precision(Parameter1).data));                    

% Recall is the same as sensitivity
recall(Parameter1).data = sum( TP(Parameter1).data,3 ) ./ ( sum(TP(Parameter1).data,3) + sum(FN(Parameter1).data,3)); 
recallBest(Parameter1) = max(max(recall(Parameter1).data));                     

f1_score(Parameter1).data = (2 * sum( TP(Parameter1).data,3 )) ./ ( (2 * sum( TP(Parameter1).data,3 ) )+ sum( FP(Parameter1).data,3 ) + sum( FN(Parameter1).data,3 ));
f1_scoreBest(Parameter1) = max(max(f1_score(Parameter1).data));    

end               


