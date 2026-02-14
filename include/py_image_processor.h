#ifndef PY_IMAGE_PROCESSOR_H_
#define PY_IMAGE_PROCESSOR_H_

#include "image_processor.h"

#include <pybind11/embed.h>

namespace py = pybind11;

/**
 * TODO document py image processor
 */
class PyImageProcessor : public ImageProcessor
{
public:
    /**
     * TODO document name method
     */
    std::string getName() const override;

private:
    /**
     * TODO document guard
     */
    py::scoped_interpreter guard;
};

#endif