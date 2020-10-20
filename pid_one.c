#define _GNU_SOURCE
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
 
 
static char child_stack[1024*1024];
 
int run(const char *name) {
  char *_args[] = {(char *)name, (char *)0 };
  execvp(name, _args);
}
static int child_fn() {
  run("bash");
  return 0;
}
 
int main() {
  char buf[255]; 
 
  pid_t pid = clone(child_fn, child_stack+1024*1024, CLONE_NEWPID | CLONE_NEWUTS | SIGCHLD , NULL);
  
  waitpid(pid, NULL, 0);
  return 0;
}
