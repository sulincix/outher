#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char *replace(const char *s, char ch, const char *repl) {
     int count = 0;
     const char *t;
     for(t=s;*t;t++)
         count += (*t == ch);
     size_t rlen = strlen(repl);
     char *res = malloc(strlen(s) + (rlen-1)*count + 1);
     char *ptr = res;
     for(t=s;*t;t++) {
         if(*t == ch) { memcpy(ptr, repl, rlen);
             ptr += rlen;
         } else {
            *ptr++ = *t;
         } 
     } *ptr = 0;
     return res;
     }

int main(int argc,char* argv[]){
    char a[1000];
    char b[1000];
    char c[1000];
    int i=0;
    char tmp[1000];
    printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    printf("<!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">\n");
    printf("<wallpapers>\n");
    while(fgets(a,1000,stdin) != NULL){
      strcat(b,"");
      int k=0;
      for(int j=0;j<1000;j++){
        if(a[j]=='/'){
          strcat(b,"");
          k=0;
        }else{
          b[k]=a[j];
          k=k+1;
        }
      }
    strcpy(a,replace(a,'\n',""));
    strcpy(b,replace(b,'\n',""));
    printf("\t<wallpaper deleted=\"false\">\n");
    printf("\t\t<name>%s</name>\n",b);
    printf("\t\t<filename>%s</filename>\n",a);
    printf("\t\t<options>zoom</options>\n");
    printf("\t\t<shade_type>solid</shade_type>\n");
    printf("\t\t<pcolor>#3465a4</pcolor>\n");
    printf("\t\t<scolor>#000000</scolor>\n");
    printf("\t</wallpaper>\n");
    i=i+1;
    }
    printf("</wallpapers>\n");
}
