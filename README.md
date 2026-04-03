# INTEGRAL OSA including Python and HEASoft (with pyXSpec)


[![Docker Pulls](https://img.shields.io/docker/pulls/integralsw/osa-python.svg)](https://hub.docker.com/repository/docker/integralsw/osa-python/)

this is a version of the [official OSA docker](https://gitlab.astro.unige.ch/savchenk/osa-docker/), but with recent python version.

heasoft needs to be re-built with python, hence the image built may take a while.

to test 

```bash
$ make pull
$ make test
```

To run an interactive jupyter lab:

```bash
$ make jupyter
```

## Image Contents

* A latest Python version, currently 3.10.11.
* OSA
* HEASoft, usually the latest version. Note that some OSA tools related to response matrix rebinning for ISGRI and JEM-X as well as standard ISGRI and JEM-X pipelines are not compatible with HEASoft versions newer than 6.28.

## What is not inside:

components which evolve at a much higher pace than the omage content, are not included and should be synced or mounted separately.

* **INTEGRAL data archive**: it should be accessed remotely FTP, HTTP, rsync, or APIs.
* **INTEGRAL IC tree**: latest version should be synced in shared area.
* **example notebooks**: since they are rapidly evolving and are contributed by different members.

# Using the OSA Python interative environment

Notebooks for use in the jupyter lab are not included. A diverse set of examples is available here:

https://github.com/cdcihub/oda_api_benchmark/

# Consideration of Reproducibility

Interactive workflows (even in repeatable/reproducible environment) can not be sticktly repeatable/reproducible, since they depend on the human input. What consituties input may vary. In this image, we consider cloning repositories with well-defined and tracked notebooks to be user input. Hence, the fact that notebooks are not in the image does not make the workflows relying on it less reproducibly.

For notes on differences between reproducibility, repeatablility, and reusablity consider: 

https://github.com/volodymyrss/reproducibility-motivation
