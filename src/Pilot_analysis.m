% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %  A script to read and plot circles around locations of mitosis as indicated
% %  in the the CSV files of training set.
% %  The R, G, and B components are plotted separately in both the original 
% %  and the normalized version (which is using normalizeStaining.m script)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear all
close all

flag_fig = 0;
for nf = 2 : 5

% Change DBFolder to appropriate location on your computer.
DBFolder = ['C:\Users\Paola\Documents\MATLAB\ENTERPRISE\Pilot\training_tiff_part1\0',num2str(nf),'\'];

f_tiff = dir([DBFolder,'*.tif']);
f_csv = dir([DBFolder,'*.csv']);

for n = 1 : length(f_tiff)
disp([num2str(n),'/',num2str(nf)])    
TIFF_fileName = f_tiff(n).name;
CSV_fileName = f_csv(n).name;

I1 = imread([DBFolder,TIFF_fileName]);
[Inorm1 H1 E1] = normalizeStaining(I1);
coord = csvread([DBFolder,CSV_fileName]);

for i = 1 : size(coord,1)
    
    circle1 = zeros(size(I1,1),size(I1,2));
    circle1(coord(i,1),coord(i,2)) =1;
    [p1 p2] = find(bwdist(circle1)<30,1,'first');
    circle_coord(i).vec = bwtraceboundary(bwdist(circle1)<30,[p1 p2],'E');
    
end

%%
if flag_fig
    figure;
    set(gcf, 'Position', get(0, 'ScreenSize'));
    title('Original images')
    subplot(2,3,1);imshow(imcomplement(I1(:,:,1)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
    
    subplot(2,3,2);imshow(imcomplement(I1(:,:,2)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
    subplot(2,3,3);imshow(imcomplement(I1(:,:,3)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
    subplot(2,3,4);imshow(imcomplement(Inorm1(:,:,1)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
    subplot(2,3,5);imshow(imcomplement(Inorm1(:,:,2)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
    subplot(2,3,6);imshow(imcomplement(Inorm1(:,:,3)));
    for k = 1 : size(coord,1)
        hold on
        plot(circle_coord(k).vec(:,2),circle_coord(k).vec(:,1),'g')
        
    end
end
%%
n_max = 100;

[bw(1).im,cx(1).vec,cy(1).vec,Eigs(1).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,1))),n_max);
[bw(2).im,cx(2).vec,cy(2).vec,Eigs(2).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,2))),n_max);
[bw(3).im,cx(3).vec,cy(3).vec,Eigs(3).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,3))),n_max);
[bw(4).im,cx(4).vec,cy(4).vec,Eigs(4).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,1))),n_max);
[bw(5).im,cx(5).vec,cy(5).vec,Eigs(5).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,2))),n_max);
[bw(6).im,cx(6).vec,cy(6).vec,Eigs(6).im] = detect_nuclei(im2double(imcomplement(Inorm1(:,:,3))),n_max);

% Plot preliminary results
for ni = 1 : 6
L = bwlabel(bw(ni).im);
for i = 1 : 10
    
    MitosisCandidateBw = L == L(cy(ni).vec(i),cx(ni).vec(i));
    
    [p1(i) p2(i)] = find(MitosisCandidateBw,1,'first');
    MitosisCandidate(ni).coord(i).vec = bwtraceboundary(MitosisCandidateBw,[p1(i) p2(i)],'E');
    
end
end

%%
if flag_fig
    figure;
    set(gcf, 'Position', get(0, 'ScreenSize'));
    title('Original images')
    subplot(2,3,1);imshow(imcomplement(I1(:,:,1)));
    for k = 1 : size(MitosisCandidate(1).coord,2)
        hold on
        plot(MitosisCandidate(1).coord(k).vec(:,2),MitosisCandidate(1).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
    
    subplot(2,3,2);imshow(imcomplement(I1(:,:,2)));
    for k = 1 : size(MitosisCandidate(2).coord,2)
        hold on
        plot(MitosisCandidate(2).coord(k).vec(:,2),MitosisCandidate(2).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
    subplot(2,3,3);imshow(imcomplement(I1(:,:,3)));
    for k = 1 : size(MitosisCandidate(3).coord,2)
        hold on
        plot(MitosisCandidate(3).coord(k).vec(:,2),MitosisCandidate(3).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
    subplot(2,3,4);imshow(imcomplement(Inorm1(:,:,1)));
    for k = 1 : size(MitosisCandidate(4).coord,2)
        hold on
        plot(MitosisCandidate(4).coord(k).vec(:,2),MitosisCandidate(4).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
    subplot(2,3,5);imshow(imcomplement(Inorm1(:,:,2)));
    for k = 1 : size(MitosisCandidate(5).coord,2)
        hold on
        plot(MitosisCandidate(5).coord(k).vec(:,2),MitosisCandidate(5).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
    subplot(2,3,6);imshow(imcomplement(Inorm1(:,:,3)));
    for k = 1 : size(MitosisCandidate(6).coord,2)
        hold on
        plot(MitosisCandidate(6).coord(k).vec(:,2),MitosisCandidate(6).coord(k).vec(:,1),'m','LineWidth',2)
        
    end
end
%%
DataFolder = ['C:\Users\Paola\Documents\MATLAB\ENTERPRISE\Pilot\Data_training_part1\0',num2str(nf),'\'];
save([DataFolder,f_csv(n).name(1:2),'.mat'],'I1','Inorm1','circle_coord','MitosisCandidate','bw','cx','cy','Eigs')

clearvars -except nf n f_tiff f_csv flag_fig DBFolder DataFolder

%pause();
close all
end
end
%%

%[r, g, b] = componentInCorrespondingColor(I1);


              