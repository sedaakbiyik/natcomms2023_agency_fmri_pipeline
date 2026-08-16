function [xRot yRot] = rotate(x,y,angle)

% rotate by 30 clockwise around (0,0)
% http://en.wikipedia.org/wiki/Rotation_matrix
rotAngle = (pi/180).*angle;
xRot     = x*cos(rotAngle) - y*sin(rotAngle);
yRot     = x*sin(rotAngle) + y*cos(rotAngle);
%plot(yRot,xRot,'b*');

%and move by (3 2)
% xRotShift = xRot + 3;
% yRotShift = yRot + 5;
% plot(yRotShift,xRotShift,'r*');



