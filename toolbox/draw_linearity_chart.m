%% Start
% Input
% * w: The width of the picture
% * h: The height of the picture
% * format: format of the raw picture (Q10 or M10);
% * pattern: sensor pattern (bggr or grbg);
% * exp_num: split the exposure time into how many segments;

function draw_linearity_chart(w,h,format,pattern,exp_num)
%% Find and calculate raw data 
folder_path = uigetdir;      % Select the pictures folder path
cd(folder_path);

img_path_list =  dir(fullfile('*.raw'));       % Find the *.raw file
img_num = length(img_path_list);               % Count how many '*.raw' files

raw = zeros(img_num,4);
std = zeros(img_num,5);
snr = zeros(img_num,4);
mean_results = cell(img_num,5);                % Build blank matrics
std_results = cell(img_num,5);
snr_results = cell(img_num,4);
mean_value_data = cell(img_num+1,5);


if img_num > 0                                                % If the folder has files
    for i = 1:img_num                                         % Read image one-by-one
            image_name = img_path_list(i).name;               % Set the veriable = image name;
            path(path,'D:\3_ReportExample\MATLAB\toolbox')    % Set the function path;
            img = read_qualcomm_raw(image_name, w, h, format);% Qualcomm raw image processing;
                        
            if strcmpi(pattern, 'grbg')                       % Judge which sensor pattern used;
                Gr = img(1:2:end, 1:2:end);
                R = img(1:2:end, 2:2:end);
                B = img(2:2:end, 1:2:end);
                Gb = img(2:2:end, 2:2:end);
                
            elseif strcmpi(pattern, 'bggr')
                B = img(1:2:end, 1:2:end);
                Gb = img(1:2:end, 2:2:end);
                Gr = img(2:2:end, 1:2:end);
                R = img(2:2:end, 2:2:end);
            end
            
            Bave = mean(B(:));                               % Calculate mean value of B,G,G,R;
            Gbave = mean(Gb(:));
            Grave = mean(Gr(:));
            Rave = mean(R(:));
            
            Y=0.299*R+ 0.587*(Gb/2+Gr/2)+0.112*B;            % Calculate std value
            stdY = std2(Y);
            stdB = std2(B);
            stdGb = std2(Gb);
            stdGr = std2(Gr);
            stdR = std2(R);
            
            snrB = 20*(log10(Bave./stdB));                   % Calculate SNR value
            snrGb = 20*(log10(Gbave./stdGb));
            snrGr = 20*(log10(Grave./stdGr));
            snrR = 20*(log10(Rave./stdR));
                     
            raw(i,:) = [Bave Gbave Grave Rave];              % Put all value together 
            std(i,:) = [stdB stdGb stdGr stdR stdY];
            snr(i,:) = [snrB snrGb snrGr snrR];
            mean_results_write = {image_name Bave Gbave Grave Rave};
            std_results_write = {stdB stdGb stdGr stdR stdY};
            snr_results_write = {snrB snrGb snrGr snrR};
            mean_results(i,:) = mean_results_write;
            std_results(i,:) = std_results_write;
            snr_results(i,:) = snr_results_write;
    end 
end

%% Write all value to Excel
mean_value_data(1,:) = {'ISO','B_avg','Gb_avg','Gr_avg','R_avg'};
mean_value_data(2:img_num+1,:) = mean_results;
isovalue = mean_value_data(2:img_num+1,1);
isovalue1 = cell2mat(isovalue);

mean_value_data_final = cell(img_num+1,6);
mean_value_data_final(1,:) = {'ISO','Exp_time','B_avg','Gb_avg','Gr_avg','R_avg'};

mean_value_data_final(2:img_num+1,1) = cellstr(isovalue1(1:img_num,1:4)); % ISO

mean_value_data_final(2:img_num+1,2) = cellstr(isovalue1(1:img_num,6:13));% Exposure time

mean_value_data_final(2:img_num+1,3:6) = mean_results(:,2:5);             % Mean value
xlswrite('rawdata.xlsx',mean_value_data_final(2:(img_num+1),2:6));

