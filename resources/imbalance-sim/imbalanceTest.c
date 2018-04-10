#include <stdio.h>
#include <iostream>
#include <random>
#include <map>
#include <iomanip>
#include <numeric>
#include <vector>

#ifndef DEBUG
#define DEBUG 0
#endif

#define PE std::vector<uint32_t>

std::vector<uint32_t> loads;
std::vector<PE> pes;
uint32_t avgLoad;
double imbalance;

inline uint32_t sum(PE pe) {
	return std::accumulate(pe.begin(), pe.end(), 0);
} 

void showLoads() {
	#if DEBUG > 0
	printf("Loads in the system:\n");
	for (auto l : loads) {
		printf("%d, ", l);
	}
	printf("\n");
	#endif
}

void showPELoad() {
	return;
}

void showSysStats(size_t nproc) {
	#if DEBUG > 0
	printf("Showing loads of each PE in order\n");
	#endif
	size_t i = 0;
	size_t acum = 0, max = 0;
	for (auto pe : pes) {
		auto val = sum(pe);
		acum += val;
		if (max < val) max = val;
		#if DEBUG > 0
		printf("%d: %d\n", i++, val);
		#endif
	}
	avgLoad = acum/nproc;
	imbalance = ((double)max)/avgLoad;
	printf("Simulated load imbalance is %f, with average load of %d\n", imbalance, avgLoad);

}

/**
 * \a mean
 * \b standard deviation
 * \n number of elements
 **/
void createNormalDistribution(uint32_t a, uint32_t b, uint32_t n) {
	// Normal
	std::random_device rd{};
	std::mt19937 gen{rd()};
	std::normal_distribution<float> dist(a,b);
	std::map<int, int> hist{};
    
	for (size_t i =0; i < n; ++i) {
		auto load = std::round(dist(gen));
		loads.push_back(load);
		++hist[load];
	}

	// Extracted from http://en.cppreference.com/w/cpp/numeric/random/normal_distribution
	if (DEBUG > 0) for(auto p : hist) {
        std::cout << std::setw(2)
                  << p.first << ' ' << std::string(p.second, '*') << '\n';
    }

    if (DEBUG > 0 ) printf("Leaving createNormalDistribution\n");
	return;
}

void uniform(uint32_t a, uint32_t b, uint32_t n) {
	return;
}

void loadToPes(size_t nproc) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<size_t> dist(0, nproc);

	pes.resize(nproc+1);
	for (auto l : loads) {
		pes[std::round(dist(gen))].push_back(l);
	}
	
	if (DEBUG > 0) printf("Leaving loadToPes\n");
}

int main (int argc, char** argv) {
	if (argc < 6) {
		printf("Load Imbalance Sim usage instructions:\n");
		printf("Expected args are:\n");
		printf("1: Load Distribution (Currently supporting only std::normal_distribution) \n");
		printf("2 & 3: Distribution args\n");
		printf("4: Number of tasks\n5: Number of PEs\n");

	};

	int dist_type = atoi(argv[1]);
	dist_type = 2;
	uint32_t a = atoi(argv[2]); 
 	uint32_t b = atoi(argv[3]); 
 	size_t n = atoi(argv[4]);
 	size_t nproc = atoi(argv[5]);

	switch(dist_type) {
		case 2:
			createNormalDistribution(a,b,n);
			break;
		case 1:
			uniform(a,b,n);
			break;
		default:
			break;
	}

	loadToPes(nproc-1);
	if (DEBUG > 0) showPELoad();
	showSysStats(nproc);

	loads.clear();
	pes.clear();
	return 0;
}