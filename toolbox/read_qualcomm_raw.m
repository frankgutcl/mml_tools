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
        sizet = w*h*5/4 + h*4;
        Data = fread(fp,sizet,'*uint8', 0,'l' );
        Data = uint16(Data);
        
        for row=1:h
            row_offset = (row-1)*(w*5/4+4);
            
            for col=1:4:w
                col_offset = floor(col/4) * 5;
                total_offset = row_offset + col_offset + 1;
                ret(row, col  ) = bitor(bitshift(Data(total_offset  ),2), bitand(bitshift(Data(total_offset+4),0),3));
                ret(row, col+1) = bitor(bitshift(Data(total_offset+1),2), bitand(bitshift(Data(total_offset+4),-2),3));
                ret(row, col+2) = bitor(bitshift(Data(total_offset+2),2), bitand(bitshift(Data(total_offset+4),-4),3));
                ret(row, col+3) = bitor(bitshift(Data(total_offset+3),2), bitand(bitshift(Data(total_offset+4),-6),3));
            end
        end
  
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