%Crop the region of "same" color in the image
%
%  Input
%  *img: The input image in RGB
%  *centX: The reference center in x-axis
%  *centY: The reference center in y-axis
%  *step: The hint search step to accelerate the search performance. Note
%         that this would impact the search result probably. large
%         step->quicker but not accurate crop, small step->slower but more
%         accurate crop
%  *maxW: The max width to crop
%  *maxH: The max height to crop
%  *maxDelta: The tolerance in percentage(of color difference) to crop
%  *margin: The "safe" margin left to the border, the margin is sometimes
%            introduced for rotate/pitch/yaw
%  *fineSearch: specify if we are in fine search, otherwise a fine search
%               is always performed
%  *color: Specify the benchmark color, otherwise we just use the color at
%               [centY, centX]
%
%  Output 
%  *left/top/right/bottom: the cood of cropped image 


function [left, top, right, bottom] = color_region(img, centX, centY, step, maxW, maxH, maxDelta, margin, fineSearch, color)

if nargin<10
    color = 0;
end

if nargin<9
    fineSearch = 0;
end

[imgH, imgW, ~] = size(img);

startX = centX - maxW + 1;
endX = centX + maxW - 1;

if startX<1
    startX=1;
end

if endX>imgW
    endX=imgW;
end

%Retreive the delta map in horizontal and vertical
hDelta = [];
vDelta = [];

for i=startX:step:endX
    if color
        [~, hDelta(end+1)] = color_dist(color, img(centY,i,:)); %#ok<AGROW>
    else
        [~, hDelta(end+1)] = color_dist(img(centY,centX,:),img(centY,i,:)); %#ok<AGROW>
    end
end

startY = centY - maxH + 1;
endY = centY + maxH - 1;

if startY<1
    startY=1;
end

if endY>imgH
    endY=imgH;
end

for j=startY:step:endY
    if color
        [~, vDelta(end+1)] = color_dist(color, img(j,centX,:)); %#ok<AGROW>
    else
        [~, vDelta(end+1)] = color_dist(img(centY,centX,:),img(j,centX,:)); %#ok<AGROW>
    end
end

%We estimate the shape of the curve is single peak in the center
%Set the left & right as center of min-difference
leftIndex = round((centX-startX)/step);
rightIndex = leftIndex;

while (rightIndex-leftIndex)*step < maxW
    
    leftAvail = false;
    rightAvail = false;
    
    if (leftIndex>1) && (hDelta(leftIndex-1)<maxDelta)
        leftAvail = true;
    end
    
    if (rightIndex<size(hDelta,2)) && (hDelta(rightIndex+1)<maxDelta)
        rightAvail = true;
    end
    
    if leftAvail==true && rightAvail==false
        leftIndex = leftIndex - 1;
    elseif rightAvail==true && leftAvail==false
        rightIndex = rightIndex + 1;
    elseif leftAvail==true && rightAvail==true
        if hDelta(leftIndex-1) < hDelta(rightIndex+1)
            leftIndex = leftIndex - 1;
        else
            rightIndex = rightIndex + 1;
        end
    else
        break;
    end
end

left = startX+leftIndex*step+(step-1)+margin;
right = startX+rightIndex*step-(step-1)-margin;

if (left>right) 
    %Cannot leave enough margin, degression to the center
    left = centX;
    right = centX;
end

%We estimate the shape of the curve is single peak in the center
%Set the top & bottom as center of min-difference
topIndex = round((centY-startY)/step);
bottomIndex = topIndex;

while (bottomIndex-topIndex)*step < maxH
    topAvail = false;
    bottomAvail = false;
    
    if (topIndex>1) && (vDelta(topIndex-1)<maxDelta)
        topAvail = true;
    end
    
    if (bottomIndex<size(vDelta,2)) && (vDelta(bottomIndex+1)<maxDelta)
        bottomAvail = true;
    end
    
    if topAvail==true && bottomAvail==false
        topIndex = topIndex - 1;
    elseif topAvail==false && bottomAvail==true
        bottomIndex = bottomIndex + 1;
    elseif topAvail==true && bottomAvail==true
        if vDelta(topIndex-1) >= vDelta(bottomIndex+1)
            topIndex = topIndex-1;
        else
            bottomIndex = bottomIndex + 1;
        end
    else
        break;
    end
end

top = startY+topIndex*step+(step-1)+margin;
bottom = startY+bottomIndex*step-(step-1)-margin;

if top>bottom
   top = centY;
   bottom = centY;
end

if ~fineSearch
    %do fine search
    [left, top, right, bottom] = color_region(img, centX, centY, step, maxW, maxH, maxDelta, margin, 1, mean(mean(img(top:bottom,left:right,:))));
end

end