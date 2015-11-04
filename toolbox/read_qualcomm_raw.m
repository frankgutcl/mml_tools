%To read the raw image (Bayer pattern RGGB)
%
% Input
% *file: The name of the file (string)
% *w: The width of the picture
% *h: The height of the picture
% *format: Only 'Q10' is supported yet

function ret=read_qualcomm_raw(file, w, h, format)
    fp = fopen(file,'rb','b');
    %w = 3264;
    %h = 2448;

    %w = 4212;
    %h = 3120;

    if strcmpi(format, 'm10')
        %Not applicable yet
        size = (w*h*5)/4;
        Data = fread(fp,size,'*uint8', 0,'l' );

        ret = reshape(Data, [5 size/5]);
        ret = reshape(ret(2:5, :), [w h]);
        fclose(fp);
    elseif strcmpi(format,'q10')
        size = w*h/6;
        Data = fread(fp,size,'*uint64', 0,'l');

        image(1,1:size) = uint16(bitand(Data(1:size),1023));
        image(2,1:size) = uint16(bitshift(bitand(Data(1:size),2^20 - 2^10),-10));
        image(3,1:size) = uint16(bitshift(bitand(Data(1:size),2^30 - 2^20),-20));
        image(4,1:size) = uint16(bitshift(bitand(Data(1:size),2^40 - 2^30),-30));
        image(5,1:size) = uint16(bitshift(bitand(Data(1:size),2^50 - 2^40),-40));
        image(6,1:size) = uint16(bitshift(bitand(Data(1:size),2^60 - 2^50),-50));
        img1 = reshape(image,[w h]);
        img = img1';
        ret = uint8(bitshift(img,-(10-8)));
        fclose(fp);
    end
end