#!/usr/bin/env bash
## ---------------------------------------------------------------------------
## Licensed to the Apache Software Foundation (ASF) under one or more
## contributor license agreements.  See the NOTICE file distributed with
## this work for additional information regarding copyright ownership.
## The ASF licenses this file to You under the Apache License, Version 2.0
## (the "License"); you may not use this file except in compliance with
## the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ---------------------------------------------------------------------------
#bin/sh
echo "start building servicecomb-docs."
echo "Python version:"
python --version

CUR_DIR=$PWD
echo "env CUR_DIR=$CUR_DIR"

echo "Starting install software"
sudo pip install mkdocs==1.6.1
sudo pip install mkdocs-material==9.5.31

git clone https://github.com/apache/servicecomb-docs.git

echo "Starting compile docs"
cd $CUR_DIR/servicecomb-docs/java-chassis-reference/zh_CN
mkdocs build -d ../../docs/java-chassis/zh_CN

echo "Starting coping docs"
cd $CUR_DIR
rm -r docs/java-chassis/zh_CN/*
cp -r servicecomb-docs/docs/java-chassis/zh_CN ./docs/java-chassis/

# add some debug infos
echo "ls -l ./docs"
ls -l ./docs
echo "ls -l ./docs/java-chassis"
ls -l ./docs/java-chassis
echo "ls -l ./docs/java-chassis/zh_CN"
ls -l ./docs/java-chassis/zh_CN

echo "Starting preparing push docs"
rm -r servicecomb-docs
git add docs