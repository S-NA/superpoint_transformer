#!/usr/bin/env pwsh

# For emojis to display properly, save this file as UTF8 with BOM.

# Local variables
$PROJECT_NAME = "spt"
$PYTHON = 3.8


# Recover the project's directory from the position of the install.sh
# script and move there. Not doing so would install some dependencies in
# the wrong place
$HERE = $PSScriptRoot
cd $HERE


# Installation of Superpoint Transformer in a conda environment
Write-Host "_____________________________________________"
Write-Host
Write-Host "         ☁ Superpoint Transformer 🤖         "
Write-Host "                  Installer                  "
Write-Host
Write-Host "_____________________________________________"
Write-Host
Write-Host
Write-Host "⭐ Searching for installed conda"
Write-Host

# Recover the path to conda on your machine
# First search the default '~/miniconda3' and '~/anaconda3' paths. If
# those do not exist, ask for user input
$CONDA_DIR = "C:\ProgramData\anaconda3"
$CONDA_PREFIX = Join-Path -Path $CONDA_DIR -ChildPath "envs" | Join-Path -ChildPath $PROJECT_NAME

IF (!(Test-Path $CONDA_DIR))
{
    throw "Could not find conda at: $CONDA_DIR"
}

Write-Host
Write-Host
Write-Host "⭐ Creating conda environment '${PROJECT_NAME}'"
Write-Host

# Create deep_view_aggregation environment from yml
conda create --name ${PROJECT_NAME} python=${PYTHON} -y

# Activate the env
conda activate ${PROJECT_NAME}

Write-Host
Write-Host
Write-Host "⭐ Installing conda and pip dependencies"
Write-Host
conda install pip nb_conda_kernels -y
pip install matplotlib
pip install plotly==5.9.0
pip install "jupyterlab>=3" "ipywidgets>=7.6" jupyter-dash
pip install "notebook>=5.3" "ipywidgets>=7.5"
pip install ipykernel
pip install torch==2.0.* torchvision --index-url https://download.pytorch.org/whl/cu118
pip install torchmetrics[detection]
# note removal of pyg_lib
pip install torch_geometric==2.3 torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.0.0+cu118.html
pip install plyfile
pip install h5py
pip install colorhash
pip install seaborn
pip install numba
pip install pytorch-lightning
pip install pyrootutils
pip install hydra-core --upgrade
pip install hydra-colorlog
pip install hydra-submitit-launcher
pip install rich
pip install torch_tb_profiler
pip install wandb
pip install gdown


#*********************************

Write-Host
Write-Host
Write-Host "⭐ Installing FRNN"
Write-Host
git clone --recursive https://github.com/S-NA/FRNN.git src/dependencies/FRNN
cd src\dependencies\FRNN
git checkout use-portable-types
cd ..\..\..

# install a prefix_sum routine first
cd src\dependencies\FRNN\external\prefix_sum
python setup.py install

# install FRNN
cd ..\..\ # back to the {FRNN} directory
python setup.py install
cd ..\..\..\

Write-Host
Write-Host
Write-Host "⭐ Installing Point Geometric Features"
Write-Host
conda install -c conda-forge eigen -y
Set-Item -Path Env:EIGEN_LIB_PATH -Value (Join-Path -Path $CONDA_PREFIX -ChildPath "Library" | Join-Path -ChildPath "include")
python -m pip install git+https://github.com/drprojects/point_geometric_features

Write-Host
Write-Host
Write-Host "⭐ Installing Parallel Cut-Pursuit"
Write-Host
# Clone parallel-cut-pursuit and grid-graph repos
git clone -b improve_merge https://gitlab.com/1a7r0ch3/parallel-cut-pursuit.git src\dependencies\parallel_cut_pursuit
git clone https://gitlab.com/1a7r0ch3/grid-graph.git src\dependencies\grid_graph

# Compile the projects
python scripts\setup_dependencies.py build_ext

Write-Host
Write-Host
Write-Host "🚀 Successfully installed SPT"