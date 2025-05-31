#include <stdio.h>

int f[10][10] = {0};
int g[10][10] = {0};

int cal_conv(int row, int cal, int m2, int n2){
	int i, j;
	int digit = 0;
	int temp;
	
	for(i = row; i < row + m2; i++){
		for(j = cal; j < cal + n2; j++){
			temp = f[i][j] * g[i - row][j - cal];
			digit += temp;
		}
	}
	
	return digit;
}

int main(){

	int m1, n1;		//matrix f
	int m2, n2;		//convolution h
	
	int i1, j1;
	int digit;
	
	//input
	scanf("%d", &m1);
	scanf("%d", &n1);
	scanf("%d", &m2);
	scanf("%d", &n2);
	
	for(i1 = 0; i1 < m1; i1++){
		for(j1 = 0; j1 < n1; j1++){
			scanf("%d", &f[i1][j1]);
		}
	}
	
	for(i1 = 0; i1 < m2; i1++){
		for(j1 = 0; j1 < n2; j1++){
			scanf("%d", &g[i1][j1]);
		}
	}
		
	for(i1 = 0; i1 < m1 - m2 + 1; i1++){
		for(j1 = 0; j1 < n1 - n2 + 1; j1++){
			digit = cal_conv(i1, j1, m2, n2);
			printf("%d ",digit);
		}
		printf("\n");
	}
	
	return 0;
}