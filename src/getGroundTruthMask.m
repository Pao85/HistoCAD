function grdTruthMask = getGroundTruthMask( circle_coord,m,n )
%This function returns a binary image where a circle of radius 30 pixels is
%drawn is marked in white for each marked center in the ground truth. 

grdTruthMask = zeros(m,n);

for i = 1:length(circle_coord)

 tempMask = poly2mask(circle_coord(i).vec(:,2),circle_coord(i).vec(:,1),m,n);

 grdTruthMask = grdTruthMask + tempMask;

end

