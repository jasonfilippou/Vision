function writeEPS(h, filename, varargin)

if nargin > 2
    width = varargin{1};
    height = varargin{2};
else
    width = 15;
    height = 10;
end

set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperSize', [width height]);
set(h, 'Units', 'centimeters');
set(h, 'Position', [0 0 width height]);
set(h, 'PaperPosition', [0 0 width height]);

print('-depsc2', filename);
