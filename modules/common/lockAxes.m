function lockAxes(ax)
% LOCKAXES Stop the user from panning, zooming or rotating an axes.
%   Call after every plotting command, because imshow and bar reset the axes.
    disableDefaultInteractivity(ax);
    ax.Toolbar.Visible = 'off';
end
