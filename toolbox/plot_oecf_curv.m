function plot_oecf_curv(rgbw_array, lumi_table)
    figure;
    title('OECF Plot');
    hold on;
    %plot(1:20, rgbw_array(:,1), 'r');
    %plot(1:20, rgbw_array(:,2), 'g');
    %plot(1:20, rgbw_array(:,3), 'b');
    
    plot(lumi_table, rgbw_array(:,4), 'k');
    %axis([1 20 0 255]);

end