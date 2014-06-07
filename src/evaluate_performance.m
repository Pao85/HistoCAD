function [TP, FN, FP] = evaluate_performance(BW,circle_coord,flag_fig)

 % Get the size of the image
                    [row,col] = size(BW);
                   


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
                    mainGrdTruthMask = getGroundTruthMask( circle_coord,row,col );
                    grdTruthMask = mainGrdTruthMask;
                    
                    % Label the ground-truth mask
                    grdTruthMask_label = bwlabel(grdTruthMask);
                    
                    if flag_fig == 1
                    % To visually assess the result of ROI detection agains the
                    % ground-truth, use the following line.
                    figure;imshow(grdTruthMask);hold on;plot(ROI_centroids(:,2),ROI_centroids(:,1),'m*');
                    end
                    
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
                    
                  