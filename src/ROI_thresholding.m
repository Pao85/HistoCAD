clear all
close all

dir_data = 'C:\Users\Paola\Documents\MATLAB\ENTERPRISE\Pilot\Data_training_part1\01\';

f = dir([dir_data,'*.mat']);

for n = 1 : 1%length(f)
    load([dir_data,f(n).name],'Eigs')
for i = 1 : 1
    
     figure();imshow(Eigs(i).im>0,[])
     
     eigv_m = mean(Eigs(i).im(Eigs(i).im(:)>0));
     eigv_std = std(Eigs(i).im(Eigs(i).im(:)>0));
     
     BW = Eigs(i).im > eigv_m;
     
     
     
     
     L = bwlabel(Eigs(i).im > 0);
     
     for l = 1 : max(L(:))
         bw_l = L == l;
         eigv_mv(l) = mean(Eigs(i).im(bw_l>0));
     end
   
     eigv_norm = ((eigv_mv - min(eigv_mv)) / (max(eigv_mv) - min(eigv_mv))); 
     
     th = graythresh(eigv_norm*255);
     
      
     Eigs_norm = Eigs(i).im;
      for l = 1 : max(L(:))
         bw_l = L == l;
         Eigs_norm(L == l) = eigv_norm(l);
      end
      
      BW = im2bw(Eigs_norm,th);
end
end  