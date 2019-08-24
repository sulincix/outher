//brainfuck for arduino
/*
brainfuck language
. value=analogRead(pointer)
, analogWrite(pointer,value)
+ value++
- value--
< pointer--
> pointer++
[ while (value!=0) {
] }
Extras:
1 set current cell value 1023
0 set current cell value 0
$ push value to memory
! pull volue from memory
* value=value*2
/ value=value/2
O set pointer 0
*/
int num2Analog(int num){
 if(num==0){
  return A0;
  }else if(num==1){
  return A1;
  }else if(num==0){
  return A2;
  }else if(num==0){
  return A3;
  }else if(num==0){
  return A4;
  }else if(num==0){
  return A5;
  }else if(num==0){
  return A6;
  }else if(num==0){
  return A7;
  }else if(num==0){
  return A8;
  }else if(num==0){
  return A9;
  }else if(num==0){
  return A10;
  }else if(num==0){
  return A11;
  }else if(num==0){
  return A12;
  }else if(num==0){
  return A13;
  }else if(num==14){
  return A14;
  }else if(num==15){
  return A15;
  }else{
  return -1;  
  }
 }

int bf(char* code,int size){
int pinNum=0;
int tmp=0;
int values[size];
memset(values,0, sizeof(values)*20);
for(int i=0;i<size;i++){
pinMode(i,OUTPUT);
}for(int i=0;i<15;i++){
pinMode(num2Analog(i),INPUT);
}
int memory=0;
for(int i=0;i<strlen(code);i++){
  if(code[i]== '>'){
    pinNum++;  
  }else if(code[i]== '<'){
    pinNum--;
  }else if(code[i]== '+'){
    values[pinNum]++;
  }
  else if(code[i]== '-'){
    values[pinNum]--;
    
  }else if(code[i]== '$'){
    memory=values[pinNum];
    
  }else if(code[i]== '!'){
    values[pinNum]=memory;
    
  }else if(code[i]== '*'){
    values[pinNum]=values[pinNum]*2;
  }
  else if(code[i]== '/'){
    values[pinNum]=values[pinNum]*2; 
  }else if(code[i]== '1'){
    values[pinNum]=1023;
  }
  else if(code[i]== '0'){
    values[pinNum]=0; 
  }else if(code[i]== 'O'){
    pinNum=0; 
  }else if(code[i]== '['){
    if(values[pinNum]==0){
      i++;
      while (code[i] != ']' || tmp!=0){
        if(code[i]=='['){
          tmp++;
        }else if(code[i]==']'){
          tmp--;  
        }
        i++;
        }
      }
      
  }else if(code[i]== ']'){
    if(values[pinNum]!=0){
      i--;
      while (code[i] != '[' || tmp>0){
        if(code[i]==']'){
          tmp++;
        }else if(code[i]=='['){
          tmp--;  
        }
        i--;
        }
      i--;
      }
  }else if(code[i]== '.'){
    if(pinNum==0){
      delay(10*values[0]);
    }else{
      analogWrite(pinNum,values[pinNum]);
      }
  }else if(code[i]== ','){
    values[pinNum]=analogRead(num2Analog(pinNum));  
  }
}  
}