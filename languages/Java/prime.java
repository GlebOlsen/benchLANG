public class prime {
    public static boolean isPrime(int n) {
        if (n <= 1)
            return false;
        if (n <= 3)
            return true;
        if (n % 2 == 0 || n % 3 == 0)
            return false;
        int i = 5;
        while (i * i <= n) {
            if (n % i == 0 || n % (i + 2) == 0)
                return false;
            i += 6;
        }
        return true;
    }
    public static void main(String[] args) {
        long start = System.currentTimeMillis();
        for (int i = 2; i < 10000000; i++) {
            if (isPrime(i))
                System.out.println(i);
        }
        long end = System.currentTimeMillis();
        double total = (double) (end - start) / 1000;
        System.out.println(total + " seconds to execute");
    }
}