rawdata = xlsread('rawdata.xlsx');                                  % NO.3 Calculate RGB Ref_ value;
ref = zeros(img_num,4);                                             % Rawdata contain exposure time extra coloumn
y_line = zeros(img_num,1);

for h = 2:5  % h raw data first coloumn
             % exposure time list number
    for m = exp_num:exp_num:img_num
        x = rawdata((m-(exp_num-1)):m,1);
        y = rawdata((m-(exp_num-1)):m,h);
        p = polyfit(x,y,1);
        y_linetemp = p(1)*x + p(2);
        y_line((m-(exp_num-1)):m,1) = y_linetemp;
    end
    ref(:,(h-1)) = y_line;                               % Output B Gb Gr R raw Ref value coloumn
end

refout = cell(img_num+1,4);
ref2cell = num2cell(ref);
refout(1,:) = {'Ref_B','Ref_Gb','Ref_Gr','Ref_R'};
refout(2:img_num+1,:) = ref2cell;


excel_final_out = cell(img_num+1,24);                 % Final output data
excel_final_out(:,1:5) = mean_value_data_final(:,2:6);
excel_final_out(:,6:9) = refout;


dev = log2(raw./ref);                    % Calculate deviation 
der1 = num2cell(dev);

devout = cell(img_num+1,4);
devout(1,:) = {'devB','devGb','devGr','devR'};
devout(2:(img_num+1),:) = der1;  

excel_final_out(:,10:13) = devout;       % Save deviation results

senrat(:,1) = raw(:,1)./raw(:,2)*100;    % Calculate sensitivity ratio B/Gb, R/Gr
senrat(:,2) = raw(:,4)./raw(:,3)*100;

senrat_out = cell(img_num,2);       
senrat_out(1,:) = {'B/Gb','R/Gr'};
senrat_out(2:(img_num+1),:) = num2cell(senrat);

excel_final_out(:,14:15) = senrat_out;   % Save B/Gb, R/Gr results

std_out = cell(img_num+1,5);
std_out(1,:) = {'std B', 'std Gb', 'std Gr', 'std R', 'std Y'};
std_out(2:img_num+1,:) = std_results;
excel_final_out(:,16:20) = std_out;      % Save std results

snr_out = cell(img_num+1,4);
snr_out(1,:) = {'SNR.B','SNR.Gb','SNR.Gr','SNR.R'};
snr_out(2:img_num+1,:)= snr_results;
excel_final_out(:,21:24) = snr_out;      % Save snr results

excel_final_out_data = cell(img_num,24);
excel_final_out_data(:,:) = excel_final_out(2:(img_num+1),:);  % Save all results

for i = 1:exp_num:img_num
    sheeti = ((i-1)/exp_num)+1;
    col = 24;
    row = exp_num+1; 
    SHEET = cell(row,col);
    SHEET(1,:) = excel_final_out(1,:);
    SHEET(2:(exp_num+1),:) = excel_final_out_data(i:(i-1+exp_num),:);
    xlswrite('linearity_results.xlsx',SHEET,sheeti);

%% Activate Excel   
    filespec_user=[pwd '\linearity_results.xlsx'];
    excel = actxserver('Excel.Application');
    excel.visible = 1;
    workbooks = excel.Workbooks;
    workbook = workbooks.Open (filespec_user);
    sheets = workbook.Sheets;
    
    sheet = sheets.Item(sheeti);
    sheet.Activate;
    sheet.Name = cell2mat(mean_value_data_final(i+1,1));
    
    font = sheet.Range('A1:X1').font;             % Setting Excel font;
    font.size = 12;
    font.bold = 1;
        
    for g=1:2:exp_num+1        
        sheet.Range([char(64+1),num2str(g),':',char(64+24),num2str(g)]).Interior.ColorIndex = 15;  % Setting Excel background color;
    end
    
    sheet.Range([char(64+1),num2str(2),':',char(64+1),num2str(exp_num+1)]).Interior.ColorIndex = 34;       
    
    for b=1:exp_num+1
        border = sheet.Range([char(64+1),num2str(b),':',char(64+24),num2str(b)]).Borders;          % Setting Excel border;
        border.ColorIndex = 1;
        border.Weight = 2;
    end
      
    
