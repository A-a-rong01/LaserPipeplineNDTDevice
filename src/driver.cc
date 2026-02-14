#include "include/image_processor.h"
#include "include/cpp_image_processor.h"
#include "include/py_image_processor.h"

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char *argv[])
{
    // turn the arguments into a vector of strings
    std::vector<std::string> args(argv + 1, argv + argc);

    ImageProcessor *processor = nullptr;
    if (std::find(args.begin(), args.end(), "--python") != args.end())
    {
        processor = new PyImageProcessor;
    }
    else
    {
        processor = new CppImageProcessor;
    }

    std::cout << "processor->getName() = " << processor->getName() << std::endl;
    return 0;
}