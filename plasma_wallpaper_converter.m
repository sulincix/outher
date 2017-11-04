#!/usr/bin/octave
ls
pkg load image
a=input("","s");
f=imread(a);
mkdir("convert");
mkdir("convert/contents");
mkdir("convert/contents/images");
imwrite(imresize(f,[1024 1280]),"convert/contents/images/1280x1024.jpg");
imwrite(imresize(f,[1200 1600]),"convert/contents/images/1600x1200.jpg");
imwrite(imresize(f,[1080 1920]),"convert/contents/images/1920x1080.jpg");
imwrite(imresize(f,[1200 1920]),"convert/contents/images/1920x1200.jpg");
imwrite(imresize(f,[250 400]),"convert/contents/screenshot.jpg");
g=fopen("convert/metadata.desktop","w");
fdisp(g,"[Desktop Entry]");
fdisp(g,"Name=convert");
fdisp(g,"X-KDE-PluginInfo-Name=convert");
fdisp(g,"X-KDE-PluginInfo-Author=Ali Rıza KESKİN");
fdisp(g,"X-KDE-PluginInfo-Email=aliriza.keskin@pardustopluluk.org");
fdisp(g,"X-KDE-PluginInfo-License=LGPLv3");
fclose(g);




