#!/bin/bash
current_dir=$(dirname "$(realpath "$0")")
if ! [ -e "/tmp/sd-webui.prepared" ]; then
    bash $DISCORD_PATH "Preparing Environment for Stable Diffusion WebUI"
    # Install Python 3.10
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/sd-webui-env
    source /tmp/sd-webui-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml
    
    bash prepare_repo.sh
    export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $WEBUI_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    if [ -n "${ACTIVATE_XFORMERS}" ]; then
        pip install xformers==0.0.16
    fi

    touch /tmp/sd-webui.prepared
else
    source /tmp/sd-webui-env/bin/activate
fi

bash $DISCORD_PATH "Downloading Models"
bash $current_dir/../utils/model_download/main.sh
bash $DISCORD_PATH "Finished Downloading Models"

python $current_dir/../utils/model_download/link_model.py

bash start.sh
bash $DISCORD_PATH "Stable Diffusion WebUI Started"