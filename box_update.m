function [box2 ok] = box_update(I1,I2,box1)
ok = true;
if(box1(1) < 0)
    box1(1) = 1;
    disp('adjusted box1(1)');
end
if(box1(2) < 0)
    box1(2) = 1;
    disp('adjusted box1(2)');
end
if(box1(3)+box1(1) > length(I1(1,:,1)))
    box1(3) = length(I1(1,:,1)) - box1(1);
    disp('adjusted box1(3)');
end
if(box1(4)+box1(2) > length(I1(:,1,1)))
    box1(4) = length(I1(:,1,1)) - box1(2);
    disp('adjusted box1(4)');
end

% points = detectMinEigenFeatures(rgb2gray(I1),'ROI',box1);
% points1 = points.Location;

%find 10*10 points uniformly distributed in box, leaving margin of 5
[x, y] = meshgrid(linspace(box1(1)+5,box1(1)+box1(3)-5,10),linspace(box1(2)+5,box1(2)+box1(4)-5,10));
points1 = zeros(10,10,2);
points1(:,:,1) = x;
points1(:,:,2) = y;
points1 = reshape(points1,100,2);

tracker_forward = vision.PointTracker;
tracker_backward = vision.PointTracker;
initialize(tracker_forward, points1, I1);
points2 = tracker_forward(I2);
initialize(tracker_backward, points2, I2);
points11 = tracker_backward(I1); 

%FB
FB_error = zeros(size(points1(:,1)));
for i = 1:size(points1(:,1))
   FB_error(i) = norm(points1(i,:)-points11(i,:));
end

med = median(FB_error);
score_FB = (FB_error <= med);  %best performing 50% points in FB

%NCC
%take submatrices around each point
NCC = zeros(size(points1(:,1)));
for i = 1:size(points1(:,1))
    
%     if(round(points1(i,1))-4 < 0 || round(points1(i,1))+5 >= length(gray1(1,:)) || round(points1(i,2))-4 < 0 || round(points1(i,2))+5 > length(gray1(:,1)))
%         A = zeros(19,19);
%         break;
%     end
    subplot1 = I1(round(points1(i,1))-4:round(points1(i,1))+5, round(points1(i,2))-4:round(points1(i,2))+5);
    if(range(range(subplot1))==0)
        A = zeros(19,19);
        break;
    end
    
    if(round(points2(i,1))-4 < 0 || round(points2(i,1))+5 >= length(I2(1,:))|| round(points2(i,2))-4 < 0 || round(points2(i,2))+5 > length(I2(:,1)))
        A = zeros(19,19);
        break;
    end
    subplot2 = I2(round(points2(i,2))-4:round(points2(i,2))+5,round(points2(i,1))-4:round(points2(i,1))+5);
    if(sum(sum(subplot1==subplot2)) >= 80)
        A = ones(19,19);
    else
        A = normxcorr2(subplot1,subplot2);
    end
    NCC(i) = max(max(A));
end

med = median(NCC);
if(med==0)
    med = mean(NCC);
end
score_NCC = (NCC > med);
score = score_NCC & score_FB;

if(sum(score) <= 10)
    ok = false;
    box2 = [0 0 0 0];
    display('Target Lost');
    return;
end

points2_new = points2(score,:);
points1_new = points1(score,:);

len = length(points1_new(:,1));
if(len == 0)
    displacement = [0 0];
else
    displacement = median(points2_new,1)-median(points1_new,1);
end


distance1 = [];
distance2 = [];
for i = 1:len
    for j = i+1:len
        distance1 = [distance1 norm(points1_new(i,:)-points1_new(j,:))];
        distance2 = [distance2 norm(points2_new(i,:)-points2_new(j,:))];
    end
end

if(isnan(median(distance1)))
    scale = 1;
else
    scale = median(distance2)/median(distance1);
end
scale = 1;
box2 = [box1(1:2)+[displacement(1) displacement(2)] box1(3:4)*scale];


% hold on
% scatter(points1(:,1),points1(:,2),'o');
% hold off



