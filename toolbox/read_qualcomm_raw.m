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
        sizet = w*h*5/4 + h*4;
        Data = fread(fp,sizet,'*uint8', 0,'l' );
        Data = uint16(Data);
        
        Data = reshape(Data, [w*5/4+4, h]);
        
        %Remove the 4-bytes padding
        Data = Data(1:w*5/4, :);
        
        %Split the 5th element
        Data = reshape(Data, [5, w*h/4]);
        
        major = Data(1:4, :);
        minor = Data(5, :);
        minor1 = bitand(minor,3);
        minor2 = bitand(bitshift(minor, -2), 3);
        minor3 = bitand(bitshift(minor, -4), 3);
        minor4 = bitand(bitshift(minor, -6), 3);
        minor = [minor1;minor2;minor3;minor4];
        
        ret = bitor(bitshift(major, 2), minor);
        ret = reshape(ret, [w,h]);
        ret = ret';
  
        fclose(fp);
    elseif strcmpi(format,'q10')
        sizet = w*h/6;
        Data = fread(fp,sizet,'*uint64', 0,'l');

        image(1,1:sizet) = uint16(bitand(Data(1:sizet),1023));
        image(2,1:sizet) = uint16(bitshift(bitand(Data(1:sizet),2^20 - 2^10),-10));
        image(3,1:sizet) = uint16(bitshift(bitand(Data(1:sizet),2^30 - 2^20),-20));
        image(4,1:sizet) = uint16(bitshift(bitand(Data(1:sizet),2^40 - 2^30),-30));
        image(5,1:sizet) = uint16(bitshift(bitand(Data(1:sizet),2^50 - 2^40),-40));
        image(6,1:sizet) = uint16(bitshift(bitand(Data(1:sizet),2^60 - 2^50),-50));
        img1 = reshape(image,[w h]);
        ret = img1';
        %ret = uint8(bitshift(img,-(10-8)));
        fclose(fp);
    end
end