function [ch1, ch2, ch3, ch4] = split_raw_pic(raw_image)
    [h, w] = size(raw_image);
    ch1 = raw_image(1:2:h, 1:2:w);
    ch2 = raw_image(1:2:h, 2:2:w);
    ch3 = raw_image(2:2:h, 1:2:w);
    ch4 = raw_image(2:2:h, 2:2:w);
end