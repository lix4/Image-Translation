for id = 1: 62
    name = int2str(id);
    cd(name);
    contents=ls;
    for i=1:length(contents)
        try
           tempImage=imread(contents(i,:));
           tempImage = rgb2gray(tempImage);
           tempImage=imresize(tempImage,[32,32]);
           extnposn=find(contents(i,:)=='.');
           extn=contents(i,extnposn+1:end);
           extn(extn==' ')=[];
           name=contents(i,:);
           name(name==' ')=[];
           imwrite(tempImage,name,extn)
        catch
            %write err msg as
            %use msgbox
        end
    end
    cd ..;
end    