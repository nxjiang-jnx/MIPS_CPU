#include <stdio.h>

int main(){
	char a[20] = {0};
	int n;
	int i;
	int flag = 1;
	
	scanf("%d", &n);
	getchar();
	
	
	for(i = 0; i < n; i++){
		scanf("%c", &a[i]);
	}                   
	
	for(i = 0; i < n / 2; i++){
		if(a[i] != a[n - i - 1]){
			flag = 0;
			break;
		}
	}
	
	printf("%d", flag);
	return 0;
}