function resetChartAxes(ax)
% RESETCHARTAXES Undo image-box styling so an axes can show a normal chart.
%   Call before plotting a chart in an axes that may have shown an image.
    ax.Visible = 'on';
    ax.XLimMode = 'auto'; ax.YLimMode = 'auto';
    ax.XTickMode = 'auto'; ax.YTickMode = 'auto';
    ax.DataAspectRatioMode = 'auto'; ax.PlotBoxAspectRatioMode = 'auto';
    ax.XColor = [0.15 0.15 0.15]; ax.YColor = [0.15 0.15 0.15];
    ax.Box = 'off';
end
