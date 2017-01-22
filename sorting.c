#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

void swap(int *arr, int n)
{

	if(arr[n]>arr[n+1])
	{
		int temp = arr[n];
		arr[n] = arr[n+1];
		arr[n+1] = temp;
		n--;
		if(n>=0)
		{
			swap(arr,n);
		}
	}

}

int main()
{
	printf("Hi, how many numbers do you need to sort ?\n");
	int nobs;
	scanf("%d",&nobs);
	printf("Hello, enter %d numbers and I will sort them.\n",nobs);
	int nosort[nobs];
	int i;
	int c;
	for(i = 0;i < nobs;i++)
	{
		int s;
		scanf("%d", &s);
		nosort[i] = s;
	}
	printf("Selection sort...\n");
	i=0;
	while(i<nobs-1)
	{
		swap(nosort,i);
		i+=1;
	}
	printf("Sorted array:\n");
	for(c=0;c<nobs;c++)
	{
		printf("%d;",nosort[c]);
	}
	printf("\n");
	return 0;
}
