function showImageInBox(ax, image)
% SHOWIMAGEINBOX Show an image centred in a fixed square box.
%   Every image box in a row has the same size, whatever the image's shape,
%   and the image cannot be dragged or zoomed. An empty image draws the empty box.
    theme = toolboxTheme();
    if ~isempty(image)
        imshow(image, 'Parent', ax);
        [rows, columns, ~] = size(image);
        side = max(rows, columns);
        ax.XLim = (columns + 1) / 2 + [-side side] / 2;
        ax.YLim = (rows + 1) / 2 + [-side side] / 2;
    end
    ax.Visible = 'on';
    ax.XTick = []; ax.YTick = [];
    ax.Box = 'on';
    ax.Color = theme.Surface;
    ax.XColor = theme.Border; ax.YColor = theme.Border;
    lockAxes(ax);
end
