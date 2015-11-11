%Crop the 20 patches in oecf chart
%
%  Input
%  *img: The oecf chart picture, can be the file path or loaded image(in RAM)
%
%  Output 
%  *grid: The 24 * 4 map of all coord of the cropped regions 

function grid=oecf_align(img)

    CROP_MARGIN = 10;
    
    if 2==size(size(img),2)
        %Looks like a file name
        img = imread(img);
    end

    [imgH, imgW, ~] = size(img);
    
    %There're some defects on the chart, we blurred it a little before
    %alignment
    bfilter = fspecial('disk', 7);
    blurred_pic= imfilter(img, bfilter);
    
    centX = imgW/2;
    centY = imgH/2;

    if check_color(blurred_pic(centY,centX,:), [0, 0, 0], 20)
        [cent, radius] = find_circle(blurred_pic, centX, centY, 20);

        if (radius <= imgH/15)
            %If the radius is very small, we consider only the small circle
            %is found/aligned
            centX = cent(1) - radius - 20;
            centY = cent(2) - radius - 20;
            disp('small circle');
        else
            %If the radius is big, we consider the big circle is
            %found/aligned
            centX = cent(1);
            centY = cent(2);
            disp('big circle');            
        end
    end

    [cent, radius] = find_circle(blurred_pic, centX, centY, 20);

    if 0==check_color(blurred_pic(cent(2), cent(1),:),[0 0 0], 20)
        disp('error');
        [l, t, r, b] = find_boundry(blurred_pic, centX, centY, 20);
        
        [cent, radius] = find_circle(blurred_pic, centX, t+10, 20);
        
        if 0==check_color(blurred_pic(cent(2), cent(1), :), [0 0 0],20)
            [cent, radius] = find_circle(blurred_pic, l+10, centY, 20);
        end
    end
    
    radius = radius*1.478;
        
    angles = [    31*pi/20 
     29*pi/20
         33*pi/20
     27*pi/20
         35*pi/20
     25*pi/20
         37*pi/20
     23*pi/20
         39*pi/20
     21*pi/20
         1*pi/20
     19*pi/20
         3*pi/20
     17*pi/20
         5*pi/20
     15*pi/20
         7*pi/20
     13*pi/20
         9*pi/20
     11*pi/20];
 
    grid = ones(20,4);
    

    for i=1:20
        centX = round(cent(1) + cos(angles(i))*radius);
        centY = round(cent(2) - sin(angles(i))*radius);
        grid(i,:) = [centX, centY, 0, 0];
    end
    
    for i=11:20
        [c, r] = find_circle(blurred_pic, grid(i,1), grid(i,2),20);
        grid(i,:) = [c(1)-r*1/2, c(2)-r*1/2, c(1)+r*1/2, c(2)+r*1/2];
        %The bottom part is too dark to align...
        grid(21-i,:) = [cent(1)*2-grid(i,3), cent(2)*2-grid(i,4), cent(1)*2-grid(i,1), cent(2)*2-grid(i,2)];
    end
    
end

function result=check_color(pixel, color, tolerence)
    COLOR(1,1,:) = uint8(color);
  
    [~, deltaP] = color_dist(pixel, COLOR);
    
    if deltaP > tolerence
        result = 0;
    else
        result = 1;
    end
end

function [cent, radius] = find_circle(img, centX, centY, tolerence)
    [l t r b] = find_boundry(img, centX, centY, tolerence);
    cent = round([(l+r)/2 (t+b)/2]);
    radius = round(sqrt(sum(([centX, t] - cent).^2)));
end

function [left, top, right, bottom] = find_boundry(img, centX, centY, tolerence)
    
    [imgH imgW colorChannel] = size(img);

    %Go left
    i=0;
    while i<centX
        [no_use, deltaP] = color_dist(img(centY, centX-i,:), img(centY,centX,:)); 
        
        if deltaP < tolerence
            i = i+1;
        else
            break;
        end
    end
    left = centX-i;
    
    i=0;
    while i<imgW-centX
        [no_use, deltaP] = color_dist(img(centY, centX+i,:), img(centY,centX,:)); 
        
        if deltaP < tolerence
            i = i+1;
        else
            break;
        end
    end
    right = centX+i;
    
    i=0;
    while i<centY
        [no_use, deltaP] = color_dist(img(centY-i,centX,:), img(centY,centX,:)); 
        if deltaP < tolerence
            i = i+1;
        else
            break;
        end
    end
    top = centY-i;
    
    i=0;
    while i<imgH-centY
        [no_use, deltaP] = color_dist(img(centY+i,centX,:), img(centY,centX,:)); 
        
        if deltaP < tolerence
            i = i+1;
        else
            break;
        end
    end
    bottom = centY+i;
end
