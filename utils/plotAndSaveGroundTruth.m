% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %  A script to read and plot the locations of mitosis as indicated
% %  in the the CSV files of training set.
% %  Note that when saving the new figure, MATLAB some how changes 
% %  the resolution of the image and adds a white border to it. I didn't
% %  fuss over this too much since these will only be for our viewing reference. 
% %  See help for 'print' for more details on saving the images.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


% Change DBFolder to appropriate location on your computer.
DBFolder = 'C:\Mitosis Detection Challenge';

% Setting up the subfolders.
mainFolder1 = sprintf('%s\\training_tiff_part1',DBFolder);
mainFolder2 = sprintf('%s\\training_tiff_part2',DBFolder);

% Some images don't have mitosis; I'm only including the ones that do.
listOfCases1{1} = 1:39;
listOfCases1{2} = 1:28;
listOfCases1{3} = 1:16;
listOfCases1{4} = 1:61;
listOfCases1{5} = [1:4 8:9];

listOfCases2{6} = 1:61;
listOfCases2{7} = 1:43;
listOfCases2{8} = [3 6 9];
listOfCases2{9} = [2 6];
listOfCases2{10} = [];
listOfCases2{11} = 1:13;
listOfCases2{12} = [1:4 6:8];

% First subfolder
for i = 1:length(listOfCases1)
    for j = 1:length(listOfCases1{i})
        
        CSV_fileName = sprintf('%s\\%02d\\%02d.csv',mainFolder1,i,listOfCases1{i}(j));
        TIFF_fileName = sprintf('%s\\%02d\\%02d.tif',mainFolder1,i,listOfCases1{i}(j));
        
        coord = csvread(CSV_fileName);
        img = imread(TIFF_fileName);
        
        h=figure;imshow(img);hold on;
        for k = 1:size(coord,1)
            % See help for 'LineSpec' for more plotting options.
            plot(coord(k,2),coord(k,1),'g*')
        end
        hold off;
        
        % The statement for saving the annotated file. Comment this line you 
        % just want to view the image. Change mainFolder1 if need to save
        % to a differet folder.
        print(h,'-dtiffn',sprintf('%s\\%02d\\%02d_annotated.tif',mainFolder1,i,listOfCases1{i}(j)));
        
        % Comment if you don't want to close the image.
        close(h);
        
    end
end

% Second subfolder
for i = 6:length(listOfCases2)
    % The if stmt is to bypass folder 10 which doesn't include any mitotic
    % figures.
    if ~isempty(listOfCases2{i})
        for j = 1:length(listOfCases2{i})
            
            CSV_fileName = sprintf('%s\\%02d\\%02d.csv',mainFolder2,i,listOfCases2{i}(j));
            TIFF_fileName = sprintf('%s\\%02d\\%02d.tif',mainFolder2,i,listOfCases2{i}(j));
            
            coord = csvread(CSV_fileName);
            img = imread(TIFF_fileName);
            
            h=figure;imshow(img);hold on;
            for k = 1:size(coord,1)
                % See help for 'LineSpec' for more plotting options. The
                % first column in the CSV file is the row, and the second
                % column is the column coordinate.
                plot(coord(k,2),coord(k,1),'g*')
            end
            hold off;
            
            % The statement for saving the annotated file. Comment this line you
            % just want to view the image. Change mainFolder1 if need to save
            % to a differet folder.
            print(h,'-dtiffn',sprintf('%s\\%02d\\%02d_annotated.tif',mainFolder2,i,listOfCases2{i}(j)));
            
            % Comment if you don't want to close the image.
            close(h);
            
        end
    end
end
        