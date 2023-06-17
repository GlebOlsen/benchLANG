import time
start = time.time()
num=100000
for prime in range(3, num+1):
    check = False
    for factor in range(2, prime):
        if prime%factor == 0:
            check = True
            break
    else:
        print(prime)
end = time.time()
print((end-start) * 10**3, 'ms')
