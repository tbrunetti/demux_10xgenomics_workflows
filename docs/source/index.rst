.. 10x demultiplexing pipeline using 5' HTO for sample hashing with VDJ documentation master file, created by
   sphinx-quickstart on Tue May 24 12:55:26 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to 10x demultiplexing pipeline using 5' HTO for sample hashing with VDJ's documentation!
================================================================================================
This is a repository to help you demultiplex your single cell RNA-seq experiments when you have used all of the following chemistries on a single library:

* 10x Genomics scRNA-seq technology
* Hash Tag Oligos (HTOs) for multiplexing samples in the same library
* 5' VDJ sequencing of T-cell (TCR) or B-cell receptors (BCR)

Dependencies
^^^^^^^^^^^^

* cellranger >=6.1.2 (tested on 6.1.2)
* bash >= v4.0  

This pipeline is dependent on the open-source code, `cellranger`_, provided by 10x genomics, particulary the `multi`_ command functionality and the `bamtofastq`_ functionality.  If you have downloaded the full cellranger suite, **multi** and **bamtofastq** should already come pre-bundled and installed in the initial cellranger installation.

.. _cellranger: https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/tutorial_in
.. _multi: https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/multi
.. _bamtofastq: https://support.10xgenomics.com/docs/bamtofastq#header

Installation
^^^^^^^^^^^^
Once cellranger is installed, there are no other true installations besides cloning this repository: ::
        
        git clone https://github.com/tbrunetti/10x_scRNA_VDJ_5pirme_HTO_dumux


Full Pipeline Overview
^^^^^^^^^^^^^^^^^^^^^^


.. toctree::
   :maxdepth: 2
   :caption: Contents:



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
