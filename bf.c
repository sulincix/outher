#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define memsize 1024000
int comment=0;
int main(int argc,char *argv[]){
  char bf[1];
  fprintf(stdout,"#include <stdio.h>\n");
  fprintf(stdout,"#include <stdlib.h>\n");
  for(int i=1;i!=argc;i++){
    fprintf(stdout,"#include <%s>\n",argv[i]);
  }
  fprintf(stdout,"\nint main(int argc,char *argv[]){\n");
  fprintf(stdout,"\tunsigned char *array=calloc(%d, 1);\n",memsize);
  fprintf(stdout,"\tunsigned char *ptr=array;\n");
  while(!feof(stdin)){
    bf[0]=fgetc(stdin);
    if(comment==0){
      if(bf[0]==(int)'<'){
        fprintf(stdout,"\t++ptr;\n");
      }
      if(bf[0]==(int)'>'){
        fprintf(stdout,"\t--ptr;\n");
      }
      if(bf[0]==(int)'+'){
        fprintf(stdout,"\t++*ptr;\n");
      }
      if(bf[0]==(int)'-'){
        fprintf(stdout,"\t--*ptr;\n");
      }
      if(bf[0]==(int)'.'){
        fprintf(stdout,"\tputchar(*ptr);\n");
      }
     if(bf[0]==(int)','){
        fprintf(stdout,"\t*ptr=getchar();\n");
      }
      if(bf[0]==(int)'['){
        fprintf(stdout,"\twhile (*ptr != 0) {\n");
      }
      if(bf[0]==(int)']'){
        fprintf(stdout,"\t}\n");
      }
      if(bf[0]==(int)'#'){
        comment=1;
      }
    }else{
      if(bf[0]==(int)'\n'){
        comment=0;
      }
      fprintf(stdout,"\t%c",bf[0]);
    }
    strcpy(bf,"");
  }
  fprintf(stdout,"}\n");
  return 0;
}
