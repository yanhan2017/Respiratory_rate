%% Read video frames and convert into grayscale
% video = VideoReader('woman_face.mp4');
% nframe = 254;
% for img = 1:nframe
%     filename=strcat('frame',num2str(img),'.png');
%     b = read(video, img);
%     imwrite(b,filename);
% end
% 
% for img = 1:nframe-1
%     RGB = imread(strcat('frame',num2str(img+1),'.png'));
%     b = rgb2gray(RGB);
%     filename = strcat('gray_frame',num2str(img),'.png');
%     imwrite(b,filename);
% end
%% Select a template in the first frame and do cross correlation
% template = imread('template1.png');
% max_position = zeros(nframe,2);
% for img = 1:nframe
%    I = imread(strcat('gray_frame', num2str(img),'.png'));
%    A = normxcorr2(template,I);
%    maximum = max(max(A));
%    [x,y] = find(A==maximum);
%    max_position(img,:) = [x,y];
% end
% img = imread('gray_frame1.png');
% box1 = [206 257 50 31];
% img1 = insertShape(img,'Rectangle',box1);
% imshow(img1)
% 
% points = detectMinEigenFeatures(img, 'ROI', box1);
% figure, imshow(img1), hold on, title('Detected features');
% plot(points);
% points = points.Location;
% 
% tracker_forward = vision.PointTracker;
% tracker_backward = vision.PointTracker;
% initialize(tracker_forward, points, I1);
% points2 = tracker_forward(I2);
% initialize(tracker_backward, points2, I2);
% points11 = tracker_backward(I1);    %points in later frame tracked back to former frame
% 
% distance = zeros(size(points(:,1)));
% for i = 1:size(points(:,1))
%    distance(i) = norm(points(i,:)-points11(i,:));
% end
% 
% median = median(distance);
% score = (distance <= median);
% points_new = 
% len = length(points1_new(:,1));
% distance1 = [];
% distance2 = [];
% for i = 1:len
%     for j = i+1:len
%         distance1 = [distance1 norm(points1_new(i,:)-points1_new(j,:))];
%         distance2 = [distance2 norm(points2_new(i,:)-points2_new(j,:))];
%     end
% end
% scale = median(distance2)/median(distance1);
% 
% objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');
% figure;
% imshow(objectImage);

%
%for walk video
%box1 = [206 255 50 33];
%box10 = [204 255 43 20];
%box55 = [160 168 43 31];
%box70 = [146 148 44 25];
%136, 80, 40, 40 for walk_and_meet

%for woman_face
%box13 = [579 302 80 50];
video = VideoReader('Video/PIR-206_14.mov');
%bbox = [236 139 90 60]; %for PIR-206_13.mov
bbox = [261 173 120 55];
I1 = readFrame(video);
[I1,Gdir] = imgradient(rgb2gray(I1));
I1 = uint8(I1);
i = 0;
while hasFrame(video)
    i = i+1;
    if(i == 40)
        ;
    end
    I2 = readFrame(video);
    [I2 Gdir] = imgradient(rgb2gray(I2));
    I2 = uint8(I2);
    [bbox ok] = box_update(I1,I2,bbox);
    if(ok)
        I1 = I2;
        objectImage = insertShape(I2,'Rectangle',bbox,'Color','red');
        imshow(objectImage);
    else
        
    end
%     ROI = imcrop(I2,bbox);
%     imshow(ROI);
end
% for img = 13:200
% filename=strcat('frame',num2str(img),'.png');
% I1 = imread(filename);
% I2 = imread(strcat('frame',num2str(img+1),'.png'));
% box13 = box_update(I1,I2,box13);
% end

%% visulize data
for i = 1:length(TrackingT(1,1,:))
min_value = min(min(TrackingT(1:30,1:30,i)));
max_value = max(max(TrackingT(1:30,1:30,i)));
diff = max_value-min_value;
imshow(uint8((TrackingT(1:30,1:30,i)-min_value).*(255/diff)))
end