%% Adding First Chart
    chart = excel.ActiveSheet.Shapes.AddChart();
    chart.Name = 'Linearity Value';
    ExpChart = excel.ActiveSheet.ChartObjects('Linearity Value');
    ExpChart.Activate;

    %Clear the original data
    try
        for i_first=1:16
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        end
    catch e
    end 
    
% Select data for chart.        
    for i_chart1 = 2:9
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!' char(64+i_chart1) int2str(2) ':' char(64+i_chart1) int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,i_chart1));
    end
    
    excel.ActiveChart.ChartType = 'xlXYScatterSmooth'; 
    excel.ActiveChart.HasTitle = 1;
    excel.ActiveChart.ChartTitle.Characters.Text = 'Linearity Value';
    
% Setting the (X-Axis) and (Y-Axis) titles. 
    ChartAxes = chart.Chart.Axes(1); 
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Exposure Time - S'); 
    ChartAxes = chart.Chart.Axes(2);  
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Output_Value'); 
    
% Setting the (Axis) Scale 
    excel.ActiveChart.Axes(1).Select; 
    excel.ActiveChart.Axes(1).MinimumScale = 0;             
    excel.ActiveChart.Axes(1).MaximumScale = 1; 
    
    excel.ActiveChart.Axes(2).Select; 
    excel.ActiveChart.Axes(2).MinimumScale = 0;             
    excel.ActiveChart.Axes(2).MaximumScale = 1100;

% Placement
    chart_range_mean = [char(64+2),num2str(exp_num+2)];
    GetPlacement = get(excel.ActiveSheet,'Range', chart_range_mean);
    ExpChart.Left = GetPlacement.Left;
    ExpChart.Top = GetPlacement.Top;
    
    
%% Adding the Second Chart
    chart = excel.ActiveSheet.Shapes.AddChart();
    chart.Name = 'B/Gb R/Gr';
    ExpChart = excel.ActiveSheet.ChartObjects('B/Gb R/Gr');
    ExpChart.Activate;

    %Clear the original data
    try
        for i_second=1:16
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        end
    catch e
    end
    
 % Select data for chart.        
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!N' int2str(2) ':N' int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,14));
    
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!O' int2str(2) ':O' int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,15));
    
    excel.ActiveChart.ChartType = 'xlXYScatterLines'; 
    excel.ActiveChart.HasTitle = 1;
    excel.ActiveChart.ChartTitle.Characters.Text = 'B/Gb R/Gr';
    
% Setting the (X-Axis) and (Y-Axis) titles. 
    ChartAxes = chart.Chart.Axes(1); 
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Exposure Time - S'); 
    ChartAxes = chart.Chart.Axes(2);  
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Sensitivity Ratio [ %]'); 
    
% Setting the (Axis) Scale 
    excel.ActiveChart.Axes(1).Select; 
    excel.ActiveChart.Axes(1).MinimumScale = 0;             
    excel.ActiveChart.Axes(1).MaximumScale = 1; 
    
    excel.ActiveChart.Axes(2).Select; 
    excel.ActiveChart.Axes(2).MinimumScale = 0;             
    excel.ActiveChart.Axes(2).MaximumScale = 140;
    
% Placement
    chart_range_2 = [char(64+10),num2str(exp_num+2)];
    GetPlacement = get(excel.ActiveSheet,'Range', chart_range_2);
    ExpChart.Left = GetPlacement.Left;
    ExpChart.Top = GetPlacement.Top;  

    
