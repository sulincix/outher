#include <stdlib.h>
#include <string.h>
#include <stdio.h>
int main(int argc,char*argv[]){
  char cmd[4096]="";
  for(int i=1;i<argc;i++){
    strcat(cmd,argv[i]);
    strcat(cmd," ");
  }
  clearenv();
  return system(cmd);
}
