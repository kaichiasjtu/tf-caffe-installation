#!/bin/bash
export P1=$1
function menu {
    clear
    echo -e 'What do you want to do?'
    echo -e '1. Install Environment'
    echo -e '2. Run in SSD300 X 300'
    echo -e '3. Train in SSD300 X 300'
    echo -en '\t\nEnter option: '
    read -n 1 option
}

function install_python {
    apt-get -y install build-essential checkinstall
    apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
    cd $MYHOME
    wget https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
    tar xzf Python-2.7.14.tgz
    cd Python-2.7.14
    ./configure
    make altinstall
    ln -s /usr/local/bin/python2.7 /usr/local/bin/python
    apt-get -y install python-pip
    pip install --upgrade pip
}

function install_dev {
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install git
    apt-get -y install curl wget
    if which python
    then
        echo
    else
        install_python
    fi
}

function install_tensorflow {
    cd $MYHOME
    if [ $P1 = 'cpu' ]
    then
        pip install tensorflow
    else
        pip install tensorflow-gpu
    fi
    git clone https://github.com/tensorflow/models.git
    apt-get -y install python-tk
    apt-get -y install protobuf-compiler python-pil python-lxml
    pip install pillow
    pip install lxml
    export TENSORFLOW_ROOT=$MYHOME/models
    cd $TENSORFLOW_ROOT/research
    protoc object_detection/protos/*.proto --python_out=.
    export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim
    python object_detection/builders/model_builder_test.py
}

function install_caffe {
    cd $MYHOME
    apt-get -y install cmake 
    apt-get -y install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler
    apt-get -y install --no-install-recommends libboost-all-dev
    apt-get -y install libatlas-base-dev
    apt-get -y install libgflags-dev libgoogle-glog-dev liblmdb-dev
    git clone https://github.com/weiliu89/caffe.git
    git checkout ssd
    export CAFFE_ROOT=$MYHOME/caffe
    export PYTHONPATH=$MYHOME/caffe/python
    cd $CAFFE_ROOT/python
    for req in $(cat requirements.txt); do pip install $req; done

    cd $CAFFE_ROOT
    sed -e 's/# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/; 
            s/INCLUDE_DIRS := $(PYTHON_INCLUDE) \/usr\/local\/include/INCLUDE_DIRS := $(PYTHON_INCLUDE) \/usr\/local\/include \/usr\/include\/hdf5\/serial/; 
            s/LIBRARY_DIRS := $(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib/LIBRARY_DIRS := $(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib \/usr\/lib\/aarch64-linux-gnu \/usr\/lib\/aarch64-linux-gnu\/hdf5\/serial/;' Makefile.config.example > Makefile.config
    make -j8
    make pycaffe
}

function run_ssd_caffe {
    echo 'run_ssd_caffe'
}

function run_ssd_tensorflow {
    export TENSORFLOW_ROOT=$MYHOME/models
    cd TENSORFLOW_ROOT/research/object_detection
    wget http://download.tensorflow.org/models/object_detection/ssd_inception_v2_coco_2017_11_17.tar.gz
    tar -xzvf ssd_inception_v2_coco_2017_11_17.tar.gz
    tar -xvf output.tar
}

export MYHOME=/home/ubuntu
menu
echo
case $option in
0)
    install_tensorflow ;;
1)
    echo -e 'Which one you want to install?'
    echo -e '1. tensorflow'
    echo -e '2. caffe'
    echo -e '3. tensorflow & caffe'
    echo -en '\t\nEnter option: '
    read -n 1 option
    echo
    case $option in   
    1)
        install_dev
        install_tensorflow ;;
    2)
        install_dev
        install_caffe ;;
    3)
        install_dev
        install_tensorflow
        install_caffe ;;
    *)
        echo 'leave' ;;
    esac ;;

2)
    echo -e 'Which one platform you want to run?'
    echo -e '1. tensorflow'
    echo -e '2. caffe'
    echo -en '\t\nEnter option: '
    read -n 1 option
    echo
    case $option in   
    1)
        run_ssd_tensorflow ;;
    2)
        run_ssd_caffe ;;
    *)
        echo 'leave' ;;
    esac ;;
*)
    echo 'leave' ;;
esac