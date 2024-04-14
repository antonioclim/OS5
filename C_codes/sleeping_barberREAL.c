#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

#define MAX_CONNECTIONS 3
#define TOTAL_REQUESTS 10

sem_t barberReady;
sem_t customerReady;
int availableConnections = 0;

void* resourceManager(void* arg) {
    for (int i = 0; i < TOTAL_REQUESTS; i++) {
        sem_wait(&customerReady);  // Wait for a connection request
        sem_wait(&barberReady);    // Wait for a connection to become free

        // Allocate the connection
        availableConnections--;
        printf("Resource Manager: Assigned a connection. [%d remaining]\n", availableConnections);

        sem_post(&barberReady);    // Signal that manager is ready for another request
        sleep(1); // Simulate connection usage time
    }
    return NULL;
}

void* clientProcess(void* arg) {
    int num = *(int*)arg;
    sleep(rand() % 5);  // Simulate varying client arrival times

    // Request a connection
    printf("Client %d: Requesting a connection\n", num);
    sem_post(&customerReady);  // Notify the resource manager
    sem_wait(&barberReady);    // Wait for a connection to be assigned

    // Connection in use
    printf("Client %d: Using the connection\n", num);
    sleep(1); // Simulate the job being done with the connection

    // Release the connection
    availableConnections++;
    printf("Client %d: Released the connection\n", num);
    sem_post(&barberReady);  // Notify the manager that the connection is free

    return NULL;
}

int main() {
    pthread_t manager, clients[TOTAL_REQUESTS];
    int clientIds[TOTAL_REQUESTS];
    availableConnections = MAX_CONNECTIONS;

    // Initialize semaphores
    sem_init(&barberReady, 0, MAX_CONNECTIONS);
    sem_init(&customerReady, 0, 0);

    // Create the resource manager thread
    pthread_create(&manager, NULL, resourceManager, NULL);

    // Create client threads
    for (int i = 0; i < TOTAL_REQUESTS; i++) {
        clientIds[i] = i + 1;
        pthread_create(&clients[i], NULL, clientProcess, &clientIds[i]);
    }

    // Wait for all threads to finish
    pthread_join(manager, NULL);
    for (int i = 0; i < TOTAL_REQUESTS; i++) {
        pthread_join(clients[i], NULL);
    }

    // Clean up
    sem_destroy(&barberReady);
    sem_destroy(&customerReady);

    return 0;
}

