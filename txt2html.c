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
    int i=0;
    int j=0;
    char tmp[1000];
    printf("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n");
    printf("<html>\n");
    printf("\t<head>\n");
    printf("\t\t<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"/>\n");
    printf("\t\t<title>Txt2Html Page</title>\n");
    printf("\t</head>\n");
    printf("<body lang=\"tr-TR\" dir=\"ltr\">\n");
    while(fgets(a,1000,stdin) != NULL){
        strcpy(a,replace(a,' ',"&nbsp"));
        strcpy(a,replace(a,'\n'," "));
        printf("<p>%s</p>\n",a);
    }
    printf("</body>\n");
    printf("</html>");
}