function show_raw_pic(raw_image, pattern)
    if isa(raw_image(1,1), 'uint8')
        %Leave what it is
    elseif isa(raw_image(1,1), 'uint16')
        max_val = double(max(max(raw_image)));
        max_range = ceil(log(max_val)/log(2));
        raw_image = bitshift(raw_image, 16-max_range);
    else
        disp('Unkown format!');
    end
    
    if nargin == 2
        imshow(demosaic(raw_image, pattern));
    else
        imshow(raw_image);
    end
end