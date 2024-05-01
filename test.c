#include <stdio.h>
#include <string.h>

int main() {
    char *str = "Hello, World!";
    int length = strlen(str);
    
    if (length > 0) {
        char *lastCharPtr = str + length - 1;
        unsigned char lastChar = (unsigned char)(*lastCharPtr);
        printf("%d",length);
        // 输出最后一位字符的二进制编码
        printf("Binary representation of the last character: ");
        for (int i = 7; i >= 0; i--) {
            printf("%d", (lastChar >> i) & 1);
        }
        printf("%X", lastChar);
        printf("\n");
    }
    
    return 0;
}