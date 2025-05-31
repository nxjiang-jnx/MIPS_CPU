#include <stdio.h>

int main(){
	int a[8][8] = {0};
	int b[8][8] = {0};
	int i, j, k;
	int n;
	int cnt = 0;
	
	//input
	scanf("%d", &n);
	for(i = 0; i < n ; i++){
		for(j = 0; j < n ; j++){
			scanf("%d", &a[i][j]);
		}	
	}
	for(i = 0; i < n ; i++){
		for(j = 0; j < n ; j++){
			scanf("%d", &b[i][j]);
		}	
	}
	
	//output
	
	for(i = 0; i < n; i++){			//row of a	s3	
		for (j = 0; j < n; j++){	//col of b  s5
			cnt = 0;				//s6
			for(k = 0; k < n ; k++){	//col of a == row of b s5
				cnt = cnt + a[i][k] * b[k][j];
			}			
			printf("%d ", cnt);
		}
		printf("\n");		
	}        
			
	return 0;
}