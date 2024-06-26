#!/bin/bash


if [ -z "$1" ]; then
  echo "Usage: $0 <dbgen_size>"
  exit 1
fi

DBGEN_SIZE=$1

cd ~

# check if directory TPCH-sqlite exists
if [ ! -d "TPCH-sqlite" ]; then
  git clone https://github.com/lovasoa/TPCH-sqlite.git
  cd TPCH-sqlite
  rm -rf tpch-dbgen
  git clone https://github.com/lovasoa/tpch-dbgen.git

  SCALE_FACTOR=$DBGEN_SIZE make
  mv TPC-H.db TPC-H-$DBGEN_SIZE.db

  #check if there is already a generated db of the specified size
elif [ ! -e "TPCH-sqlite/TPC-H-$DBGEN_SIZE.db" ]; then
  rm TPCH-sqlite/tpch-dbgen/*.tbl

  cd TPCH-sqlite
  
  SCALE_FACTOR=$DBGEN_SIZE make

  mv TPC-H.db TPC-H-$DBGEN_SIZE.db
fi



cd ~

cd sqlite-unikraft-tpch

sed -i.bak -E "s|\"/TPC-H-[0-9]+.db\",|\"/TPC-H-$DBGEN_SIZE.db\",|g" Kraftfile

mkdir rootfs

cd rootfs

#if there is other dbs remove them
rm -f TPC-H-*.db

cp ~/TPCH-sqlite/TPC-H-$DBGEN_SIZE.db .
  #if the queries are not in the rootfs, copy them
  if [ ! -e query1.sql ]; then
    cp ../queries/* .
  fi

#TODO throughput



kraft build --target qemu/x86_64