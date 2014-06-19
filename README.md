# InfoTheory.jl

A Julia package for non-parametric estimation of information theoretic quantities such as entropy and mutual information.

## Limitations

We currently use only the NaiveNeighborTree from NearestNeighbors.jl since the KDTree implementation is based on a version of the Distance.jl package which is not yet available in Julia's METADATA. Thus, performance for most of our estimators is bad but will be easily fixed once the latest versions of these packages are in sync.

## Acknowledgement

This package is partly based on the [NPEET library version 1.1 by Greg Ver Steeg](http://www.isi.edu/~gregv/npeet.html).

## Build status

[![Build Status](https://travis-ci.org/robertfeldt/InfoTheory.jl.svg?branch=master)](https://travis-ci.org/robertfeldt/InfoTheory.jl)
