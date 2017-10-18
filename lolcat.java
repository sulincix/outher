import java.util.*;

class HelloWorld {

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        String line;
        String[] word;
        Random r = new Random();
        while(true){
        line = in.nextLine();
        if(line == ""){
        break;
        }
         word = line.split("");
        for (int i=0;i<word.length;i++){
        System.out.print("\\033["+Integer.toString(30+r.nextInt(7))+";1m"+word[i]);
        }
        System.out.print("\\033[0m\n");}
    }
}
