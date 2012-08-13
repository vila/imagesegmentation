function f_perim = draw_perimeter(f, C, c)
%DRAW_PERIMETER Given a grayscale image and a characteristic function
% returns an image with the perimeter of C drawn overlayed on f
% with color c

if nargin < 3
    c = [1 0 0];
end

% find the perimeter of C
perim = bwperim(C);

% we dilate the perimiter to make it a little bit thicker border
perim = imdilate( perim, strel('square',2) );

if (size(f,3) < 3)
   f = repmat(f, [1 1 3]); 
end

[m,n,~] = size(f);

% create a new image with the border overlayed
f_perim = f .* repmat(~perim, [1 1 3]) + cat(3, c(1)*perim, cat(3, c(2)*perim, c(3)*perim));

end