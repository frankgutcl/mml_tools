%To extract the PD map(iamge) and compensate the raw image 
%
% Input
% * raw_image: The raw image 
% * pd_pattern: The PD pattern, currently only support "3m2"
% 
% Output
% * left: The image for left-covered
% * right: The image for right-covered
% * comp_raw: The compensated (BPCed) raw image
function [left, right, comp_raw] = raw_pd_extract(raw_image, pd_pattern)
    
    if strcmpi(pd_pattern, '3m2')
        data = load('3m2_pd_pattern.mat');
        pd = data.pd;
    else
        disp('Unsupported PD pattern');
        return;
    end
    
    left = zeros(pd.repeat.y, pd.repeat.x);
    right = zeros(pd.repeat.y, pd.repeat.x);
    
    comp_raw = raw_image;
    
    for row=1:pd.repeat.y
        for col=1:pd.repeat.x
            for i=1:size(pd.pattern, 1)
                for j=1:size(pd.pattern, 2)
                    x = pd.margin.x + ((col-1)*size(pd.pattern, 2) + j-1)*pd.block.x + pd.left_pat(pd.pattern(i,j), 1);
                    y = pd.margin.y + ((row-1)*size(pd.pattern, 1) + i-1)*pd.block.y + pd.left_pat(pd.pattern(i,j), 2);               

                    left(row,col) = raw_image(y,x);
                    
                    comp_raw(y,x) = mean([raw_image(y, x-2), raw_image(y, x+2), raw_image(y-2, x), raw_image(y+2, x)]);

                    x = pd.margin.x + ((col-1)*size(pd.pattern, 2) + j-1)*pd.block.x + pd.right_pat(pd.pattern(i,j), 1);
                    y = pd.margin.y + ((row-1)*size(pd.pattern, 1) + i-1)*pd.block.y + pd.right_pat(pd.pattern(i,j), 2);
                    
                    right(row,col) = raw_image(y, x);

                    comp_raw(y, x) = mean([raw_image(y, x-2), raw_image(y, x+2), raw_image(y-2, x), raw_image(y+2, x)]);
                end
            end
        end
    end
    
    left = uint16(left);
    right = uint16(right);
end