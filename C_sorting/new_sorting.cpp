#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <iostream>
using namespace std;

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

void swap(long int *arr,long int p,long int small)
{
	long int temp = arr[small];
	arr[small] = arr[p];
	arr[p] = temp;
}

void select_sort(long int *arr, long int nobs){
	long int i, small, p;
	for(p=0;p<nobs;p++){
		small = p;
		for(i=p;i<nobs;i++){
			if(arr[i]<arr[small]){
				small=i;
			}
		}
		swap(arr,p,small);
	}
}

void bubble_sort(long int *arr,long int nobs){
	long int i=0;
	while(i<nobs-1){
		neighbor_swap(arr,i);
		i+=1;
	}
}

void quick_sort(long int *arr, long int nobs){
	long int p=nobs;
	long int i;
	if(nobs>1){
		for(i=0;i<p;i++){
			if(arr[i]>arr[p]){
				swap(arr,p-1,p);
				swap(arr,i,p);
				p--;
			}
		}
		quick_sort(arr,p);
		quick_sort((arr+p),nobs);
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
			printf("\n");
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
	time_t bench;
	printf("What sorting algorithm do you want to use ?\n1 - Bubble\n\
																											 2 - Selection\n\
																											 3 - Quicksort\n");
	int method;
	scanf("%d",&method);
	switch(method){
			case 1:
				printf("Performing bubble sort...\n");
				bench = time(NULL);
				bubble_sort(nosort,nobs);
				bench = time(NULL) - bench;
				break;
			case 2:
				printf("Performing selection sort...\n");
				bench = time(NULL);
				select_sort(nosort,nobs);
				bench = time(NULL) - bench;
				break;
			case 3:
				printf("Performing quick sort...\n");
				bench = time(NULL);
				quick_sort(nosort,nobs);
				bench = time(NULL) - bench;
				break;
			default:
				printf("You did not choose a valid method, bye.\n");
	}
	long int c;
	printf("Sorted array:\n");
	for(c=0;c<nobs;c++)
	{
		printf("%ld; ",nosort[c]);
	}
	printf("\n");
	printf("Sorting took %ld seconds.",bench);
	return 0;
}
