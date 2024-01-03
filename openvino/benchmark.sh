#!/bin/bash

export PATH="$PATH:$(pwd)/venv-ov22.3/bin"

echo ""
echo "download:"
omz_downloader --name resnet-50-tf

echo ""
echo "convert:"
omz_converter --name resnet-50-tf --precisions FP16

echo ""
echo "benchmark(CPU):"
benchmark_app -m public/resnet-50-tf/FP16/resnet-50-tf.xml -niter 100 -d CPU

echo ""
echo "benchmark(GPU):"
benchmark_app -m public/resnet-50-tf/FP16/resnet-50-tf.xml -niter 100 -d GPU
