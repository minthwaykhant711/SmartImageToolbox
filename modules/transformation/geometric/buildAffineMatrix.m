function A = buildAffineMatrix(imgSize, angleDeg, sx, sy, shx, shy, tx, ty)
    % Compose a 3x3 affine matrix from intuitive parameters, applied about the
    % image centre in the order: shear -> scale -> rotate, then translate.
    %   imgSize  - size(img) (only rows and columns are used)
    %   angleDeg - counter-clockwise rotation in degrees
    %   sx, sy   - scale factors
    %   shx, shy - horizontal and vertical shear factors
    %   tx, ty   - translation in pixels (right, down)

    cx = (imgSize(2) + 1) / 2;
    cy = (imgSize(1) + 1) / 2;
    theta = -deg2rad(angleDeg);

    R  = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
    S  = [sx 0 0; 0 sy 0; 0 0 1];
    Sh = [1 shx 0; shy 1 0; 0 0 1];
    toOrigin = [1 0 -cx; 0 1 -cy; 0 0 1];
    back = [1 0 cx + tx; 0 1 cy + ty; 0 0 1];

    A = back * R * S * Sh * toOrigin;
end
