%Plot the MCC error between "current" RGB and refenced RGB. Reference is
%noted with square and "current" is noted as circle
%
% Input
% *lab: The CIELab of current
% *slab: The referenced CIELab 
% *rgb: The RGB of current, used as color fill
% *srgb: The reference RGB, used as color fill

function plot_mcc_error(lab, slab, rgb, srgb)
    figure;
    axis([-100, 100, -100, 100]);
    
    hold on
    grid on
    
    title('2D MCC Error Plot');
    xlabel('A*');
    ylabel('B*');
    
    drawArrow = @(x,y,props) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, props{:} ) ;        
    for i=1:24
        scatter(slab(i,2), slab(i,3), 50,'s', 'MarkerEdgeColor', srgb(i,:)./255, 'MarkerFaceColor' , srgb(i,:)./255);
        drawArrow([slab(i,2), lab(i,2)],[slab(i,3), lab(i,3)], {'color', srgb(i,:)./255});
        scatter(lab(i,2), lab(i,3), 50,'c', 'MarkerEdgeColor', rgb(i,:)./255, 'MarkerFaceColor' , rgb(i,:)./255);
    end
end