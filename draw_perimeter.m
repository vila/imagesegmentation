function f_perim = draw_perimeter(f, C)
%DRAW_PERIMETER Given a grayscale image and a characteristic function
% returns an image with the perimeter of C drawn overlayed on f

% find the perimeter of C
perim = bwperim(C);

% we dilate the perimiter to make it a little bit thicker border
perim = imdilate( perim, strel('square',2) );
       
% create a new image with the border overlayed
f_perim = repmat(f.*~perim, [1 1 3]) + cat(3, perim,zeros([size(f) 2]));

end