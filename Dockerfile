FROM python:3.8

LABEL maintainer "miso3"

ENV GOOGLE_APPLICATION_CREDENTIALS /gcp-key.json

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y cmake build-essential gcc g++ git


# install python libraries
COPY requirements.txt requirements.txt
RUN pip install -U pip
RUN pip install -r requirements.txt

## light gbm
RUN git clone --recursive https://github.com/Microsoft/LightGBM && \
        cd LightGBM/python-package && python setup.py install

RUN apt autoremove -y && apt clean && \
        rm -rf /usr/local/src/*

## jupyter

RUN yes | jupyter notebook --generate-config --allow-root
ENV JUPYTER_CONFIG /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip = '0.0.0.0'" >> ${JUPYTER_CONFIG}
RUN echo "c.NotebookApp.open_browser = False" >> ${JUPYTER_CONFIG}
RUN echo "c.NotebookApp.token = ''" >> ${JUPYTER_CONFIG}
RUN echo "c.NotebookApp.password = ''" >> ${JUPYTER_CONFIG}
RUN echo "c.NotebookApp.terminado_settings = { 'shell_command': ['/bin/bash'] }" >> ${JUPYTER_CONFIG}

# run JupyterLab
EXPOSE 8888
VOLUME /work
WORKDIR "/work"
CMD ["jupyter", "lab", "--allow-root"]
