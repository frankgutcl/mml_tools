%By Robbie Yuan

fp = fopen('D:\tmp\q10office.raw','rb','b');
%w = 3264;
%h = 2448;

w = 4212;
h = 3120;

size = w*h/6;
[Data,l] = fread(fp,size,'uint64=>uint64','l' );

image(1,1:size) = uint16(bitand(Data(1:size),1023));
image(2,1:size) = uint16(bitshift(bitand(Data(1:size),2^20 - 2^10),-10));
image(3,1:size) = uint16(bitshift(bitand(Data(1:size),2^30 - 2^20),-20));
image(4,1:size) = uint16(bitshift(bitand(Data(1:size),2^40 - 2^30),-30));
image(5,1:size) = uint16(bitshift(bitand(Data(1:size),2^50 - 2^40),-40));
image(6,1:size) = uint16(bitshift(bitand(Data(1:size),2^60 - 2^50),-50));
img1 = reshape(image,[w h]);
img = img1';
raw = uint8(bitshift(img,-(10-8)));
figure;
imshow(raw);
imwrite(raw,'test.bmp','bmp');
type(raw)
fclose(fp);