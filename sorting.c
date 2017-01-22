#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

void neighbor_swap(long int *arr,long int n)
{

	if(arr[n]>arr[n+1])
	{
		long int temp = arr[n];
		arr[n] = arr[n+1];
		arr[n+1] = temp;
	}
	n--;
	if(n>=0)
	{
		neighbor_swap(arr,n);
	}

}

int main()
{
	printf("Hi, how many numbers do you need to sort ?\n");
	long int nobs;
	scanf("%ld",&nobs);
	printf("What do you want to do ?\n1 - sort randomly generated numbers\n2 - manually enter numbers\n");
	int usrchoice;
	scanf("%d",&usrchoice);
	long int nosort[nobs];
	long int i;
	switch(usrchoice){
		case 1:
			for(i=0;i<nobs;i++)
			{
				nosort[i] = rand() % 100;
			}
			printf("unsorted array:\n");
			for(i=0;i<nobs;i++)
				printf("%ld; ",nosort[i]);
			break;
		case 2:
			for(i = nobs-1;i >= 0;i--)
			{
				long int s;
				scanf("%ld", &s);
				nosort[i] = s;
			}
			break;
		default:
		printf("you had 1 job...");
	}

	printf("\nBubble sort...\n");
	i=0;
	while(i<nobs-1)
	{
		neighbor_swap(nosort,i);
		i+=1;
	}
	long int c;
	printf("Sorted array:\n");
	for(c=0;c<nobs;c++)
	{
		printf("%ld; ",nosort[c]);
	}
	printf("\n");
	return 0;
}
