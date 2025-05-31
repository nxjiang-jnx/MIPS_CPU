#include <stdio.h>
#include <string.h>

#define MAX 500  // ����һ���������󳤶ȣ��㹻�洢������ÿһλ

// ��ӡ����洢�Ĵ���
void printFactorial(int result[], int size) {
    for (int i = size - 1; i >= 0; i--) {
        printf("%d", result[i]);
    }
}

// ���׳˽�������� result ������
int multiply(int x, int result[], int result_size) {
    int carry = 0;  // �����λ
    for (int i = 0; i < result_size; i++) {
        int prod = result[i] * x + carry;
        result[i] = prod % 10;  // �����λ������
        carry = prod / 10;      // �����λ
    }

    // ����ʣ��Ľ�λ
    while (carry) {
        result[result_size] = carry % 10;
        carry = carry / 10;
        result_size++;
    }

    return result_size;
}

// ���� n �Ľ׳�
void factorial(int n) {
    int result[MAX];

    // ��ʼ�����Ϊ1
    result[0] = 1;
    int result_size = 1;

    // ��2��ʼ�˵�n
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
