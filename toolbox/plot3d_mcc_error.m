%Plot the mcc error in 3D(LAB) space. The square is the reference and the
%circle is the "current" color
%
% Input
% *lab: The "current" lab color. It is a 24*3 matrix (in 0-255)
% *slab: The reference lab color. A 24*3 matrix (in 0-255)
% *rgb: The "current" rgb color, used for display. It is a 24*3 matrix (in 0-255)
% *srgb: The reference rgb color, used for display. A 24*3 matrix (in 0-255)

function plot3d_mcc_error(lab, slab, rgb, srgb)
    figure;
    axis([-100, 100, -100, 100, 0, 100]);
    
    hold on
    grid on
    
    title('3D MCC Error Plot');
    xlabel('A*');
    ylabel('B*');
    zlabel('L*');
    
    drawArrow3 = @(x,y,z,props) quiver3( x(1),y(1),z(1),x(2)-x(1),y(2)-y(1), z(2)-z(1),0, props{:} ) ;        
    for i=1:24
        scatter3(slab(i,2), slab(i,3), slab(i,1), 50,'s', 'MarkerEdgeColor', srgb(i,:)./255, 'MarkerFaceColor' , srgb(i,:)./255);
        drawArrow3([slab(i,2), lab(i,2)],[slab(i,3), lab(i,3)], [slab(i,1), lab(i,1)], {'color', srgb(i,:)./255});
        scatter3(lab(i,2), lab(i,3), lab(i,1), 50,'c', 'MarkerEdgeColor', rgb(i,:)./255, 'MarkerFaceColor' , rgb(i,:)./255);
    end
    view(3);
end