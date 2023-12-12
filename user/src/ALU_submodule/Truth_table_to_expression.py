import sympy as sym
from bitstring import Bits

import random
sym.init_printing()
a,b,c,d,e,f,g = sym.symbols('w[6],w[5],w[4],w[3],w[2],w[1],w[0]')


boundary = [  -64,-13,-4,4,12,64]
result = []
for i in range(5):
    miniterm = []
    for j in range(boundary[i],boundary[i+1]):
        # 将整数转换为指定位数的二进制补码表示
        binary = Bits(int=j, length=7).bin
        binary_list = [int(bit) for bit in binary]
        miniterm.append(binary_list)
    result.append(sym.simplify(sym.SOPform([a,b,c,d,e,f,g], miniterm)))
    
for i in range(2,-3,-1):
    if(i>=0):
        print('    assign   ','q%d  []='%i,(result[i+2]),';')
    else:
        print('    assign   ','q%d_n[]='%-i,(result[i+2]),';')

bin(random.randint(-2**64,2**64))




