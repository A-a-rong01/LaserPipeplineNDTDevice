#include "include/py_image_processor.h"

#include <iostream>

std::string PyImageProcessor::getName() const
{
    try
    {
        py::module_ pyProcessor = py::module_::import("scripts.pyprocessor");
        py::object executor = pyProcessor.attr("get_name");
        py::object resultObject = executor();
        return resultObject.cast<std::string>();
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << '\n';
        return "Get name failed";
    }
}