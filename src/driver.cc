#include "include/cpp_image_processor.h"
#include "include/cxxopts.hpp"
#include "include/image_processor.h"
#include "include/py_image_processor.h"

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[])
{
    cxxopts::Options options("NDT Image Analyzer", "Non-destructive testing "
        "image processing software developed for detecting microcracks and "
        "micro pits on the Raspberry Pi 5");

    options.add_options()
        ("p,python", "Run with the embedded Python interpreter")
        ("h,help", "Print usage")
    ;

    auto result = options.parse(argc, argv);

    // return early on help
    if (result.count("help"))
    {
        std::cout << options.help() << std::endl;
        return EXIT_SUCCESS;
    }
    
    ImageProcessor *processor = nullptr;
    if(result["python"].as<bool>())
    {
        processor = new PyImageProcessor;
    }
    else
    {
        processor = new CppImageProcessor;
    }

    std::cout << "processor->getName() = " << processor->getName() << std::endl;
    return EXIT_SUCCESS;
}