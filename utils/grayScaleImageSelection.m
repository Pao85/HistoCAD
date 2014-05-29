
img = imread('C:\Mitosis Detection Challenge\training_tiff_part1\01\22.tif');
CSV_fileName = 'C:\Mitosis Detection Challenge\training_tiff_part1\01\22.csv';
coord = csvread(CSV_fileName);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
Q = 0.212*R-0.523*G+0.311*B;
half_half = 0.5*R+0.5*B;
Q = double(Q);
MAX = max(Q(:));
MIN = min(Q(:));
normQ = (Q-MIN)./(MAX-MIN);
normQ = normQ * 255;
normQ = uint8(normQ);


halfHalf_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'entropy', 0, 0, 0);
halfHalf_bwImg = bwareaopen(halfHalf_bwImg,30);

red_bwImg = normalizeAndBinarizeGrayImg( R, imcomplement(double(R)), ones(size(R)),...
    'entropy', 0, 0, 0);
red_bwImg = bwareaopen(red_bwImg,30);

Q_bwImg = normalizeAndBinarizeGrayImg( Q, imcomplement(double(Q)), ones(size(Q)),...
    'entropy', 0, 0, 0);
Q_bwImg = bwareaopen(Q_bwImg,30);


figure;
subplot(3,3,1);imshow(imcomplement(R),[]);title('Red');hold on;
        for k = 1:size(coord,1)
            % See help for 'LineSpec' for more plotting options.
            plot(coord(k,2),coord(k,1),'g*')
        end
        hold off;
subplot(3,3,2);imshow(imcomplement(normQ),[]);title('Normalized Q');hold on;
        for k = 1:size(coord,1)
            % See help for 'LineSpec' for more plotting options.
            plot(coord(k,2),coord(k,1),'g*')
        end
        hold off;
subplot(3,3,3);imshow(imcomplement(half_half),[]);title('Half Red, Half Blue');hold on;
        for k = 1:size(coord,1)
            % See help for 'LineSpec' for more plotting options.
            plot(coord(k,2),coord(k,1),'g*')
        end
        hold off;

subplot(3,3,4);imhist(imcomplement(R));
subplot(3,3,5);imhist(imcomplement(normQ));
subplot(3,3,6);imhist(imcomplement(half_half));

subplot(3,3,7);imshow(red_bwImg);
subplot(3,3,8);imshow(Q_bwImg);
subplot(3,3,9);imshow(halfHalf_bwImg);

RC_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'ridler-calvard', 0, 0, 0);
RC_bwImg = bwareaopen(RC_bwImg,30);

RATS_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'RATS', 0, 0, 0);
RATS_bwImg = bwareaopen(RATS_bwImg,30);

ISO_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'ISO', 0, 0, 0);
ISO_bwImg = bwareaopen(ISO_bwImg,30);

CON_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'concavity', 0, 0, 0);
CON_bwImg = bwareaopen(CON_bwImg,30);

MO_bwImg = normalizeAndBinarizeGrayImg( half_half, imcomplement(double(half_half)), ones(size(half_half)),...
    'moments', 0, 0, 0);
MO_bwImg = bwareaopen(MO_bwImg,30);

figure;
subplot(2,3,1);imshow(halfHalf_bwImg);
subplot(2,3,2);imshow(RC_bwImg);
subplot(2,3,3);imshow(RATS_bwImg);
subplot(2,3,4);imshow(ISO_bwImg);
subplot(2,3,5);imshow(CON_bwImg);
subplot(2,3,6);imshow(MO_bwImg);
