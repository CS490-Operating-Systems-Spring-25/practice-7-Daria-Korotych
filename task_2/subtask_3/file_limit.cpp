#include <iostream>
#include <fstream>
#include <vector>
#include <thread>
#include <chrono>

int main() {
    const int batchSize = 1000;
    const int totalFiles = 100000;
    std::vector<std::ofstream> files;

    std::cout << "Starting file creation..." << std::endl;

    for (int i = 0; i < totalFiles / batchSize; ++i) {
        std::cout << "Batch " << (i + 1) << " - Attempting to open " << batchSize << " files." << std::endl;

        for (int j = 0; j < batchSize; ++j) {
            std::string fileName = "file_" + std::to_string(i * batchSize + j) + ".txt";
            files.emplace_back(fileName);

            if (!files.back().is_open()) {
                std::cerr << "Error: Failed to open " << fileName << ". Max file descriptor limit may be reached." << std::endl;
                return 1;
            }
            files.back() << "This is file number " << (i * batchSize + j) << std::endl;
        }

        std::cout << "Batch " << (i + 1) << " completed. Sleeping for 1 second..." << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    std::cout << "Completed all file operations. Press Enter to clean up and exit." << std::endl;
    std::cin.get();
    return 0;
}