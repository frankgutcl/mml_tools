%Calculate the color distance(diff) between two pixels
%
%  Input
%  *pixelA/pixelB: the pixel is a 3-dimensional or 2-demension, represented in RGB
%                 8 bit
%
%  Output 
%  *deltaV: The difference value of pixelA & pixelB
%  *deltaP: The difference percentage of pixelA & pixelB

function [deltaV, deltaP]=color_dist(pixelA, pixelB)

if 3==size(size(pixelA),2)
    %For 3-d RGB value
    colorA = int32([pixelA(1,1,1), pixelA(1,1,2), pixelA(1,1,3)]);
else
    %For 2-d RGB val
    colorA = int32(pixelA);
end

if 3==size(size(pixelB),2)
    colorB = int32([pixelB(1,1,1), pixelB(1,1,2), pixelB(1,1,3)]);
else
    colorB = int32(pixelB);
end

deltaV = sqrt(sum((colorA-colorB).^2));
deltaP = deltaV*100/(1.7321*255);
end