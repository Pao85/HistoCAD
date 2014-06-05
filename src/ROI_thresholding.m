% This script uses the eigen value map of the images to obtain regions of
% interest (ROI). It also evaluates the results of ROI detection using the
% provided ground-truth markings.
tic
clear all
close all

% Set the subfolder where the .mat files are stored
dir_data = 'C:\Mitosis Detection Challenge\training_tiff_part1\01\';

% get all .mat files in the specified subfolder
f = dir([dir_data,'*.mat']);

% n indicates the number 'name' of image
for n = 1 : 1%length(f)
    
    % Load only the eigen value maps 'Eigs' from the .mat files.
    load([dir_data,f(n).name],'Eigs','circle_coord');
    
    % Get the size of the image
    [row,col] = size(Eigs(1).im);
    
    % Eigs is a struct that contains 6 fields; one for each RGB component
    % and their normalized counter parts (1-R, 2-G, 3-B, 4-R_norm,
    % 5-G_norm, 6-B_norm).
    for i = 1 : 1
        
% %         % Show all pixels in the Eigs image that are nonzero
% %         figure();imshow(Eigs(i).im>0,[])
% %         
% %         % Global mean of the regions that are nonzero
% %         eigv_m = mean(Eigs(i).im(Eigs(i).im(:)>0));
% %         % Global standard deviation of the regions that are nonzero
% %         eigv_std = std(Eigs(i).im(Eigs(i).im(:)>0));
% %         
% %         % Threshold based on the global mean
% %         BW = Eigs(i).im > eigv_m;
        
        % Label the regions in the Eigs image that are nonzero
        L = bwlabel(Eigs(i).im > 0);
        
        % Compute the mean of each nonzero region that is obtained from the
        % previous step
        eigv_mv = zeros(max(L(:)),1);        
        for l = 1 : max(L(:))
            bw_l = L == l;
            eigv_mv(l) = mean(Eigs(i).im(bw_l>0));            
        end
        
        % Normalized the average intensties of the all the regions (note,
        % this is a vector)
        eigv_norm = ((eigv_mv - min(eigv_mv)) / (max(eigv_mv) - min(eigv_mv)));
        
        % Assign the mean values of each region to all the pixels in that 
        % region
        Eigs_norm = zeros(size(Eigs(i).im));    
        for l = 1 : max(L(:))
            bw_l = L == l;
            Eigs_norm(L == l) = eigv_norm(l);
        end
        
        % Obtain a suitable threshold using Otsu's method by streching the 
        % normalized values from 0 to 255 and binarize the image based on 
        % the obtained threshold 
        BW = im2bw(Eigs_norm,graythresh(eigv_norm*255));
        figure;imshow(BW);
        
        % Label the thresholded ROIs 
        L = bwlabel(BW);
        
        % Obtain the labels (number) for each ROI except label zero
        ROI_labels = unique(L); ROI_labels=ROI_labels(ROI_labels>0);
        
        % Obtain the centroid of each ROI
        ROI_centroids = zeros(length(ROI_labels),2);
        for k = 1:length(ROI_labels)
            [r,c] = find(L == ROI_labels(k));
            % First column of ROI_centroids is the row index
            ROI_centroids(k,1) = round(mean(r));
            % Second column of ROI_centroids is the column index
            ROI_centroids(k,2) = round(mean(c));
        end
            
        % Get a binary mask indicating the marked sites of mitosis as the
        % ground-truth. (White circles as the sites)
        grdTruthMask = getGroundTruthMask( circle_coord,row,col );
        
        % Label the ground-truth mask
        grdTruthMask_label = bwlabel(grdTruthMask);
        
        % To visually assess the result of ROI detection agains the
        % ground-truth, use the following line.
        figure;imshow(grdTruthMask);hold on;plot(ROI_centroids(:,2),ROI_centroids(:,1),'m*');
        
        % The total number of actually positive cases is equal to number of
        % circles
        AP = length(circle_coord);        
        FP = 0;
        TP = 0;
        
        % For every ROI centroid, if the corresponding pixel in the
        % ground-truth mask is equal 1, then that ROI is a TP; otherwise, it
        % a FP. If a TP, then remove the corresponding ground-truth circle
        % (site) so that it will not lead to another incorrect TP detection. 
        for k = 1:length(ROI_labels)

            TP = TP + grdTruthMask(ROI_centroids(k,1),ROI_centroids(k,2));                   
            
            if grdTruthMask(ROI_centroids(k,1),ROI_centroids(k,2))
                % Find the ground-truth label of the pixel that is equal to
                % 2                
                grdTruthLabelToRemove = grdTruthMask_label(ROI_centroids(k,1),ROI_centroids(k,2));
                % Set the entire region in ground-truth mask equal to zero
                % so that it will not lead to another TP
                grdTruthMask(grdTruthMask_label==grdTruthLabelToRemove) = 0;
            else
                FP = FP + 1;
            end
            
        end
        
        % Define the quantitative metrics to evaluate the results of ROI
        % deteciton.
        
        % False negative
        FN = AP - TP;
        
        sensitivity = TP/AP;
        
        percision = TP/(TP+FP);
        
        recall = TP / (TP + FN);
        
        f1_score = (2 * TP) / ( (2 * TP )+ FP + FN);
        
    end
end
toc