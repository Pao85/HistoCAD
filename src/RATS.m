%RATS as a function
function thresh = RATS (img)
    img = double(img) / 255.0;
    [nrows,ncols] = size(img);
    dx = img;
    dy = img;
    dxy = img;
    for y = 2:nrows-1
        for x = 2:ncols-1
            dy(y,x) = img(y+1,x) - img(y-1,x);
            dx(y,x) = img(y,x+1) - img(y,x-1);
            dxy(y,x) = max( abs(dy(y,x)) , abs(dx(y,x)) );
        end
    end
    Sd = sum (dxy(:));
    Sdf = sum(dot(img,dxy));
    thresh = Sdf / Sd;
end