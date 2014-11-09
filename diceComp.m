function comp = diceComp( image1, image2 )
image1(:) = image1(:) > 0.5;
image2(:) = image2(:) > 0.5;
comp = sum(image1(:) & image2(:))/((sum(image1(:)) + sum(image2(:)))/2);

end

