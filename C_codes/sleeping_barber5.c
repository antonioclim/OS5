#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <stdint.h>

#define MAX_WAITING_CUSTOMERS 3
#define TOTAL_CUSTOMERS 7

pthread_mutex_t mutex;
pthread_cond_t customer_ready;
pthread_cond_t barber_ready;

int waiting_room[MAX_WAITING_CUSTOMERS];
int num_customers = 0;
int customers_served = 0;

void* barber(void* arg) {
    while(customers_served < TOTAL_CUSTOMERS) {
        pthread_mutex_lock(&mutex);

        while(num_customers == 0) {
            printf("Barber is sleeping.\n");
            pthread_cond_wait(&customer_ready, &mutex);
        }

        int customer_id = waiting_room[0];
        printf("Barber starts a haircut for Customer %d.\n", customer_id);
        sleep(3);

        for (int i = 0; i < num_customers - 1; i++) {
            waiting_room[i] = waiting_room[i + 1];
        }
        num_customers--;
        customers_served++;

        printf("Barber finishes a haircut for Customer %d.\n", customer_id);
        pthread_cond_signal(&barber_ready);
        pthread_mutex_unlock(&mutex);
    }
    printf("Barber's day ends after serving all customers.\n");
    return NULL;
}

void* customer(void* arg) {
    int id = (intptr_t)arg;

    pthread_mutex_lock(&mutex);
    if (num_customers < MAX_WAITING_CUSTOMERS) {
        waiting_room[num_customers++] = id;
        printf("Customer %d arrives and sits in the waiting room.\n", id);
        pthread_cond_signal(&customer_ready);
    } else {
        printf("Customer %d leaves because no chairs are available.\n", id);
    }
    pthread_mutex_unlock(&mutex);

    if (num_customers >= MAX_WAITING_CUSTOMERS) {
        sleep(5);  // Delay for retry if the waiting room was full
        customer((void *)(intptr_t)id);
    }
    return NULL;
}

int main() {
    pthread_t barber_thread, cust_threads[TOTAL_CUSTOMERS];
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&customer_ready, NULL);
    pthread_cond_init(&barber_ready, NULL);

    pthread_create(&barber_thread, NULL, barber, NULL);

    for (int i = 1; i <= TOTAL_CUSTOMERS; i++) {
        sleep(1);
        pthread_create(&cust_threads[i-1], NULL, customer, (void*)(intptr_t)i);
    }

    for (int i = 0; i < TOTAL_CUSTOMERS; i++) {
        pthread_join(cust_threads[i], NULL);
    }

    pthread_join(barber_thread, NULL);
    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&customer_ready);
    pthread_cond_destroy(&barber_ready);

    return 0;
}

