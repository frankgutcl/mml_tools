% Generate OECF report
% 
% Input
% * file: The path of output file
% * rgbw_array: The rgbw of patches(captured) in captured photos
% * label_array: The labels of files
% * lumi_table: The luminance table (measured)

function gen_oecf_report(file, rgbw_array, label_array, lumi_table)
    T1 = [3 2 6 22];
    T2 = [2 2 2 22];
    
    for index=1:size(rgbw_array,1)
        rgbw = ones(20,4);
        rgbw(:,:) = rgbw_array(index,:,:);
        
        xlswrite(file, {'Color' 'cd/m2' 'Red' 'Green' 'Blue' 'Gray'}, index, getRange(T1(1)-2, T1(2), T1(3), T1(2)));
        xlswrite(file, rgbw, index, getRange(T1(1), T1(2)+1, T1(3), T1(4)));
        xlswrite(file, lumi_table, index, getRange(T2(1), T2(2)+1, T2(3), T2(4)));
    end

    excel = actxserver('Excel.Application');
    excel.visible = 1;
    workbooks = excel.Workbooks;
    workbook = workbooks.Open(file);
    sheets = workbook.Sheets;
        
    for index=1:size(rgbw_array,1)
        sheet = sheets.Item(index); 
        sheet.Activate; 

        font = sheet.Range(getRange(T1(1), T1(2), T1(3), T1(2))).font;
        font.size=12;
        font.bold=1;

        for i=T1(2):2:T1(4)
            sheet.Range(getRange(T1(1), i, T1(3),i)).Interior.ColorIndex = 15;
        end

        border=sheet.Range(getRange(T1(1), T1(2), T1(3), T1(4))).Borders;
        border.ColorIndex=1;
        border.Weight=3;

        for i=1:20
            sheet.Range(getRange(1,T1(2)+i,1,T1(2)+i)).Interior.Color = RGB(rgbw_array(index,i,1), rgbw_array(index,i,2), rgbw_array(index,i,3));
        end
        sheet.Name = cell2mat(label_array(index));
    end
    
    %Adding chart
    sheet = sheets.Item(1); 
    sheet.Activate; 
    chart = excel.ActiveSheet.Shapes.AddChart(); 
    chart.Name = 'OECF';

    ExpChart = excel.ActiveSheet.ChartObjects('OECF');
    ExpChart.Activate;

    %Clear the original data
    try
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
    catch e
    end 

    for index=1:size(rgbw_array,1)
        NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
        NewSeries.XValues = [cell2mat(label_array(index)) '!B' int2str(3) ':B' int2str(22)];
        NewSeries.Values  = [cell2mat(label_array(index)) '!F' int2str(3) ':F' int2str(22)];
        NewSeries.Name    = cell2mat(label_array(index));
    end
    excel.ActiveChart.ChartType = 'xlXYScatterLinesNoMarkers'; 

    
    sheet = sheets.Item(1); 
    sheet.Activate; 
    chart = excel.ActiveSheet.Shapes.AddChart(); 
    chart.Name = 'Tone Curve';

    ExpChart = excel.ActiveSheet.ChartObjects('Tone Curve');
    ExpChart.Activate;

    %Clear the original data
    try
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
    catch e
    end 
    

    for index=1:size(rgbw_array,1)
        gray = ones(20);
        for i=1:20
            gray(i) = rgbw_array(index,i,4);
        end
        max = find(gray==255,1,'first');
        factor = 1024/lumi_table(max);
        
        NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
        
        
        NewSeries.XValues = lumi_table(1:max).*factor;
        NewSeries.Values  = gray(1:max);
        NewSeries.Name    = cell2mat(label_array(index));
    end
    excel.ActiveChart.ChartType = 'xlXYScatterLinesNoMarkers'; 

    
    workbook.Save();
    workbook.Close();
    excel.Quit();
end

function range=getRange(left, top, right, bottom)
    range=[char(64+left), num2str(top), ':', char(64+right), num2str(bottom)];
end

function color=RGB(r, g, b)
    color = 256*(256*b +g)+r;
end