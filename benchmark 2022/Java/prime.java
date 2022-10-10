public class prime
{
    public static void main(String args[])
    {
        long start = System.currentTimeMillis();
        int i, j, n = 10000000;
        for (i = 2; i <= n; i++){ 
            for (j = 2; j <= (i/j); j++){
                if (i%j == 0) {
                    break;
                }
            }
            if (j > (i/j)) 
            {
                System.out.println(i);
            }
        }
        long end = System.currentTimeMillis();
        double total = (double)(end - start)/1000;
        System.out.println(total);
    }
}