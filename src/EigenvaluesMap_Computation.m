function Eigs = EigenvaluesMap_Computation(roi_d,std_gaussian,box_size)

% Filtersing stage 
roi_d2 = imfilter(roi_d,fspecial('gaussian',5*std_gaussian,std_gaussian),'circular');
roi_d2 = imfilter(roi_d2,fspecial('average',box_size),'circular');

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