function T = trs
%TRS Create an affine transformation involving a translation by (50, 100),
% a rotation of pi / 16 in a clockwise direction and a scaling of 0.8
% across both dimensions.
T = [0.8 * cos(pi/16) -0.8*sin(pi/16) 50; 
    0.8 * sin(pi/16) 0.8 * cos(pi/16) 100];
end

