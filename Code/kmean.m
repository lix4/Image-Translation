function [result] = kmean(k, means, img)    
    [row col cha] = size(img);
    placeholder = zeros(row, col);
    for i = 1:row
       for j = 1:col
          min_distance = 9999;
          closet_cluster = 1;
          for z = 1:k
              distance = RGBdistnace(img(i, j, :), means(z, :));
              if distance < min_distance
                  min_distance = means(z);
                  closet_cluster = z;
              end
          end
%           fprintf('cluster belongs to: %i\n', closet_cluster);
          placeholder(i, j) = closet_cluster;
       end
    end
    result = placeholder;
    
end

function [distance] = RGBdistnace(p1, p2)
    square1 = (p1(1) - p2(1)) ^ 2;
    square2 = (p1(2) - p2(2)) ^ 2;
    square3 = (p1(3) - p2(3)) ^ 2;
    distance = sqrt(square1 + square2 +square3);
end