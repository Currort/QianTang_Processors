a = ""
b = 1
a=list(a)
print(bin(b)[2:].zfill(3))
for i in range(65):
    a.append('*')
for i in range(len(a)-1,-1,-1):
    print(i)
    d=''.join(a)
    print(d)
    a[i] = '0'
    if i+1 ==64:
        a[i] = '1'
    elif i+1 ==0:
        print(1)
    elif (i+1)%4==0:
        c = bin(b)[2:].zfill(3)
        a[i+1] = c[2]
        a[i] =   c[1]
        a[i-1] = c[0]
        # print(c[0]+c[1]+c[2])
        if b!=7:
            b+=1
            
    
            
zero_index  =''
invert_index=''
double_index='' 
d=0
# for i in range(len(a)-1,-1,-1):
#     print((len(a)-1-i))
#     if (len(a)-1-i) %2==0:
#         d=d+1
#         print(d)
for i in range(len(a)-1,-1,-1):
    if (len(a)-1-i) ==0:
        c = '000'
        match c :
            case '000':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
            case '001':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '010':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '011':
                zero_index  +='0'
                invert_index+='0'
                double_index+='1'
            case '100':
                zero_index  +='0'
                invert_index+='1'
                double_index+='1'
            case '101':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '110':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '111':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
    elif (len(a)-1-i) ==len(a)-1:
        print(1)
        c = a[i] + a[i] + a[i+1]
        match c :
            case '000':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
            case '001':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '010':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '011':
                zero_index  +='0'
                invert_index+='0'
                double_index+='1'
            case '100':
                zero_index  +='0'
                invert_index+='1'
                double_index+='1'
            case '101':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '110':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '111':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
    elif (len(a)-1-i) %2==0:
        c = a[i-1] + a[i] + a[i+1]
        print(c)
        print(i)
        match c :
            case '000':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
            case '001':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '010':
                zero_index  +='0'
                invert_index+='0'
                double_index+='0'
            case '011':
                zero_index  +='0'
                invert_index+='0'
                double_index+='1'
            case '100':
                zero_index  +='0'
                invert_index+='1'
                double_index+='1'
            case '101':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '110':
                zero_index  +='0'
                invert_index+='1'
                double_index+='0'
            case '111':
                zero_index  +='1'
                invert_index+='0'
                double_index+='0'
            
c=''.join(a)          
print(len(a))
print('data_in='+ c)
z=list(zero_index)
print('zero_index='+ ''.join(reversed(z)))
z=list(invert_index)
print('invert_index='+''.join(reversed(z)))
z=list(double_index)
print('double_index='+''.join(reversed(z)))

# data_in=0011001100110011001100110011001100110010000100000011001000010000
                                                                        #   62 63 64
#         0011001100110011001100110011001100110010000100000011001000010000
# zero_index=         hex(int('00000000000000000000101100001011',2))
#                     00000000000000000000101100001011
                  
# invert_index=       01010101010101010101000001010000
#                     01010101010101010101000001010000
                      
# double_index=       00000000000000000001000000010000
#                     00000000000000000001000000010000