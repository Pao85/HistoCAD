function [bw,cx,cy,Eigs] = detect_nuclei(im,n)
%% Input
%im: image
%n: maximum number of ROIs

%% Output
% bw: binary mask of detected  nuclei
% (cx,cy): coordinates of the centers of the detected nuclei
% Eigs: Node map


% nodal_analysis detect nodes based on the eigenvalues of the Hessian of a
% given image (im). Eigs is a matrix of nodes (node map).
Eigs = nodal_analysis_cg(im);

% assign_ranking ranks the detected nodes based on the average of the node
% map (Eigs). Only the first n ROIs are selected.
[bw,cx,cy] = assign_ranking(Eigs,n);



function Eigs = nodal_analysis_cg(roi_d)

% Filtersing stage 
roi_d2 = imfilter(roi_d,fspecial('gaussian',60,12),'circular');
roi_d2 = imfilter(roi_d2,fspecial('average',20),'circular');

% Hessian computation
[U,V] = gradient(roi_d2,1,1);
[Ux,Uy] = gradient(U,1,1);
[Vx,Vy] = gradient(V,1,1);

% Computation of the node map
Eigs = zeros(size(roi_d));

for i = 1 : size(roi_d,1)
    
    for j = 1 : size(roi_d,2)
        
        H1 = [Ux(i,j) Uy(i,j);Vx(i,j) Vy(i,j)];
        e = eig(H1);
        
        % Selection of nodes
        if  prod(e) > 0 && e(1) < 0 && isreal(e) == 1
            Eigs(i,j)=prod(e);
        end
        
    end
end


function [bw,cx,cy] = assign_ranking(Eigs,n_max)

cx = zeros(1,n_max);
cy = zeros(1,n_max);
bw = Eigs>0;

L = bwlabel(bw);

% Criterion for ranking based on the average of the Eigenvalues map
M = cell2mat(struct2cell(regionprops(bw,Eigs,'MeanIntensity')));

x=sortrows([M' (1:length(M))']);
x=x(end:-1:1,:);

% Include only n_max candidates
for k = n_max+1 : length(x(:,1))
    bw(L(:)==x(k,2))=0;
end
clear x M;

% Mean values of the node map on each ROI
M = cell2mat(struct2cell(regionprops(logical(bw),Eigs,'MeanIntensity')));
ch = regionprops(bw,'ConvexHull');

x=sortrows([M' (1:length(M))']);
x=x(end:-1:1,:);

% Coordinates of the centers of the ROIs
for i = 1 : length(ch)
    cx(i)=round(mean(ch(x(i,2)).ConvexHull(:,1)));
    cy(i)=round(mean(ch(x(i,2)).ConvexHull(:,2)));
end
