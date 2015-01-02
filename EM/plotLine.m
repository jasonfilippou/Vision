function plotLine(minX, maxX, line, step, style, msize)
% PLOTLINE A helpful routine which plots 2D lines for us. Essentially an
% abstraction over "plot".
x = minX:step:maxX; 
a = line(1); b = line(2);
plot(x, a.*x + b, style, 'MarkerSize', msize);
end