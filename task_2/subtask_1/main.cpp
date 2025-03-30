#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>

int main() {
    std::ofstream file("test.txt", std::ios::out | std::ios::app);

    if (!file.is_open()) {
        std::cerr << "Error: Unable to open test.txt for writing." << std::endl;
        return 1;
    }

    for (int i = 0; i < 1000; ++i) {
        file << "Iteration " << i << std::endl;
        file.flush();
        std::cout << "Written: iteration " << i << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    std::cout << "Completed 1000 iterations." << std::endl;
    file.close();
    return 0;
}