%% Draw the Third Chart
    chart = excel.ActiveSheet.Shapes.AddChart();
    chart.Name = 'std Y; std Gr';
    ExpChart = excel.ActiveSheet.ChartObjects('std Y; std Gr');
    ExpChart.Activate;

    %Clear the original data
    try
        for i_third=1:16
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        end
    catch e
    end
    
 % Select data for chart.        
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!R' int2str(2) ':R' int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,18));
    
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!T' int2str(2) ':T' int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,20));
    
    excel.ActiveChart.ChartType = 'xlXYScatterLines'; 
    excel.ActiveChart.HasTitle = 1;
    excel.ActiveChart.ChartTitle.Characters.Text = 'std Y; std Gr';
    
% Setting the (X-Axis) and (Y-Axis) titles. 
    ChartAxes = chart.Chart.Axes(1); 
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Exposure Time - S'); 
    ChartAxes = chart.Chart.Axes(2);  
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Sensitivity Ratio [ %]'); 
    
% Setting the (Axis) Scale 
    excel.ActiveChart.Axes(1).Select; 
    excel.ActiveChart.Axes(1).MinimumScale = 0;             
    excel.ActiveChart.Axes(1).MaximumScale = 1; 
    
    excel.ActiveChart.Axes(2).Select; 
    excel.ActiveChart.Axes(2).MinimumScale = 0;             
    excel.ActiveChart.Axes(2).MaximumScale = 350;
    
% Placement
    chart_range_3 = [char(64+2),num2str(exp_num+19)];
    GetPlacement = get(excel.ActiveSheet,'Range', chart_range_3);
    ExpChart.Left = GetPlacement.Left;
    ExpChart.Top = GetPlacement.Top;  

    
%% Adding the Fourth Chart
    chart = excel.ActiveSheet.Shapes.AddChart();
    chart.Name = 'Deviation';
    ExpChart = excel.ActiveSheet.ChartObjects('Deviation');
    ExpChart.Activate;

    %Clear the original data
    try
        for i_fourth=1:16
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        end
    catch e
    end
    
 % Select data for chart.        
    for i_chart4 = 10:13 
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = [cell2mat(mean_value_data_final(i+1,1)) '!A' int2str(2) ':A' int2str(exp_num+1)];
    NewSeries.Values  = [cell2mat(mean_value_data_final(i+1,1)) '!' char(64+i_chart4) int2str(2) ':' char(64+i_chart4) int2str(exp_num+1)];
    NewSeries.Name    = cell2mat(excel_final_out(1,10));
    end
    
    excel.ActiveChart.ChartType = 'xlXYScatterLines'; 
    excel.ActiveChart.HasTitle = 1;
    excel.ActiveChart.ChartTitle.Characters.Text = 'Deviation';
    
% Setting the (X-Axis) and (Y-Axis) titles. 
    ChartAxes = chart.Chart.Axes(1); 
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Exposure Time - S'); 
    ChartAxes = chart.Chart.Axes(2);  
    set(ChartAxes,'HasTitle',1); 
    set(ChartAxes.AxisTitle,'Caption','Output_Value'); 
    
% Setting the (Axis) Scale 
    excel.ActiveChart.Axes(1).Select; 
    excel.ActiveChart.Axes(1).MinimumScale = 0;             
    excel.ActiveChart.Axes(1).MaximumScale = 1; 
    
    excel.ActiveChart.Axes(2).Select; 
    excel.ActiveChart.Axes(2).MinimumScale = -3;             
    excel.ActiveChart.Axes(2).MaximumScale = 1;

% Placement
    chart_range_4 = [char(64+10),num2str(exp_num+19)];
    GetPlacement = get(excel.ActiveSheet,'Range', chart_range_4);
    ExpChart.Left = GetPlacement.Left;
    ExpChart.Top = GetPlacement.Top;  


    workbook.Save();
    workbook.Close();
    excel.Quit();
end
% Reopen excel
    excel = actxserver('Excel.Application');
    excel.visible = 1;
    workbooks = excel.Workbooks;
    workbooks.Open (filespec_user);

    disp('Done!');
end










