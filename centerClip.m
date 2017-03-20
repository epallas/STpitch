function [ yClip ] = centerClip( y, th )
%UNTITLED Summary of this function goes here
%  Compute center clipping of a function given a certain threshold
    y2 = y - th;
    y2(y2<0) = 0;
    y3 = y + th;
    y3(y3>0) = 0;
    yClip = y2 + y3;
end

