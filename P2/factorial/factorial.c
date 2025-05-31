#include <stdio.h>
#include <string.h>

#define MAX 500  // 定义一个数组的最大长度，足够存储大数的每一位

// 打印数组存储的大数
void printFactorial(int result[], int size) {
    for (int i = size - 1; i >= 0; i--) {
        printf("%d", result[i]);
    }
}

// 将阶乘结果保存在 result 数组中
int multiply(int x, int result[], int result_size) {
    int carry = 0;  // 保存进位
    for (int i = 0; i < result_size; i++) {
        int prod = result[i] * x + carry;
        result[i] = prod % 10;  // 将最低位存入结果
        carry = prod / 10;      // 计算进位
    }

    // 处理剩余的进位
    while (carry) {
        result[result_size] = carry % 10;
        carry = carry / 10;
        result_size++;
    }

    return result_size;
}

// 计算 n 的阶乘
void factorial(int n) {
    int result[MAX];

    // 初始化结果为1
    result[0] = 1;
    int result_size = 1;

    // 从2开始乘到n
    for (int x = 2; x <= n; x++) {
        result_size = multiply(x, result, result_size);
    }

    printFactorial(result, result_size);
}

int main() {
    int n;
    scanf("%d", &n);
    
    factorial(n);
    return 0;
}
