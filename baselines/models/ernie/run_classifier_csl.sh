#!/usr/bin/env bash
# @Author: Li Yudong
# @Date:   2019-11-28
# @Last Modified by:   Li Yudong
# @Last Modified time: 2019-11-28

TASK_NAME="csl"
MODEL_NAME="baidu_ernie"
CURRENT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export CUDA_VISIBLE_DEVICES="0"
export PRETRAINED_MODELS_DIR=$CURRENT_DIR/prev_trained_model
export ERNIE_DIR=$PRETRAINED_MODELS_DIR/$MODEL_NAME
export GLUE_DATA_DIR=$CURRENT_DIR/../../glue/chineseGLUEdatasets

# download and unzip dataset
if [ ! -d $GLUE_DATA_DIR ]; then
  mkdir -p $GLUE_DATA_DIR
  echo "makedir $GLUE_DATA_DIR"
fi
cd $GLUE_DATA_DIR
if [ ! -d $TASK_NAME ]; then
  mkdir $TASK_NAME
  echo "makedir $GLUE_DATA_DIR/$TASK_NAME"
fi
cd $TASK_NAME
if [ ! -f "train.json" ] || [ ! -f "dev.json" ] || [ ! -f "test.json" ]; then
  rm *
  wget https://storage.googleapis.com/cluebenchmark/tasks/csl_public.zip
  unzip csl_public.zip
  rm csl_public.zip
else
  echo "data exists"
fi
echo "Finish download dataset."

# download model
if [ ! -d $ERNIE_DIR ]; then
  mkdir -p $ERNIE_DIR
  echo "makedir $ERNIE_DIR"
fi
cd $ERNIE_DIR
if [ ! -f "bert_config.json" ] || [ ! -f "vocab.txt" ] || [ ! -f "bert_model.ckpt.index" ] || [ ! -f "bert_model.ckpt.meta" ] || [ ! -f "bert_model.ckpt.data-00000-of-00001" ]; then
  rm *
  wget https://storage.googleapis.com/chineseglue/pretrain_models/baidu_ernie.zip
  unzip baidu_ernie.zip
  rm baidu_ernie.zip
else
  echo "model exists"
fi
echo "Finish download model."

# run task
cd $CURRENT_DIR
echo "Start running..."
python run_classifier.py \
  --task_name=$TASK_NAME \
  --do_train=true \
  --do_eval=true \
  --data_dir=$GLUE_DATA_DIR/$TASK_NAME \
  --vocab_file=$ERNIE_DIR/vocab.txt \
  --bert_config_file=$ERNIE_DIR/bert_config.json \
  --init_checkpoint=$ERNIE_DIR/bert_model.ckpt \
  --max_seq_length=256 \
  --train_batch_size=4 \
  --learning_rate=1e-5 \
  --num_train_epochs=3.0 \
  --output_dir=$CURRENT_DIR/${TASK_NAME}_output/
