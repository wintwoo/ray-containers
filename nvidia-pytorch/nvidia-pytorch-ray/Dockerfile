FROM rayproject/nvidia-pytorch-ray-deps:2.9.3-py310-gpu 

ARG WHEEL_PATH
ARG FIND_LINKS_PATH=".whl"
ARG CONSTRAINTS_FILE="requirements_compiled.txt"

COPY requirements_compiled.txt ./
COPY $WHEEL_PATH .
# COPY $FIND_LINKS_PATH $FIND_LINKS_PATH

RUN pip --no-cache-dir install -c $CONSTRAINTS_FILE \
    `basename $WHEEL_PATH`[all] \
    && sudo rm `basename $WHEEL_PATH`

ENV PATH="${PATH}:${HOME}/.local/bin"

RUN pip freeze > /home/ray/pip-freeze.txt
