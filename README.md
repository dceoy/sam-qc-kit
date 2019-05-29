sam-qc-kit
==========

Docker-based Tools for Quality Control Checks and Visualization of SAM/BAM/CRAM Files

- Quality control (QC) checks using SAMtools
- Integrative Genomics Viewer (IGV) Web App

Usage
-----

#### Preparation

```sh
$ git clone https://github.com/dceoy/sam-qc-kit.git
$ cd sam-qc-kit
```

#### QC checks

1.  Copy your SAM/BAM/CRAM files into `input`.

    ```sh
    $ mkdir input
    $ cp -a /path/to/data/*.bam input
    ```

2.  Write results of QC checks in `output`.

    ```sh
    $ mkdir output
    $ docker-compose run --rm samtools-qc input output
    ```

    Run `docker-compose run --rm samtools-qc --help`  or `bin/samtools_qc.sh --help` for more details of options.

#### IGV Web App

1.  Run an IGV server.

    ```sh
    $ docker-compose run --rm igv-webapp
    ```

2.  View reads at `http://127.0.0.1:8888`.

Tests
-----

```sh
$ cd test
$ docker-compose run --rm test-samtools-qc
$ docker-compose run --rm igv-webapp
```

IGV Web App can be used at `http://127.0.0.1:8888`.
