#include <iostream>
#include <fstream>
#include <vector>

int main() {
    const int numFiles = 100;
    std::vector<std::ofstream> files;

    for (int i = 0; i < numFiles; ++i) {
        std::string fileName = "file_" + std::to_string(i) + ".txt";
        files.emplace_back(fileName);

        if (!files.back().is_open()) {
            std::cerr << "Error: Unable to open " << fileName << std::endl;
            return 1;
        }
        std::cout << "Opened: " << fileName << std::endl;
        files.back() << "This is file number " << i << std::endl;
    }

    std::cout << "All files opened. Check file descriptors." << std::endl;

    std::cout << "Press Enter to close files and exit..." << std::endl;
    std::cin.get();

    return 0;
}
