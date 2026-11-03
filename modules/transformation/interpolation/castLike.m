function output = castLike(values, reference)
    % Convert interpolated double values back to the class of the reference image,
    % clamping to that class's valid range.

    if isa(reference, 'double') || isa(reference, 'single')
        output = cast(values, class(reference));
    elseif islogical(reference)
        output = values >= 0.5;
    else
        % Casting to an integer class rounds and saturates to the valid range
        output = cast(values, class(reference));
    end
end
