public class fib
{
    static int fib(int n) {
        if (n <= 1) 
        {
            return n;
        }
        return fib(n-1) + fib(n-2);
    }
    public static void main(String args[])
    {
        long start = System.currentTimeMillis();
        fib(45);
        long end = System.currentTimeMillis();
        double total = (double)(end - start)/1000;
        System.out.println(total);
    }
}